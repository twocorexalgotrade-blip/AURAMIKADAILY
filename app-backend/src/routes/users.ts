import { Router, Response } from 'express';
import { z } from 'zod';
import { pool } from '../config/db';
import { requireAuth } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../types';

const router = Router();

const AddressSchema = z.object({
  label: z.string().min(1).default('Home'),
  name: z.string().min(1),
  phone: z.string().min(10),
  line1: z.string().min(1),
  city: z.string().min(1),
  pin_code: z.string().optional(),
});

const ProfileUpdateSchema = z.object({
  name: z.string().min(1).optional(),
  email: z.string().email().optional(),
  dob: z.string().optional(),
  image_path: z.string().optional(),
});

// GET /users/me
router.get('/me', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const userRes = await pool.query('SELECT * FROM users WHERE uid = $1', [req.uid]);
  if (userRes.rows.length === 0) throw new AppError(404, 'User not found');

  const addrRes = await pool.query(
    'SELECT * FROM addresses WHERE user_uid = $1 ORDER BY id',
    [req.uid],
  );

  res.json({ ...userRes.rows[0], addresses: addrRes.rows });
});

// PATCH /users/me
router.patch('/me', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = ProfileUpdateSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const updates = parsed.data;
  const fields = Object.keys(updates);
  if (fields.length === 0) { res.json({ updated: false }); return; }

  const setClauses = fields.map((f, i) => `${f} = $${i + 2}`).join(', ');
  const values = fields.map(f => (updates as Record<string, unknown>)[f]);

  await pool.query(
    `UPDATE users SET ${setClauses}, updated_at = NOW() WHERE uid = $1`,
    [req.uid, ...values],
  );
  res.json({ updated: true });
});

// GET /users/me/addresses
router.get('/me/addresses', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const result = await pool.query(
    'SELECT * FROM addresses WHERE user_uid = $1 ORDER BY id',
    [req.uid],
  );
  res.json({ addresses: result.rows });
});

// POST /users/me/addresses
router.post('/me/addresses', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = AddressSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { label, name, phone, line1, city, pin_code } = parsed.data;
  const result = await pool.query(
    `INSERT INTO addresses (user_uid, label, name, phone, line1, city, pin_code)
     VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
    [req.uid, label, name, phone, line1, city, pin_code ?? ''],
  );
  res.status(201).json({ added: true, address: result.rows[0] });
});

// DELETE /users/me/addresses/:id
router.delete('/me/addresses/:id', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const id = parseInt(req.params['id'] ?? '', 10);
  if (isNaN(id)) throw new AppError(400, 'Invalid address id');

  const result = await pool.query(
    'DELETE FROM addresses WHERE id = $1 AND user_uid = $2 RETURNING id',
    [id, req.uid],
  );
  if (result.rowCount === 0) throw new AppError(404, 'Address not found');
  res.json({ deleted: true });
});

export default router;
