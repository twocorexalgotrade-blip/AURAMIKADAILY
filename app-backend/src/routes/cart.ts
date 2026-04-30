import { Router, Response } from 'express';
import { z } from 'zod';
import { pool } from '../config/db';
import { requireAuth } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../types';

const router = Router();

const CartItemSchema = z.object({
  productId: z.string().min(1),
  quantity: z.number().int().min(1).max(10),
  isExpress: z.boolean().default(false),
});

// GET /cart
router.get('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const result = await pool.query(
    'SELECT * FROM cart_items WHERE user_uid = $1 ORDER BY id',
    [req.uid],
  );
  res.json({ items: result.rows });
});

// PUT /cart/items
router.put('/items', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = CartItemSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { productId, quantity, isExpress } = parsed.data;
  await pool.query(
    `INSERT INTO cart_items (user_uid, product_id, quantity, is_express, updated_at)
     VALUES ($1, $2, $3, $4, NOW())
     ON CONFLICT (user_uid, product_id)
     DO UPDATE SET quantity = $3, is_express = $4, updated_at = NOW()`,
    [req.uid, productId, quantity, isExpress],
  );

  const result = await pool.query('SELECT * FROM cart_items WHERE user_uid = $1', [req.uid]);
  res.json({ items: result.rows });
});

// DELETE /cart/items/:productId
router.delete('/items/:productId', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  await pool.query(
    'DELETE FROM cart_items WHERE user_uid = $1 AND product_id = $2',
    [req.uid, req.params['productId']],
  );
  res.json({ deleted: true });
});

// DELETE /cart
router.delete('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  await pool.query('DELETE FROM cart_items WHERE user_uid = $1', [req.uid]);
  res.json({ cleared: true });
});

export default router;
