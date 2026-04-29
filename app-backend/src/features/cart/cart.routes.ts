import { Router, Response } from 'express';
import { z } from 'zod';
import { db } from '../../config/firebase';
import { requireAuth } from '../../middleware/auth';
import { AppError } from '../../middleware/errorHandler';
import { AuthenticatedRequest } from '../../types';
import admin from 'firebase-admin';

const router = Router();

const CartItemSchema = z.object({
  productId: z.string().min(1),
  quantity: z.number().int().min(1).max(10),
  isExpress: z.boolean().default(false),
});

// GET /cart — fetch cart for authenticated user
router.get('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const snap = await db.collection('carts').doc(req.uid).get();

  if (!snap.exists) {
    res.json({ items: [] });
    return;
  }

  const cart = snap.data();
  res.json({ items: cart?.items ?? [] });
});

// PUT /cart/items — upsert a cart item (add or update quantity)
router.put('/items', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = CartItemSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { productId, quantity, isExpress } = parsed.data;
  const cartRef = db.collection('carts').doc(req.uid);
  const snap = await cartRef.get();
  const items: Array<{ productId: string; quantity: number; isExpress: boolean }> =
    snap.data()?.items ?? [];

  const idx = items.findIndex(i => i.productId === productId);
  if (idx >= 0) {
    items[idx] = { productId, quantity, isExpress };
  } else {
    items.push({ productId, quantity, isExpress });
  }

  await cartRef.set({
    userId: req.uid,
    items,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  res.json({ items });
});

// DELETE /cart/items/:productId — remove one item
router.delete('/items/:productId', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const { productId } = req.params as { productId: string };
  const cartRef = db.collection('carts').doc(req.uid);
  const snap = await cartRef.get();
  const items: Array<{ productId: string }> = snap.data()?.items ?? [];

  await cartRef.update({
    items: items.filter(i => i.productId !== productId),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  res.json({ deleted: true });
});

// DELETE /cart — clear entire cart
router.delete('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  await db.collection('carts').doc(req.uid).set({
    userId: req.uid,
    items: [],
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  res.json({ cleared: true });
});

export default router;
