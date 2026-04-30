import { Router, Response } from 'express';
import { z } from 'zod';
import { auth } from '../config/firebase';
import { pool } from '../config/db';
import { requireAuth } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../types';

const router = Router();

const RegisterSchema = z.object({
  name: z.string().min(1),
  phone: z.string().min(10),
  email: z.string().email().optional(),
  dob: z.string().optional(),
});

// POST /auth/register
router.post('/register', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = RegisterSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { name, phone, email, dob } = parsed.data;

  const existing = await pool.query('SELECT uid FROM users WHERE uid = $1', [req.uid]);
  if (existing.rows.length > 0) {
    const profile = await pool.query('SELECT * FROM users WHERE uid = $1', [req.uid]);
    res.json({ isNewUser: false, profile: profile.rows[0] });
    return;
  }

  const result = await pool.query(
    `INSERT INTO users (uid, name, phone, email, dob)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
    [req.uid, name, phone, email ?? null, dob ?? null],
  );

  res.status(201).json({ isNewUser: true, profile: result.rows[0] });
});

// DELETE /auth/account
router.delete('/account', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  await pool.query('DELETE FROM users WHERE uid = $1', [req.uid]);
  await auth.deleteUser(req.uid);
  res.json({ deleted: true });
});

export default router;
