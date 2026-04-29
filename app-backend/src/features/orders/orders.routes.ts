import { Router, Request, Response } from 'express';
import { z } from 'zod';
import { db } from '../../config/firebase';
import { requireAuth } from '../../middleware/auth';
import { AppError } from '../../middleware/errorHandler';
import { AuthenticatedRequest, OrderStatus } from '../../types';
import admin from 'firebase-admin';

const router = Router();

const AddressSchema = z.object({
  name: z.string().min(1),
  phone: z.string().min(10),
  line1: z.string().min(1),
  city: z.string().min(1),
  pincode: z.string().length(6),
});

const OrderItemSchema = z.object({
  productId: z.string(),
  productName: z.string(),
  brandName: z.string(),
  price: z.number().positive(),
  quantity: z.number().int().min(1),
  imageUrl: z.string().optional(),
});

const CreateOrderSchema = z.object({
  items: z.array(OrderItemSchema).min(1),
  address: AddressSchema,
  isExpress: z.boolean().default(false),
  giftCardCode: z.string().optional(),
});

// POST /orders — create a new order (sets status = payment_pending)
router.post('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = CreateOrderSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { items, address, isExpress, giftCardCode } = parsed.data;

  const subtotal = items.reduce((sum, i) => sum + i.price * i.quantity, 0);
  const deliveryFee = isExpress ? 0 : 49;

  let giftCardDiscount = 0;
  if (giftCardCode) {
    const gcSnap = await db.collection('giftCards').doc(giftCardCode).get();
    if (!gcSnap.exists) throw new AppError(400, 'Invalid gift card code');
    const gc = gcSnap.data()!;
    if (gc['status'] !== 'active') throw new AppError(400, 'Gift card is not active');
    giftCardDiscount = Math.min(gc['remainingAmount'] as number, subtotal + deliveryFee);
  }

  const total = Math.max(0, subtotal + deliveryFee - giftCardDiscount);

  const orderRef = db.collection('orders').doc();
  const order = {
    id: orderRef.id,
    userId: req.uid,
    items,
    address,
    subtotal,
    deliveryFee,
    giftCardCode: giftCardCode ?? null,
    giftCardDiscount,
    total,
    isExpress,
    status: 'payment_pending' as OrderStatus,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await orderRef.set(order);
  res.status(201).json({ orderId: orderRef.id, total });
});

// GET /orders — list orders for authenticated user
router.get('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const snap = await db.collection('orders')
    .where('userId', '==', req.uid)
    .orderBy('createdAt', 'desc')
    .limit(50)
    .get();

  res.json({ orders: snap.docs.map(d => ({ id: d.id, ...d.data() })) });
});

// GET /orders/:id — single order
router.get('/:id', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const snap = await db.collection('orders').doc(req.params['id']!).get();
  if (!snap.exists) throw new AppError(404, 'Order not found');

  const order = snap.data()!;
  if (order['userId'] !== req.uid) throw new AppError(403, 'Forbidden');

  res.json({ id: snap.id, ...order });
});

// POST /orders/:id/cancel — cancel order if still pending
router.post('/:id/cancel', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const ref = db.collection('orders').doc(req.params['id']!);
  const snap = await ref.get();
  if (!snap.exists) throw new AppError(404, 'Order not found');

  const order = snap.data()!;
  if (order['userId'] !== req.uid) throw new AppError(403, 'Forbidden');
  if (!['pending', 'payment_pending', 'confirmed'].includes(order['status'] as string)) {
    throw new AppError(400, 'Order cannot be cancelled at this stage');
  }

  await ref.update({
    status: 'cancelled',
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  res.json({ cancelled: true });
});

// ── Admin-only: PATCH /orders/:id/status ─────────────────────────────────────
// Protected by a simple admin UID list — replace with custom claims for production
const ADMIN_UIDS = (process.env['ADMIN_UIDS'] ?? '').split(',').filter(Boolean);

router.patch('/:id/status', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  if (!ADMIN_UIDS.includes(req.uid)) throw new AppError(403, 'Admin only');

  const { status } = req.body as { status: OrderStatus };
  const validStatuses: OrderStatus[] = [
    'pending', 'payment_pending', 'payment_failed', 'confirmed',
    'processing', 'shipped', 'delivered', 'cancelled',
  ];
  if (!validStatuses.includes(status)) throw new AppError(400, 'Invalid status');

  await db.collection('orders').doc(req.params['id']!).update({
    status,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  res.json({ updated: true });
});

export default router;
