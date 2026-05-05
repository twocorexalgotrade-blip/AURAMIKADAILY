import { Router, Request, Response } from 'express';
import { pool } from '../config/db';
import { AppError } from '../middleware/errorHandler';

const router = Router();

// GET /vendors
router.get('/', async (_req: Request, res: Response) => {
  const result = await pool.query(
    `SELECT v.*,
            (SELECT COUNT(*) FROM products p WHERE p.vendor_id = v.id)::int AS total_products
     FROM vendors v
     ORDER BY v.name LIMIT 50`,
  );
  res.json({ vendors: result.rows });
});

// GET /vendors/:id/products — MUST be before /:id
router.get('/:id/products', async (req: Request, res: Response) => {
  const limit = Math.min(parseInt((req.query['limit'] as string) || '20', 10), 100);
  const result = await pool.query(
    'SELECT * FROM products WHERE vendor_id = $1 ORDER BY created_at DESC LIMIT $2',
    [req.params['id'], limit],
  );
  res.json({ products: result.rows });
});

// GET /vendors/:id
router.get('/:id', async (req: Request, res: Response) => {
  const result = await pool.query('SELECT * FROM vendors WHERE id = $1', [req.params['id']]);
  if (result.rows.length === 0) throw new AppError(404, 'Vendor not found');
  res.json(result.rows[0]);
});

export default router;
