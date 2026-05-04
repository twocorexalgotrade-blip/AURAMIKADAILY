import { Router, Request, Response } from 'express';
import { z } from 'zod';
import https from 'https';
import crypto from 'crypto';
import { randomUUID } from 'crypto';
import { pool } from '../config/db';
import { requireAuth } from '../middleware/auth';
import { AppError } from '../middleware/errorHandler';
import { AuthenticatedRequest } from '../types';
import { env } from '../config/env';

const router = Router();

const CreatePaymentSchema = z.object({
  orderId: z.string().min(1),
  customerName: z.string().min(1),
  customerPhone: z.string().min(10),
  customerEmail: z.string().email().optional(),
});

const StartCheckoutSchema = z.object({
  items: z.array(z.object({
    productId: z.string().min(1),
    quantity: z.number().int().min(1).max(10),
  })).min(1).max(50),
  address: z.object({
    name: z.string().min(1),
    phone: z.string().min(10),
    line1: z.string().min(1),
    city: z.string().min(1),
    pincode: z.string().length(6),
  }),
  isExpress: z.boolean().default(false),
  giftCardCode: z.string().optional(),
  customerName: z.string().min(1),
  customerPhone: z.string().min(10),
  customerEmail: z.string().email().optional(),
});

// POST /payments/start — single-shot order + Cashfree session creation.
// Saves one round trip vs. POST /orders → POST /payments/create-order.
router.post('/start', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = StartCheckoutSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { items, address, isExpress, giftCardCode, customerName, customerPhone, customerEmail } = parsed.data;

  // Hydrate prices from DB — never trust client.
  const productIds = items.map(i => i.productId);
  const productsRes = await pool.query(
    `SELECT id, product_name, brand_name, price, image_urls, in_stock
     FROM products WHERE id = ANY($1)`,
    [productIds],
  );
  const productById = new Map<string, {
    id: string; product_name: string; brand_name: string;
    price: number; image_urls: string[]; in_stock: boolean;
  }>(productsRes.rows.map(r => [r.id as string, r as never]));

  const hydrated = items.map(i => {
    const p = productById.get(i.productId);
    if (!p) throw new AppError(400, `Product not found: ${i.productId}`);
    if (!p.in_stock) throw new AppError(400, `Out of stock: ${p.product_name}`);
    return {
      productId: p.id, productName: p.product_name, brandName: p.brand_name,
      price: p.price, quantity: i.quantity, imageUrl: p.image_urls?.[0] ?? null,
    };
  });

  const subtotal = hydrated.reduce((s, i) => s + i.price * i.quantity, 0);
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

  // Insert order + items in a transaction.
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

  // Mock mode → confirm directly, no Cashfree call.
  if (env.cashfree.mock) {
    const mockCfId = `MOCK${orderId.replace(/-/g, '').slice(0, 16)}`;
    await pool.query(
      "UPDATE orders SET cashfree_order_id = $1, status = 'confirmed', updated_at = NOW() WHERE id = $2",
      [mockCfId, orderId],
    );
    await pool.query('DELETE FROM cart_items WHERE user_uid = $1', [req.uid]);
    res.json({ orderId, total, paymentSessionId: mockCfId, cashfreeOrderId: mockCfId, mode: 'MOCK', isMock: true });
    return;
  }

  // Real Cashfree flow.
  const phone = customerPhone.replace(/\D/g, '');
  const phone10 = phone.length > 10 ? phone.slice(-10) : phone;
  const cfOrderId = `AUR${orderId.replace(/-/g, '').slice(0, 20)}${Date.now().toString().slice(-10)}`;

  const payload = JSON.stringify({
    order_id: cfOrderId,
    order_amount: parseFloat(total.toFixed(2)),
    order_currency: 'INR',
    order_meta: {
      return_url: `https://auramikadaily.com/payment/return?order_id={order_id}`,
      payment_methods: 'upi,cc,dc,nb,app',
    },
    customer_details: {
      customer_id: `CUST_${req.uid.slice(0, 16)}`,
      customer_name: customerName || 'Customer',
      customer_email: customerEmail ?? 'customer@auramika.in',
      customer_phone: phone10 || '9999999999',
    },
  });

  const cfRes = await cashfreeRequest('POST', '/orders', payload) as Record<string, unknown>;
  const sessionId = cfRes['payment_session_id'] as string | undefined;
  if (!sessionId) {
    const cfErr = cfRes['message'] ?? cfRes['error'] ?? JSON.stringify(cfRes);
    console.error('[Cashfree] Missing payment_session_id. Response:', cfRes);
    throw new AppError(502, `Cashfree payment session error: ${String(cfErr)}`);
  }

  await pool.query(
    'UPDATE orders SET cashfree_order_id = $1, updated_at = NOW() WHERE id = $2',
    [cfOrderId, orderId],
  );

  res.json({
    orderId, total,
    paymentSessionId: sessionId,
    cashfreeOrderId: cfOrderId,
    mode: env.cashfree.env,
  });
});

