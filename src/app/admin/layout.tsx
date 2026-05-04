import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import Link from 'next/link';
import { LayoutDashboard, Package, ShoppingBag, Store, LogOut } from 'lucide-react';

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const cookieStore = await cookies();
  const token = cookieStore.get('admin_token');
  if (!token || token.value !== process.env.ADMIN_PASSWORD) {
    redirect('/login');
  }

  return (
    <div className="flex h-screen bg-neutral-950 text-neutral-100">
      <aside className="w-64 border-r border-neutral-800 bg-neutral-950 flex flex-col">
        <div className="h-16 flex items-center px-6 border-b border-neutral-800 font-bold text-xl tracking-wider uppercase text-white">
          AuraMika Admin
        </div>
        <nav className="flex-1 px-4 py-6 space-y-1">
          <Link href="/admin" className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-neutral-400 hover:text-white hover:bg-neutral-900 transition-colors">
            <LayoutDashboard className="w-5 h-5" /> Dashboard
          </Link>
          <Link href="/admin/products" className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-neutral-400 hover:text-white hover:bg-neutral-900 transition-colors">
            <Package className="w-5 h-5" /> Products
          </Link>
          <Link href="/admin/orders" className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-neutral-400 hover:text-white hover:bg-neutral-900 transition-colors">
            <ShoppingBag className="w-5 h-5" /> Orders
          </Link>
          <Link href="/admin/vendors" className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-neutral-400 hover:text-white hover:bg-neutral-900 transition-colors">
            <Store className="w-5 h-5" /> Vendors
          </Link>
        </nav>
        <div className="p-4 border-t border-neutral-800">
          <form action="/api/admin/logout" method="POST">
            <button type="submit" className="flex items-center gap-3 px-3 py-2.5 w-full rounded-lg text-red-400 hover:text-red-300 hover:bg-red-500/10 transition-colors">
              <LogOut className="w-5 h-5" /> Sign Out
            </button>
          </form>
        </div>
      </aside>
      <main className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <header className="h-16 border-b border-neutral-800 bg-neutral-950 flex items-center px-8 flex-shrink-0">
          <h2 className="text-sm font-medium text-neutral-400">Admin Portal</h2>
        </header>
        <div className="flex-1 overflow-auto p-8 bg-neutral-900/20">
          {children}
        </div>
      </main>
    </div>
  );
}
