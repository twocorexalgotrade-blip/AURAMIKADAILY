import { Router, Response } from 'express';
import { z } from 'zod';
import { pool } from '../config/db';
import { requireAuth } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../types';

const router = Router();

const RegisterSchema = z.object({
  productId: z.string().min(1),
});

// ── POST /reminders  — register interest in an out-of-stock product ───────────
router.post('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = RegisterSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { productId } = parsed.data;

  // Verify product exists and is actually out of stock
  const product = await pool.query(
    'SELECT id, in_stock FROM products WHERE id = $1',
    [productId],
  );
  if (product.rows.length === 0) throw new AppError(404, 'Product not found');
  if (product.rows[0].in_stock) throw new AppError(400, 'Product is already in stock');

  await pool.query(
    `INSERT INTO stock_reminders (user_uid, product_id)
     VALUES ($1, $2)
     ON CONFLICT (user_uid, product_id) DO NOTHING`,
    [req.uid, productId],
  );

  res.status(201).json({ registered: true, productId });
});

// ── DELETE /reminders/:productId  — cancel reminder ──────────────────────────
router.delete('/:productId', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  await pool.query(
    'DELETE FROM stock_reminders WHERE user_uid = $1 AND product_id = $2',
    [req.uid, req.params['productId']],
  );
  res.json({ cancelled: true });
});

// ── GET /reminders  — list product IDs the user is watching ──────────────────
router.get('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const result = await pool.query(
    'SELECT product_id FROM stock_reminders WHERE user_uid = $1',
    [req.uid],
  );
  res.json({ productIds: result.rows.map((r: { product_id: string }) => r.product_id) });
});

export default router;
