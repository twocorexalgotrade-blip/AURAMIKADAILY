import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

const CASHFREE_API_URL =
  process.env.NEXT_PUBLIC_CASHFREE_ENV === 'production'
    ? 'https://api.cashfree.com/pg'
    : 'https://sandbox.cashfree.com/pg';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { customer, cart, subtotal, deliveryFee, total } = body;

    if (!customer || !cart?.length) {
      return NextResponse.json({ error: 'Invalid order data' }, { status: 400 });
    }

    // Generate a unique order ID for Cashfree
    const orderId = `AUR_${Date.now()}_${Math.random().toString(36).slice(2, 7).toUpperCase()}`;

    // Call Cashfree Create Order API
    const cfResponse = await fetch(`${CASHFREE_API_URL}/orders`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-client-id': process.env.CASHFREE_APP_ID!,
        'x-client-secret': process.env.CASHFREE_SECRET_KEY!,
        'x-api-version': '2023-08-01',
      },
      body: JSON.stringify({
        order_id: orderId,
        order_amount: total,
        order_currency: 'INR',
        customer_details: {
          customer_id: `CUST_${Date.now()}`,
          customer_name: customer.name,
          customer_email: customer.email,
          customer_phone: customer.phone,
        },
        order_meta: {
          return_url: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://auramikadaily.onrender.com'}/order-success?order_id=${orderId}`,
          notify_url: `${process.env.NEXT_PUBLIC_SITE_URL || 'https://auramikadaily.onrender.com'}/api/cashfree/webhook`,
        },
      }),
    });

    if (!cfResponse.ok) {
      const cfError = await cfResponse.json();
      console.error('Cashfree error:', cfError);
      return NextResponse.json({ error: 'Payment gateway error' }, { status: 502 });
    }

    const cfData = await cfResponse.json();

    // Save the order to DB with PENDING status
    await prisma.order.create({
      data: {
        cashfreeOrderId: orderId,
        status: 'PENDING',
        customerName: customer.name,
        customerEmail: customer.email,
        customerPhone: customer.phone,
        address: customer.address,
        city: customer.city,
        state: customer.state,
        pincode: customer.pincode,
        subtotal,
        deliveryFee,
        total,
        items: {
          create: cart.map((item: { name: string; price: number; quantity: number; image: string }) => ({
            productName: item.name,
            price: item.price,
            quantity: item.quantity,
            image: item.image,
          })),
        },
      },
    });

    return NextResponse.json({
      orderId,
      paymentSessionId: cfData.payment_session_id,
    });
  } catch (error) {
    console.error('Order creation error:', error);
    return NextResponse.json({ error: 'Failed to create order' }, { status: 500 });
  }
}
