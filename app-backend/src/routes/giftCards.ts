import { Router, Response } from 'express';
import { z } from 'zod';
import { pool } from '../config/db';
import { requireAuth } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../types';

const router = Router();

// POST /gift-cards/validate
router.post('/validate', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const { code } = z.object({ code: z.string().min(1) }).parse(req.body);

  const result = await pool.query('SELECT * FROM gift_cards WHERE code = $1', [code]);
  if (result.rows.length === 0) throw new AppError(404, 'Gift card not found');

  const gc = result.rows[0];
  if (gc.status !== 'active') throw new AppError(400, `Gift card is ${gc.status as string}`);
  if (gc.expires_at && new Date(gc.expires_at as string) < new Date()) {
    await pool.query("UPDATE gift_cards SET status = 'expired' WHERE code = $1", [code]);
    throw new AppError(400, 'Gift card has expired');
  }

  res.json({ code, remainingAmount: gc.remaining_amount, status: gc.status });
});

// GET /gift-cards/mine
router.get('/mine', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const result = await pool.query(
    'SELECT * FROM gift_cards WHERE owner_uid = $1 ORDER BY created_at DESC',
    [req.uid],
  );
  res.json({ giftCards: result.rows });
});

export default router;
