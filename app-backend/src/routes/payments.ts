import { Router, Request, Response } from 'express';
import { z } from 'zod';
import https from 'https';
import admin from 'firebase-admin';
import { db } from '../config/firebase';
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

  const orderSnap = await db.collection('orders').doc(orderId).get();
  if (!orderSnap.exists) throw new AppError(404, 'Order not found');
  const order = orderSnap.data()!;
  if (order['userId'] !== req.uid) throw new AppError(403, 'Forbidden');

  const phone = customerPhone.replace(/\D/g, '');
  const phone10 = phone.length > 10 ? phone.slice(-10) : phone;
  const cfOrderId = `AUR_${orderId}_${Date.now()}`;

  const payload = JSON.stringify({
    order_id: cfOrderId,
    order_amount: parseFloat((order['total'] as number).toFixed(2)),
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

  const cfRes = await cashfreeRequest('POST', '/orders', payload);

  await db.collection('orders').doc(orderId).update({
    cashfreeOrderId: cfOrderId,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  res.json({
    paymentSessionId: (cfRes as Record<string, unknown>)['payment_session_id'],
    cashfreeOrderId: cfOrderId,
    mode: env.cashfree.env,
  });
});

// POST /payments/webhook — Cashfree webhook
router.post('/webhook', async (req: Request, res: Response) => {
  const event = req.body as {
    type: string;
    data: {
      order: { order_id: string; order_status: string };
      payment: { cf_payment_id: string };
    };
  };

  if (event.type === 'PAYMENT_SUCCESS_WEBHOOK') {
    const cfOrderId: string = event.data.order.order_id;
    const cfPaymentId: string = event.data.payment.cf_payment_id;

    const snap = await db.collection('orders')
      .where('cashfreeOrderId', '==', cfOrderId)
      .limit(1)
      .get();

    if (!snap.empty) {
      const docRef = snap.docs[0]!.ref;
      const orderData = snap.docs[0]!.data();

      await docRef.update({
        status: 'confirmed',
        cashfreePaymentId: cfPaymentId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      const giftCardCode: string | null = orderData['giftCardCode'] ?? null;
      const giftCardDiscount: number = orderData['giftCardDiscount'] ?? 0;
      if (giftCardCode && giftCardDiscount > 0) {
        const gcRef = db.collection('giftCards').doc(giftCardCode);
        await db.runTransaction(async t => {
          const gcSnap = await t.get(gcRef);
          const remaining = (gcSnap.data()?.remainingAmount ?? 0) - giftCardDiscount;
          t.update(gcRef, {
            remainingAmount: Math.max(0, remaining),
            status: remaining <= 0 ? 'used' : 'active',
          });
        });
      }

      await db.collection('carts').doc(orderData['userId'] as string).set({
        userId: orderData['userId'],
        items: [],
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }

  if (event.type === 'PAYMENT_FAILED_WEBHOOK') {
    const cfOrderId: string = event.data.order.order_id;
    const snap = await db.collection('orders')
      .where('cashfreeOrderId', '==', cfOrderId)
      .limit(1)
      .get();
    if (!snap.empty) {
      await snap.docs[0]!.ref.update({
        status: 'payment_failed',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  }

  res.status(200).json({ received: true });
});

// GET /payments/verify/:cashfreeOrderId
router.get('/verify/:cashfreeOrderId', requireAuth, async (req: AuthenticatedRequest, res: Response) => {
  const { cashfreeOrderId } = req.params as { cashfreeOrderId: string };
  const cfRes = await cashfreeRequest('GET', `/orders/${cashfreeOrderId}`, null);
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
          resolve(JSON.parse(data));
        } catch {
          reject(new Error('Invalid JSON from Cashfree'));
        }
      });
    });

    request.on('error', reject);
    if (body) request.write(body);
    request.end();
  });
}

export default router;
