import { Router, Response } from 'express';
import { z } from 'zod';
import { pool } from '../config/db';
import { requireAuth } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest, OrderStatus } from '../types';
import { env } from '../config/env';
import { randomUUID } from 'crypto';

const router = Router();

const AddressSchema = z.object({
  name: z.string().min(1),
  phone: z.string().min(10),
  line1: z.string().min(1),
  city: z.string().min(1),
  pincode: z.string().length(6),
});

// Client only sends productId + quantity. Price, name, brand, and image are
// hydrated from the products table server-side — never trust client-supplied
// prices (would let a malicious user pay ₹1 for any product).
const OrderItemSchema = z.object({
  productId: z.string().min(1),
  quantity: z.number().int().min(1).max(10),
});

const CreateOrderSchema = z.object({
  items: z.array(OrderItemSchema).min(1).max(50),
  address: AddressSchema,
  isExpress: z.boolean().default(false),
  giftCardCode: z.string().optional(),
});

const VALID_STATUSES: OrderStatus[] = [
  'pending', 'payment_pending', 'payment_failed', 'confirmed',
  'processing', 'shipped', 'delivered', 'cancelled',
];

// POST /orders
router.post('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = CreateOrderSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { items, address, isExpress, giftCardCode } = parsed.data;

  // Hydrate every line from the products table — refuse if any product is
  // missing or out of stock. This is the source of truth for prices.
  const productIds = items.map(i => i.productId);
  const productsRes = await pool.query(
    `SELECT id, product_name, brand_name, price, image_urls, in_stock
     FROM products WHERE id = ANY($1)`,
    [productIds],
  );
  const productById = new Map<string, {
    id: string;
    product_name: string;
    brand_name: string;
    price: number;
    image_urls: string[];
    in_stock: boolean;
  }>(productsRes.rows.map(r => [r.id as string, r as never]));

  const hydrated = items.map(i => {
    const p = productById.get(i.productId);
    if (!p) throw new AppError(400, `Product not found: ${i.productId}`);
    if (!p.in_stock) throw new AppError(400, `Out of stock: ${p.product_name}`);
    return {
      productId: p.id,
      productName: p.product_name,
      brandName: p.brand_name,
      price: p.price,
      quantity: i.quantity,
      imageUrl: p.image_urls?.[0] ?? null,
    };
  });

  const subtotal = hydrated.reduce((sum, i) => sum + i.price * i.quantity, 0);
  const deliveryFee = isExpress ? 0 : 49;

  let giftCardDiscount = 0;
  if (giftCardCode) {
    const gcRes = await pool.query('SELECT * FROM gift_cards WHERE code = $1', [giftCardCode]);
    if (gcRes.rows.length === 0) throw new AppError(400, 'Invalid gift card code');
    const gc = gcRes.rows[0];
    if (gc.status !== 'active') throw new AppError(400, `Gift card is ${gc.status as string}`);
    if (gc.expires_at && new Date(gc.expires_at as string) < new Date()) {
      await pool.query("UPDATE gift_cards SET status = 'expired' WHERE code = $1", [giftCardCode]);
      throw new AppError(400, 'Gift card has expired');
    }
    giftCardDiscount = Math.min(gc.remaining_amount as number, subtotal + deliveryFee);
  }

  const total = Math.max(0, subtotal + deliveryFee - giftCardDiscount);
  const orderId = randomUUID();

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    await client.query(
      `INSERT INTO orders (id, user_uid, subtotal, delivery_fee, gift_card_code, gift_card_discount,
        total, is_express, status, address_name, address_phone, address_line1, address_city, address_pincode)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,'payment_pending',$9,$10,$11,$12,$13)`,
      [orderId, req.uid, subtotal, deliveryFee, giftCardCode ?? null, giftCardDiscount,
       total, isExpress, address.name, address.phone, address.line1, address.city, address.pincode],
    );

    for (const item of hydrated) {
      await client.query(
        `INSERT INTO order_items (order_id, product_id, product_name, brand_name, price, quantity, image_url)
         VALUES ($1,$2,$3,$4,$5,$6,$7)`,
        [orderId, item.productId, item.productName, item.brandName, item.price, item.quantity, item.imageUrl],
      );
    }

    await client.query('COMMIT');
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }

  res.status(201).json({ orderId, total });
});

// GET /orders
router.get('/', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const ordersRes = await pool.query(
    'SELECT * FROM orders WHERE user_uid = $1 ORDER BY created_at DESC LIMIT 50',
    [req.uid],
  );

  const orders = await Promise.all(ordersRes.rows.map(async (order) => {
    const itemsRes = await pool.query('SELECT * FROM order_items WHERE order_id = $1', [order.id]);
    return { ...order, items: itemsRes.rows };
  }));

  res.json({ orders });
});

// GET /orders/:id
router.get('/:id', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const orderRes = await pool.query('SELECT * FROM orders WHERE id = $1', [req.params['id']]);
  if (orderRes.rows.length === 0) throw new AppError(404, 'Order not found');
  const order = orderRes.rows[0];
  if (order.user_uid !== req.uid) throw new AppError(403, 'Forbidden');

  const itemsRes = await pool.query('SELECT * FROM order_items WHERE order_id = $1', [order.id]);
  res.json({ ...order, items: itemsRes.rows });
});

// POST /orders/:id/cancel
router.post('/:id/cancel', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const orderRes = await pool.query('SELECT * FROM orders WHERE id = $1', [req.params['id']]);
  if (orderRes.rows.length === 0) throw new AppError(404, 'Order not found');
  const order = orderRes.rows[0];
  if (order.user_uid !== req.uid) throw new AppError(403, 'Forbidden');
  if (!['pending', 'payment_pending', 'confirmed'].includes(order.status as string)) {
    throw new AppError(400, 'Order cannot be cancelled at this stage');
  }
  await pool.query("UPDATE orders SET status = 'cancelled', updated_at = NOW() WHERE id = $1", [req.params['id']]);
  res.json({ cancelled: true });
});

// PATCH /orders/:id/status — admin only
router.patch('/:id/status', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  if (!env.adminUids.includes(req.uid)) throw new AppError(403, 'Admin only');
  const { status } = req.body as { status: OrderStatus };
  if (!VALID_STATUSES.includes(status)) throw new AppError(400, 'Invalid status');
  await pool.query('UPDATE orders SET status = $1, updated_at = NOW() WHERE id = $2', [status, req.params['id']]);
  res.json({ updated: true });
});

export default router;
