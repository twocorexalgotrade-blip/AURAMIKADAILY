import { Router, Response } from 'express';
import { z } from 'zod';
import { db } from '../../config/firebase';
import { requireAuth } from '../../middleware/auth';
import { AppError } from '../../middleware/errorHandler';
import { AuthenticatedRequest, CustomOrderStatus } from '../../types';
import admin from 'firebase-admin';

const router = Router();

const CreateCustomOrderSchema = z.object({
  description: z.string().min(10).max(2000),
  budget: z.number().positive().optional(),
  imageUrls: z.array(z.string().url()).max(5).optional(),
});

// POST /custom-orders — submit a custom order request
router.post('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = CreateCustomOrderSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const ref = db.collection('customOrders').doc();
  const order = {
    id: ref.id,
    userId: req.uid,
    ...parsed.data,
    status: 'submitted' as CustomOrderStatus,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await ref.set(order);
  res.status(201).json({ id: ref.id });
});

// GET /custom-orders — list user's custom orders
router.get('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const snap = await db.collection('customOrders')
    .where('userId', '==', req.uid)
    .orderBy('createdAt', 'desc')
    .limit(20)
    .get();

  res.json({ customOrders: snap.docs.map(d => ({ id: d.id, ...d.data() })) });
});

// GET /custom-orders/:id
router.get('/:id', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const snap = await db.collection('customOrders').doc(req.params['id']!).get();
  if (!snap.exists) throw new AppError(404, 'Custom order not found');
  if (snap.data()!['userId'] !== req.uid) throw new AppError(403, 'Forbidden');
  res.json({ id: snap.id, ...snap.data() });
});

export default router;
