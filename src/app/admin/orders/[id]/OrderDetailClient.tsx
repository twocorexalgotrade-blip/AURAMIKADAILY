'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ChevronLeft } from 'lucide-react';
import Link from 'next/link';

const STATUS_STYLES: Record<string, string> = {
  PENDING:  'bg-yellow-500/10 text-yellow-400',
  PAID:     'bg-emerald-500/10 text-emerald-400',
  SHIPPED:  'bg-blue-500/10 text-blue-400',
  FAILED:   'bg-red-500/10 text-red-400',
  REFUNDED: 'bg-neutral-500/10 text-neutral-400',
};

const ALL_STATUSES = ['PENDING', 'PAID', 'SHIPPED', 'FAILED', 'REFUNDED'];

interface OrderItem {
  id: string;
  productName: string;
  price: number;
  quantity: number;
  image: string;
}

interface Order {
  id: string;
  cashfreeOrderId: string;
  status: string;
  customerName: string;
  customerEmail: string;
  customerPhone: string;
  address: string;
  city: string;
  state: string;
  pincode: string;
  subtotal: number;
  deliveryFee: number;
  total: number;
  items: OrderItem[];
  createdAt: string;
}

export default function OrderDetailClient({ order: initialOrder }: { order: Order }) {
  const router = useRouter();
  const [order, setOrder] = useState(initialOrder);
  const [updating, setUpdating] = useState(false);

  const updateStatus = async (status: string) => {
    setUpdating(true);
    try {
      const res = await fetch(`/api/admin/orders/${order.id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status }),
      });
      if (res.ok) {
        const updated = await res.json();
        setOrder(prev => ({ ...prev, status: updated.status }));
      }
    } finally {
      setUpdating(false);
    }
  };

  return (
    <div className="space-y-6 max-w-4xl">
      <div className="flex items-center gap-4">
        <Link href="/admin/orders" className="p-2 bg-neutral-900 border border-neutral-800 rounded-lg hover:bg-neutral-800 transition-colors">
          <ChevronLeft className="w-5 h-5" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Order Detail</h1>
          <p className="text-neutral-500 text-xs font-mono mt-0.5">{order.cashfreeOrderId}</p>
        </div>
        <span className={`ml-auto inline-flex items-center px-3 py-1.5 rounded-full text-sm font-semibold ${STATUS_STYLES[order.status] || 'bg-neutral-800 text-neutral-400'}`}>
          {order.status}
        </span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* Customer Info */}
        <div className="md:col-span-2 bg-neutral-900 border border-neutral-800 rounded-xl p-6 space-y-4">
          <h2 className="font-semibold text-sm text-neutral-400 uppercase tracking-wider">Customer</h2>
          <div className="grid grid-cols-2 gap-4 text-sm">
            <div><p className="text-neutral-500 text-xs mb-0.5">Name</p><p className="font-medium">{order.customerName}</p></div>
            <div><p className="text-neutral-500 text-xs mb-0.5">Phone</p><p className="font-medium">{order.customerPhone}</p></div>
            <div className="col-span-2"><p className="text-neutral-500 text-xs mb-0.5">Email</p><p className="font-medium">{order.customerEmail}</p></div>
            <div className="col-span-2">
              <p className="text-neutral-500 text-xs mb-0.5">Shipping Address</p>
              <p className="font-medium">{order.address}, {order.city}, {order.state} — {order.pincode}</p>
            </div>
          </div>
        </div>

        {/* Update Status */}
        <div className="bg-neutral-900 border border-neutral-800 rounded-xl p-6 space-y-3">
          <h2 className="font-semibold text-sm text-neutral-400 uppercase tracking-wider">Update Status</h2>
          <div className="space-y-2">
            {ALL_STATUSES.map(s => (
              <button
                key={s}
                onClick={() => updateStatus(s)}
                disabled={updating || s === order.status}
                className={`w-full py-2 px-3 rounded-lg text-sm font-medium transition-colors ${
                  s === order.status
                    ? 'bg-white text-black cursor-default'
                    : 'bg-neutral-800 text-neutral-300 hover:bg-neutral-700'
                } disabled:opacity-50`}
              >
                {s}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Items */}
      <div className="bg-neutral-900 border border-neutral-800 rounded-xl p-6">
        <h2 className="font-semibold text-sm text-neutral-400 uppercase tracking-wider mb-4">Items Ordered</h2>
        <div className="divide-y divide-neutral-800">
          {order.items.map(item => (
            <div key={item.id} className="flex items-center gap-4 py-4">
              <img src={item.image} alt={item.productName} className="w-14 h-14 object-cover rounded-lg bg-neutral-800" />
              <div className="flex-1">
                <p className="font-medium">{item.productName}</p>
                <p className="text-sm text-neutral-500">Qty: {item.quantity}</p>
              </div>
              <p className="font-semibold">₹{(item.price * item.quantity).toLocaleString('en-IN')}</p>
            </div>
          ))}
        </div>
        <div className="border-t border-neutral-800 mt-2 pt-4 space-y-1 text-sm">
          <div className="flex justify-between text-neutral-400"><span>Subtotal</span><span>₹{order.subtotal.toLocaleString('en-IN')}</span></div>
          <div className="flex justify-between text-neutral-400"><span>Delivery</span><span>{order.deliveryFee === 0 ? 'FREE' : `₹${order.deliveryFee}`}</span></div>
          <div className="flex justify-between text-white font-bold text-base pt-2 border-t border-neutral-800"><span>Total</span><span>₹{order.total.toLocaleString('en-IN')}</span></div>
        </div>
      </div>

      <p className="text-xs text-neutral-600">
        Placed on {new Date(order.createdAt).toLocaleString('en-IN', { day: 'numeric', month: 'long', year: 'numeric', hour: '2-digit', minute: '2-digit' })}
      </p>
    </div>
  );
}
