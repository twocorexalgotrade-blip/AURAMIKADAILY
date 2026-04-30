import { Router, Response } from 'express';
import { z } from 'zod';
import { pool } from '../config/db';
import { requireAuth } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../types';
import { randomUUID } from 'crypto';

const router = Router();

const CreateCustomOrderSchema = z.object({
  description: z.string().min(10).max(2000),
  budget: z.number().positive().optional(),
  imageUrls: z.array(z.string().url()).max(5).optional(),
});

// POST /custom-orders
router.post('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = CreateCustomOrderSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { description, budget, imageUrls } = parsed.data;
  const id = randomUUID();

  await pool.query(
    `INSERT INTO custom_orders (id, user_uid, description, budget, image_urls)
     VALUES ($1, $2, $3, $4, $5)`,
    [id, req.uid, description, budget ?? null, imageUrls ?? []],
  );

  res.status(201).json({ id });
});

// GET /custom-orders
router.get('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const result = await pool.query(
    'SELECT * FROM custom_orders WHERE user_uid = $1 ORDER BY created_at DESC LIMIT 20',
    [req.uid],
  );
  res.json({ customOrders: result.rows });
});

// GET /custom-orders/:id
router.get('/:id', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const result = await pool.query('SELECT * FROM custom_orders WHERE id = $1', [req.params['id']]);
  if (result.rows.length === 0) throw new AppError(404, 'Custom order not found');
  if (result.rows[0].user_uid !== req.uid) throw new AppError(403, 'Forbidden');
  res.json(result.rows[0]);
});

export default router;