// POST /payments/create-order
router.post('/create-order', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = CreatePaymentSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { orderId, customerName, customerPhone, customerEmail } = parsed.data;

  const orderRes = await pool.query('SELECT * FROM orders WHERE id = $1', [orderId]);
  if (orderRes.rows.length === 0) throw new AppError(404, 'Order not found');
  const order = orderRes.rows[0];
  if (order.user_uid !== req.uid) throw new AppError(403, 'Forbidden');

  // Mock mode: skip Cashfree entirely, confirm the order immediately.
  if (env.cashfree.mock) {
    const mockCfId = `MOCK${orderId.replace(/-/g, '').slice(0, 16)}`;
    await pool.query(
      "UPDATE orders SET cashfree_order_id = $1, status = 'confirmed', updated_at = NOW() WHERE id = $2",
      [mockCfId, orderId],
    );
    await pool.query('DELETE FROM cart_items WHERE user_uid = $1', [req.uid]);
    console.log('[Cashfree] Mock mode — order confirmed without payment:', orderId);
    res.json({ paymentSessionId: mockCfId, cashfreeOrderId: mockCfId, mode: 'MOCK', isMock: true });
    return;
  }

  const phone = customerPhone.replace(/\D/g, '');
  const phone10 = phone.length > 10 ? phone.slice(-10) : phone;
  // Cashfree: alphanumeric only, max 50 chars.
  // Strip UUID hyphens, take first 20 hex chars + 10-digit epoch suffix = 33 chars total.
  const cfOrderId = `AUR${orderId.replace(/-/g, '').slice(0, 20)}${Date.now().toString().slice(-10)}`;

  const payload = JSON.stringify({
    order_id: cfOrderId,
    order_amount: parseFloat((order.total as number).toFixed(2)),
    order_currency: 'INR',
    order_meta: {
      return_url: `https://auramikadaily.com/payment/return?order_id={order_id}`,
      payment_methods: 'upi,cc,dc,nb,app',
    },
    customer_details: {
      customer_id: `CUST_${req.uid.slice(0, 16)}`,
      customer_name: customerName || 'Customer',
      customer_email: customerEmail ?? 'customer@auramika.in',
      customer_phone: phone10 || '9999999999',
    },
  });

  const cfRes = await cashfreeRequest('POST', '/orders', payload) as Record<string, unknown>;
  const sessionId = cfRes['payment_session_id'] as string | undefined;
  if (!sessionId) {
    const cfErr = cfRes['message'] ?? cfRes['error'] ?? JSON.stringify(cfRes);
    console.error('[Cashfree] Missing payment_session_id. Response:', cfRes);
    throw new AppError(502, `Cashfree payment session error: ${String(cfErr)}`);
  }

  await pool.query(
    'UPDATE orders SET cashfree_order_id = $1, updated_at = NOW() WHERE id = $2',
    [cfOrderId, orderId],
  );

  res.json({
    paymentSessionId: sessionId,
    cashfreeOrderId: cfOrderId,
    mode: env.cashfree.env,
  });
});

