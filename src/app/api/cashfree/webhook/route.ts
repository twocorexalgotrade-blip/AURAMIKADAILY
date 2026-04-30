import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import crypto from 'crypto';

export async function POST(request: NextRequest) {
  try {
    const body = await request.text();
    const signature = request.headers.get('x-webhook-signature');
    const timestamp = request.headers.get('x-webhook-timestamp');

    // Verify webhook signature
    if (signature && timestamp && process.env.CASHFREE_SECRET_KEY) {
      const signedPayload = `${timestamp}${body}`;
      const expectedSignature = crypto
        .createHmac('sha256', process.env.CASHFREE_SECRET_KEY)
        .update(signedPayload)
        .digest('base64');

      if (signature !== expectedSignature) {
        return NextResponse.json({ error: 'Invalid signature' }, { status: 401 });
      }
    }

    const event = JSON.parse(body);
    const orderId = event?.data?.order?.order_id;
    const orderStatus = event?.data?.order?.order_status;

    if (!orderId) {
      return NextResponse.json({ received: true });
    }

    const statusMap: Record<string, string> = {
      PAID: 'PAID',
      ACTIVE: 'PENDING',
      EXPIRED: 'FAILED',
      CANCELLED: 'FAILED',
    };

    const newStatus = statusMap[orderStatus] || 'PENDING';

    await prisma.order.updateMany({
      where: { cashfreeOrderId: orderId },
      data: { status: newStatus },
    });

    return NextResponse.json({ received: true });
  } catch (error) {
    console.error('Webhook error:', error);
    return NextResponse.json({ error: 'Webhook processing failed' }, { status: 500 });
  }
}
