import { prisma } from '@/lib/prisma';
import { PackageOpen, DollarSign, TrendingUp } from 'lucide-react';
import Link from 'next/link';

export default async function AdminDashboard() {
  const totalProducts = await prisma.product.count();
  
  // Aggregate could also get total inventory value, but let's keep it simple
  const products = await prisma.product.findMany({
    select: { price: true, quantity: true },
  });

  const totalValue = products.reduce((acc, curr) => acc + (curr.price * curr.quantity), 0);
  const totalQuantity = products.reduce((acc, curr) => acc + curr.quantity, 0);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold tracking-tight">Overview</h1>
        <Link 
          href="/admin/products/new"
          className="px-4 py-2 bg-white text-black font-semibold rounded-lg hover:bg-neutral-200 transition-colors"
        >
          Add Product
        </Link>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-neutral-900 border border-neutral-800 rounded-xl p-6">
          <div className="flex items-center gap-4">
            <div className="p-3 bg-indigo-500/10 rounded-lg">
              <PackageOpen className="w-6 h-6 text-indigo-400" />
            </div>
            <div>
              <p className="text-sm font-medium text-neutral-400">Total Products</p>
              <h3 className="text-2xl font-bold mt-1">{totalProducts}</h3>
            </div>
          </div>
        </div>

        <div className="bg-neutral-900 border border-neutral-800 rounded-xl p-6">
          <div className="flex items-center gap-4">
            <div className="p-3 bg-emerald-500/10 rounded-lg">
              <DollarSign className="w-6 h-6 text-emerald-400" />
            </div>
            <div>
              <p className="text-sm font-medium text-neutral-400">Inventory Value</p>
              <h3 className="text-2xl font-bold mt-1">${totalValue.toFixed(2)}</h3>
            </div>
          </div>
        </div>

        <div className="bg-neutral-900 border border-neutral-800 rounded-xl p-6">
          <div className="flex items-center gap-4">
            <div className="p-3 bg-amber-500/10 rounded-lg">
              <TrendingUp className="w-6 h-6 text-amber-400" />
            </div>
            <div>
              <p className="text-sm font-medium text-neutral-400">Total Units</p>
              <h3 className="text-2xl font-bold mt-1">{totalQuantity}</h3>
            </div>
          </div>
        </div>
      </div>
      
      <div className="mt-8 bg-neutral-900 border border-neutral-800 rounded-xl p-6">
        <h2 className="text-lg font-semibold mb-4">Quick Insights</h2>
        <p className="text-neutral-400">The dashboard overview provides a quick glance at your product inventory. Navigate to the Products tab to manage individual items.</p>
      </div>
    </div>
  );
}
