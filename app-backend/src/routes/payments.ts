import { Router, Request, Response } from 'express';
import { z } from 'zod';
import https from 'https';
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

// POST /payments/create-order
router.post('/create-order', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const parsed = CreatePaymentSchema.safeParse(req.body);
  if (!parsed.success) throw new AppError(400, parsed.error.issues[0]?.message ?? 'Invalid body');

  const { orderId, customerName, customerPhone, customerEmail } = parsed.data;

  const orderRes = await pool.query('SELECT * FROM orders WHERE id = $1', [orderId]);
  if (orderRes.rows.length === 0) throw new AppError(404, 'Order not found');
  const order = orderRes.rows[0];
  if (order.user_uid !== req.uid) throw new AppError(403, 'Forbidden');

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
router.post('/webhook', async (req: Request, res: Response) => {
  const event = req.body as {
    type: string;
    data: {
      order: { order_id: string; order_status: string };
      payment: { cf_payment_id: string };
    };
  };

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
  const cfRes = await cashfreeRequest('GET', `/orders/${req.params['cashfreeOrderId']}`, null);
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
