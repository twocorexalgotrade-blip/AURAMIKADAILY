import { Router, Response } from 'express';
import { z } from 'zod';
import { db } from '../../config/firebase';
import { requireAuth } from '../../middleware/auth';
import { AppError } from '../../middleware/errorHandler';
import { AuthenticatedRequest } from '../../types';

const router = Router();

// POST /gift-cards/validate — check if a code is valid and return balance
router.post('/validate', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const { code } = z.object({ code: z.string().min(1) }).parse(req.body);

  const snap = await db.collection('giftCards').doc(code).get();
  if (!snap.exists) throw new AppError(404, 'Gift card not found');

  const gc = snap.data()!;
  if (gc['status'] !== 'active') throw new AppError(400, `Gift card is ${gc['status'] as string}`);

  const expiresAt = gc['expiresAt'] as FirebaseFirestore.Timestamp | null;
  if (expiresAt && expiresAt.toDate() < new Date()) {
    await snap.ref.update({ status: 'expired' });
    throw new AppError(400, 'Gift card has expired');
  }

  res.json({
    code,
    remainingAmount: gc['remainingAmount'],
    status: gc['status'],
  });
});

// GET /gift-cards/mine — gift cards owned by the user
router.get('/mine', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const snap = await db.collection('giftCards')
    .where('ownerId', '==', req.uid)
    .orderBy('createdAt', 'desc')
    .get();

  res.json({ giftCards: snap.docs.map(d => ({ id: d.id, ...d.data() })) });
});

export default router;
