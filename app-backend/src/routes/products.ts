import { Router, Request, Response } from 'express';
import { pool } from '../config/db';
import { requireAuth } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../types';

const router = Router();

// GET /products/wishlist/mine — MUST be before /:id
router.get('/wishlist/mine', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const result = await pool.query(
    `SELECT p.* FROM products p
     JOIN wishlist_items w ON w.product_id = p.id
     WHERE w.user_uid = $1
     ORDER BY w.created_at DESC`,
    [req.uid],
  );
  res.json({ products: result.rows });
});

// GET /products/search?q=...
router.get('/search', async (req: Request, res: Response) => {
  const q = (req.query['q'] as string ?? '').trim();
  if (!q) throw new AppError(400, 'Query param q is required');

  const result = await pool.query(
    `SELECT * FROM products
     WHERE in_stock = true
       AND (product_name ILIKE $1 OR brand_name ILIKE $1 OR category ILIKE $1 OR vibe ILIKE $1)
     ORDER BY created_at DESC LIMIT 30`,
    [`%${q}%`],
  );
  res.json({ products: result.rows });
});

// GET /products
router.get('/', async (req: Request, res: Response) => {
  const { vibe, category, limit = '20', offset = '0' } = req.query as Record<string, string>;
  const pageSize = Math.min(parseInt(limit, 10) || 20, 100);
  const pageOffset = parseInt(offset, 10) || 0;

  const conditions: string[] = ['in_stock = true'];
  const values: unknown[] = [];

  if (vibe) { values.push(vibe); conditions.push(`vibe = $${values.length}`); }
  if (category) { values.push(category); conditions.push(`category = $${values.length}`); }

  values.push(pageSize, pageOffset);
  const result = await pool.query(
    `SELECT * FROM products
     WHERE ${conditions.join(' AND ')}
     ORDER BY created_at DESC
     LIMIT $${values.length - 1} OFFSET $${values.length}`,
    values,
  );
  res.json({ products: result.rows, nextOffset: result.rows.length === pageSize ? pageOffset + pageSize : null });
});

// GET /products/:id
router.get('/:id', async (req: Request, res: Response) => {
  const result = await pool.query('SELECT * FROM products WHERE id = $1', [req.params['id']]);
  if (result.rows.length === 0) throw new AppError(404, 'Product not found');
  res.json(result.rows[0]);
});

// POST /products/:id/wishlist — toggle
router.post('/:id/wishlist', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const productId = req.params['id']!;

  const existing = await pool.query(
    'SELECT 1 FROM wishlist_items WHERE user_uid = $1 AND product_id = $2',
    [req.uid, productId],
  );

  if (existing.rows.length > 0) {
    await pool.query(
      'DELETE FROM wishlist_items WHERE user_uid = $1 AND product_id = $2',
      [req.uid, productId],
    );
    res.json({ wishlisted: false });
  } else {
    await pool.query(
      'INSERT INTO wishlist_items (user_uid, product_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [req.uid, productId],
    );
    res.json({ wishlisted: true });
  }
});

export default router;
