export const dynamic = 'force-dynamic';

import { prisma } from '@/lib/prisma';
import Link from 'next/link';
import { ShoppingBag, TrendingUp, Clock, Filter } from 'lucide-react';

const STATUS_STYLES: Record<string, string> = {
  PENDING:  'bg-yellow-500/10 text-yellow-400',
  PAID:     'bg-emerald-500/10 text-emerald-400',
  SHIPPED:  'bg-blue-500/10 text-blue-400',
  FAILED:   'bg-red-500/10 text-red-400',
  REFUNDED: 'bg-neutral-500/10 text-neutral-400',
};

// Next.js 15 requires awaiting searchParams
export default async function AdminOrders({ searchParams }: { searchParams: Promise<{ tab?: string }> }) {
  const resolvedParams = await searchParams;
  const currentTab = resolvedParams.tab || 'active';

  const orders = await prisma.order.findMany({
    orderBy: { createdAt: 'desc' },
    include: { items: true },
  });

  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);
  const todayOrders = orders.filter(o => o.createdAt >= todayStart);
  const todayRevenue = todayOrders.filter(o => o.status === 'PAID').reduce((s, o) => s + o.total, 0);
  const totalRevenue = orders.filter(o => o.status === 'PAID').reduce((s, o) => s + o.total, 0);

  // Filter based on selected tab
  const displayOrders = orders.filter(o => {
    if (currentTab === 'active') {
      return ['PAID', 'SHIPPED'].includes(o.status);
    }
    if (currentTab === 'abandoned') {
      return ['PENDING', 'FAILED'].includes(o.status);
    }
    if (currentTab === 'refunded') {
      return o.status === 'REFUNDED';
    }
    return true; // "all"
  });

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Orders</h1>
          <p className="text-neutral-400 mt-1">Track and manage customer orders</p>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        {[
          { label: 'Active Orders', value: orders.filter(o => ['PAID', 'SHIPPED'].includes(o.status)).length, icon: ShoppingBag, color: 'text-blue-400' },
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

      {/* Tabs */}
      <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-none border-b border-neutral-800">
        {[
          { id: 'active', label: 'Active (Paid/Shipped)' },
          { id: 'abandoned', label: 'Abandoned Checkouts' },
          { id: 'refunded', label: 'Refunded' },
          { id: 'all', label: 'All Orders' },
        ].map(tab => (
          <Link
            key={tab.id}
            href={`/admin/orders?tab=${tab.id}`}
            className={`px-4 py-2 text-sm font-medium whitespace-nowrap transition-colors border-b-2 -mb-[2px] ${
              currentTab === tab.id
                ? 'border-white text-white'
                : 'border-transparent text-neutral-400 hover:text-neutral-200'
            }`}
          >
            {tab.label}
          </Link>
        ))}
      </div>

      {/* Orders Table */}
      <div className="bg-neutral-900 border border-neutral-800 rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-neutral-950 border-b border-neutral-800 text-neutral-400 font-medium">
              <tr>
                <th className="px-6 py-4">Order ID</th>
                <th className="px-6 py-4">Customer</th>
                <th className="px-6 py-4">Items</th>
                <th className="px-6 py-4">Total</th>
                <th className="px-6 py-4">Status</th>
                <th className="px-6 py-4">Date</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-neutral-800">
              {displayOrders.length === 0 ? (
                <tr>
                  <td colSpan={7} className="px-6 py-12 text-center text-neutral-500 bg-neutral-900">
                    <div className="flex flex-col items-center justify-center gap-2">
                       <Filter className="w-6 h-6 mb-2 opacity-50" />
                       <p>No orders found for this filter.</p>
                       {currentTab === 'active' && <p className="text-xs">Only successful Cashfree payments appear here.</p>}
                    </div>
                  </td>
                </tr>
              ) : (
                displayOrders.map(order => (
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
                    <td className="px-6 py-4 text-neutral-400 text-xs whitespace-nowrap">
                      {new Date(order.createdAt).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <Link href={`/admin/orders/${order.id}`}
                        className="text-xs text-neutral-400 hover:text-white border border-neutral-700 hover:border-neutral-500 px-3 py-1.5 rounded-lg transition-colors whitespace-nowrap">
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
    </div>
  );
}
