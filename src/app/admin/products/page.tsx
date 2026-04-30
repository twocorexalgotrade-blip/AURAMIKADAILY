import { prisma } from '@/lib/prisma';
import Link from 'next/link';
import { Plus, Edit2, Trash2, Package } from 'lucide-react';
import Image from 'next/image';

interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  quantity: number;
  images: string[];
  createdAt: Date;
}

export default async function AdminProducts() {
  const products: Product[] = await prisma.product.findMany({
    orderBy: { createdAt: 'desc' },
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Products</h1>
          <p className="text-neutral-400 mt-1">Manage your storefront inventory</p>
        </div>
        <Link
          href="/admin/products/new"
          className="flex items-center gap-2 px-4 py-2 bg-white text-black font-semibold rounded-lg hover:bg-neutral-200 transition-colors"
        >
          <Plus className="w-4 h-4" />
          Add Product
        </Link>
      </div>

      <div className="bg-neutral-900 border border-neutral-800 rounded-xl overflow-hidden">
        <table className="w-full text-left">
          <thead className="bg-neutral-950 border-b border-neutral-800 text-sm font-medium text-neutral-400">
            <tr>
              <th className="px-6 py-4">Product</th>
              <th className="px-6 py-4">Price</th>
              <th className="px-6 py-4">Quantity</th>
              <th className="px-6 py-4">Added On</th>
              <th className="px-6 py-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-neutral-800">
            {products.length === 0 ? (
              <tr>
                <td colSpan={5} className="px-6 py-12 text-center text-neutral-500">
                  No products found. Add your first product to get started.
                </td>
              </tr>
            ) : (
              products.map((product: Product) => (
                <tr key={product.id} className="hover:bg-neutral-800/50 transition-colors">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-4">
                      {product.images.length > 0 ? (
                        <div className="w-12 h-12 relative rounded-md overflow-hidden bg-neutral-800 flex-shrink-0">
                          <Image
                            src={product.images[0]}
                            alt={product.name}
                            fill
                            className="object-cover"
                          />
                        </div>
                      ) : (
                        <div className="w-12 h-12 bg-neutral-800 rounded-md flex items-center justify-center flex-shrink-0">
                          <Package className="w-5 h-5 text-neutral-500" />
                        </div>
                      )}
                      <div>
                        <p className="font-medium text-neutral-100 line-clamp-1">{product.name}</p>
                        <p className="text-sm text-neutral-500 line-clamp-1">{product.description}</p>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 font-medium">${product.price.toFixed(2)}</td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold ${
                        product.quantity > 10
                          ? 'bg-emerald-500/10 text-emerald-400'
                          : product.quantity > 0
                          ? 'bg-amber-500/10 text-amber-400'
                          : 'bg-red-500/10 text-red-400'
                      }`}
                    >
                      {product.quantity} in stock
                    </span>
                  </td>
                  <td className="px-6 py-4 text-sm text-neutral-400">
                    {new Date(product.createdAt).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 text-right space-x-2">
                    <button className="p-2 text-neutral-400 hover:text-white hover:bg-neutral-800 rounded-lg transition-colors">
                      <Edit2 className="w-4 h-4" />
                    </button>
                    <button className="p-2 text-red-400 hover:text-red-300 hover:bg-red-500/10 rounded-lg transition-colors">
                      <Trash2 className="w-4 h-4" />
                    </button>
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
