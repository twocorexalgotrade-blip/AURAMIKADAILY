import { prisma } from '@/lib/prisma';
import Link from 'next/link';
import { ShoppingBag, TrendingUp, Clock } from 'lucide-react';

const STATUS_STYLES: Record<string, string> = {
  PENDING:  'bg-yellow-500/10 text-yellow-400',
  PAID:     'bg-emerald-500/10 text-emerald-400',
  SHIPPED:  'bg-blue-500/10 text-blue-400',
  FAILED:   'bg-red-500/10 text-red-400',
  REFUNDED: 'bg-neutral-500/10 text-neutral-400',
};

export default async function AdminOrders() {
  const orders = await prisma.order.findMany({
    orderBy: { createdAt: 'desc' },
    include: { items: true },
  });

  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);
  const todayOrders = orders.filter(o => o.createdAt >= todayStart);
  const todayRevenue = todayOrders.filter(o => o.status === 'PAID').reduce((s, o) => s + o.total, 0);
  const totalRevenue = orders.filter(o => o.status === 'PAID').reduce((s, o) => s + o.total, 0);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Orders</h1>
        <p className="text-neutral-400 mt-1">Track and manage customer orders</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {[
          { label: 'Total Orders', value: orders.length, icon: ShoppingBag, color: 'text-blue-400' },
          { label: 'Today\'s Revenue', value: `₹${todayRevenue.toLocaleString('en-IN')}`, icon: TrendingUp, color: 'text-emerald-400' },
          { label: 'Lifetime Revenue', value: `₹${totalRevenue.toLocaleString('en-IN')}`, icon: Clock, color: 'text-purple-400' },
        ].map(stat => (
          <div key={stat.label} className="bg-neutral-900 border border-neutral-800 rounded-xl p-5 flex items-center gap-4">
            <div className={`p-3 bg-neutral-800 rounded-lg ${stat.color}`}>
              <stat.icon className="w-5 h-5" />
            </div>
            <div>
              <p className="text-sm text-neutral-400">{stat.label}</p>
              <p className="text-xl font-bold">{stat.value}</p>
            </div>
          </div>
        ))}
      </div>

      {/* Orders Table */}
      <div className="bg-neutral-900 border border-neutral-800 rounded-xl overflow-hidden">
        <table className="w-full text-left text-sm">
          <thead className="bg-neutral-950 border-b border-neutral-800 text-neutral-400 font-medium">
            <tr>
              <th className="px-6 py-4">Order ID</th>
              <th className="px-6 py-4">Customer</th>
              <th className="px-6 py-4">Items</th>
              <th className="px-6 py-4">Total</th>
              <th className="px-6 py-4">Status</th>
              <th className="px-6 py-4">Date</th>
              <th className="px-6 py-4"></th>
            </tr>
          </thead>
          <tbody className="divide-y divide-neutral-800">
            {orders.length === 0 ? (
              <tr>
                <td colSpan={7} className="px-6 py-12 text-center text-neutral-500">
                  No orders yet. Orders will appear here once customers checkout.
                </td>
              </tr>
            ) : (
              orders.map(order => (
                <tr key={order.id} className="hover:bg-neutral-800/50 transition-colors">
                  <td className="px-6 py-4 font-mono text-xs text-neutral-400">
                    {order.cashfreeOrderId.slice(0, 16)}…
                  </td>
                  <td className="px-6 py-4">
                    <p className="font-medium text-neutral-100">{order.customerName}</p>
                    <p className="text-xs text-neutral-500">{order.customerEmail}</p>
                  </td>
                  <td className="px-6 py-4 text-neutral-400">
                    {order.items.length} item{order.items.length !== 1 ? 's' : ''}
                  </td>
                  <td className="px-6 py-4 font-semibold">
                    ₹{order.total.toLocaleString('en-IN')}
                  </td>
                  <td className="px-6 py-4">
                    <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold ${STATUS_STYLES[order.status] || 'bg-neutral-800 text-neutral-400'}`}>
                      {order.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-neutral-400 text-xs">
                    {new Date(order.createdAt).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}
                  </td>
                  <td className="px-6 py-4 text-right">
                    <Link href={`/admin/orders/${order.id}`}
                      className="text-xs text-neutral-400 hover:text-white border border-neutral-700 hover:border-neutral-500 px-3 py-1.5 rounded-lg transition-colors">
                      View
                    </Link>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