// POST /payments/webhook
// req.body is a Buffer here because index.ts mounts express.raw() on this path
// — required so we can verify Cashfree's HMAC signature against the exact bytes.
router.post('/webhook', async (req: Request, res: Response) => {
  const rawBody = req.body as Buffer;
  if (!Buffer.isBuffer(rawBody)) throw new AppError(400, 'Invalid webhook body');

  // Mock mode (local dev) skips signature verification.
  if (!env.cashfree.mock) {
    const signature = req.header('x-webhook-signature');
    const timestamp = req.header('x-webhook-timestamp');
    if (!signature || !timestamp) throw new AppError(401, 'Missing webhook signature');

    const expected = crypto
      .createHmac('sha256', env.cashfree.secretKey)
      .update(timestamp + rawBody.toString('utf8'))
      .digest('base64');

    const sigBuf = Buffer.from(signature);
    const expBuf = Buffer.from(expected);
    if (sigBuf.length !== expBuf.length || !crypto.timingSafeEqual(sigBuf, expBuf)) {
      console.warn('[Cashfree webhook] Signature mismatch — rejecting');
      throw new AppError(401, 'Invalid webhook signature');
    }
  }

  let event: {
    type: string;
    data: {
      order: { order_id: string; order_status: string };
      payment: { cf_payment_id: string };
    };
  };
  try {
    event = JSON.parse(rawBody.toString('utf8'));
  } catch {
    throw new AppError(400, 'Invalid webhook JSON');
  }

  if (event.type === 'PAYMENT_SUCCESS_WEBHOOK') {
    const cfOrderId = event.data.order.order_id;
    const cfPaymentId = event.data.payment.cf_payment_id;

    const orderRes = await pool.query(
      'SELECT * FROM orders WHERE cashfree_order_id = $1',
      [cfOrderId],
    );

    if (orderRes.rows.length > 0) {
      const order = orderRes.rows[0];

      await pool.query(
        "UPDATE orders SET status = 'confirmed', cashfree_payment_id = $1, updated_at = NOW() WHERE id = $2",
        [cfPaymentId, order.id],
      );

      if (order.gift_card_code && order.gift_card_discount > 0) {
        const client = await pool.connect();
        try {
          await client.query('BEGIN');
          const gcRes = await client.query('SELECT remaining_amount FROM gift_cards WHERE code = $1 FOR UPDATE', [order.gift_card_code]);
          if (gcRes.rows.length > 0) {
            const remaining = Math.max(0, (gcRes.rows[0].remaining_amount as number) - (order.gift_card_discount as number));
            await client.query(
              'UPDATE gift_cards SET remaining_amount = $1, status = $2 WHERE code = $3',
              [remaining, remaining <= 0 ? 'used' : 'active', order.gift_card_code],
            );
          }
          await client.query('COMMIT');
        } catch (e) {
          await client.query('ROLLBACK');
          throw e;
        } finally {
          client.release();
        }
      }

      await pool.query('DELETE FROM cart_items WHERE user_uid = $1', [order.user_uid]);
    }
  }

  if (event.type === 'PAYMENT_FAILED_WEBHOOK') {
    const cfOrderId = event.data.order.order_id;
    await pool.query(
      "UPDATE orders SET status = 'payment_failed', updated_at = NOW() WHERE cashfree_order_id = $1",
      [cfOrderId],
    );
  }

  res.status(200).json({ received: true });
});

// GET /payments/verify/:cashfreeOrderId
router.get('/verify/:cashfreeOrderId', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const cfOrderId = req.params['cashfreeOrderId'] ?? '';
  // Ownership check — only the user who created the order can poll its status.
  const orderRes = await pool.query(
    'SELECT user_uid FROM orders WHERE cashfree_order_id = $1',
    [cfOrderId],
  );
  if (orderRes.rows.length === 0) throw new AppError(404, 'Order not found');
  if (orderRes.rows[0].user_uid !== req.uid) throw new AppError(403, 'Forbidden');

  const cfRes = await cashfreeRequest('GET', `/orders/${cfOrderId}`, null);
  res.json(cfRes);
});

function cashfreeRequest(method: string, path: string, body: string | null): Promise<unknown> {
  return new Promise((resolve, reject) => {
    const url = new URL(env.cashfree.baseUrl + path);
    const options: https.RequestOptions = {
      hostname: url.hostname,
      path: url.pathname + url.search,
      method,
      headers: {
        'x-api-version': '2023-08-01',
        'x-client-id': env.cashfree.appId,
        'x-client-secret': env.cashfree.secretKey,
        'Content-Type': 'application/json',
        ...(body ? { 'Content-Length': Buffer.byteLength(body) } : {}),
      },
    };
    const request = https.request(options, response => {
      let data = '';
      response.on('data', chunk => (data += chunk));
      response.on('end', () => {
        try {
          const parsed = JSON.parse(data) as unknown;
          if ((response.statusCode ?? 0) >= 400) {
            console.error('[Cashfree] HTTP', response.statusCode, JSON.stringify(parsed));
            reject(new AppError(502, `Cashfree HTTP ${response.statusCode}: ${JSON.stringify(parsed)}`));
          } else {
            resolve(parsed);
          }
        } catch { reject(new Error('Invalid JSON from Cashfree')); }
      });
    });
    request.on('error', reject);
    if (body) request.write(body);
    request.end();
  });
}

export default router;
