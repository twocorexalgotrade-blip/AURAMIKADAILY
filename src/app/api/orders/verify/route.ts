import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

const CASHFREE_API_URL =
  process.env.NEXT_PUBLIC_CASHFREE_ENV === 'production'
    ? 'https://api.cashfree.com/pg'
    : 'https://sandbox.cashfree.com/pg';

export async function POST(request: NextRequest) {
  try {
    const { orderId } = await request.json();

    if (!orderId) {
      return NextResponse.json({ error: 'Order ID required' }, { status: 400 });
    }

    // Verify with Cashfree
    const cfResponse = await fetch(`${CASHFREE_API_URL}/orders/${orderId}`, {
      headers: {
        'x-client-id': process.env.CASHFREE_APP_ID!,
        'x-client-secret': process.env.CASHFREE_SECRET_KEY!,
        'x-api-version': '2023-08-01',
      },
    });

    if (!cfResponse.ok) {
      return NextResponse.json({ error: 'Failed to verify payment' }, { status: 502 });
    }

    const cfOrder = await cfResponse.json();

    // Map Cashfree status to our status
    const statusMap: Record<string, string> = {
      PAID: 'PAID',
      ACTIVE: 'PENDING',
      EXPIRED: 'FAILED',
      CANCELLED: 'FAILED',
    };
    const newStatus = statusMap[cfOrder.order_status] || 'PENDING';

    // Update DB
    const updated = await prisma.order.update({
      where: { cashfreeOrderId: orderId },
      data: { status: newStatus },
    });

    return NextResponse.json({ status: updated.status, order: updated });
  } catch (error) {
    console.error('Payment verify error:', error);
    return NextResponse.json({ error: 'Verification failed' }, { status: 500 });
  }
}
