'use client';

import Link from 'next/link';
import { ShoppingBag, User, Menu, X, Search } from 'lucide-react';
import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useCart } from '@/context/CartContext';
import { usePathname } from 'next/navigation';

const navLinks = [
    { label: 'Shop', href: '/shop' },
    { label: 'Collections', href: '/collections' },
    { label: 'Gifting', href: '/gifting' },
    { label: 'Our Story', href: '/story' },
];

export default function Navigation() {
    const [mobileOpen, setMobileOpen] = useState(false);
    const { totalItems } = useCart();
    const pathname = usePathname();
    const isHome = pathname === '/';

    return (
        <>
            <nav className={`fixed w-full z-50 px-4 sm:px-6 py-4 flex justify-between items-center backdrop-blur-md border-b transition-colors ${isHome ? 'bg-transparent border-white/5' : 'bg-brand-light/95 border-brand-dark/5'
                }`}>
                {/* Left */}
                <div className="flex items-center gap-3 md:gap-6">
                    <button onClick={() => setMobileOpen(true)} className={isHome ? 'text-white' : 'text-brand-dark'}>
                        <Menu className="w-5 h-5" />
                    </button>
                    <div className="hidden md:flex gap-6 font-outfit text-xs uppercase tracking-widest">
                        {navLinks.map(link => (
                            <Link key={link.href} href={link.href}
                                className={`hover:text-brand-accent transition-colors ${pathname === link.href ? 'text-brand-accent' : isHome ? 'text-white/80' : 'text-brand-dark'
                                    }`}>
                                {link.label}
                            </Link>
                        ))}
                    </div>
                </div>

                {/* Centre — Brand */}
                <Link href="/" className={`font-playfair text-xl md:text-2xl font-bold tracking-[0.25em] uppercase absolute left-1/2 -translate-x-1/2 whitespace-nowrap transition-colors ${isHome ? 'text-white' : 'text-brand-dark'
                    }`}>
                    Auramika
                </Link>

                {/* Right */}
                <div className="flex items-center gap-3 md:gap-5">
                    <Link href="/shop"><Search className={`w-4 h-4 cursor-pointer hidden md:block transition-colors hover:text-brand-accent ${isHome ? 'text-white/80' : 'text-brand-dark'}`} /></Link>
                    <Link href="/account"><User className={`w-4 h-4 cursor-pointer hidden md:block transition-colors hover:text-brand-accent ${isHome ? 'text-white/80' : 'text-brand-dark'}`} /></Link>
                    <Link href="/cart" className="relative">
                        <ShoppingBag className={`w-5 h-5 transition-colors hover:text-brand-accent ${isHome ? 'text-white' : 'text-brand-dark'}`} />
                        {totalItems > 0 && (
                            <motion.span
                                key={totalItems}
                                initial={{ scale: 0.5 }}
                                animate={{ scale: 1 }}
                                className="absolute -top-2 -right-2 bg-brand-accent text-white font-bold text-[9px] w-4 h-4 rounded-full flex items-center justify-center leading-none"
                            >
                                {totalItems > 9 ? '9+' : totalItems}
                            </motion.span>
                        )}
                    </Link>
                </div>
            </nav>

            {/* Mobile Drawer */}
            <AnimatePresence>
                {mobileOpen && (
                    <>
                        <motion.div key="backdrop" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} transition={{ duration: 0.2 }}
                            onClick={() => setMobileOpen(false)} className="fixed inset-0 z-[60] bg-brand-dark/60 backdrop-blur-sm" />
                        <motion.div key="drawer" initial={{ x: '-100%' }} animate={{ x: 0 }} exit={{ x: '-100%' }}
                            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
                            className="fixed top-0 left-0 z-[70] h-full w-[80vw] max-w-xs bg-brand-light flex flex-col">
                            <div className="flex items-center justify-between px-6 py-6 border-b border-brand-dark/10">
                                <Link href="/" onClick={() => setMobileOpen(false)} className="font-playfair text-xl tracking-[0.2em] text-brand-dark uppercase">Auramika</Link>
                                <button onClick={() => setMobileOpen(false)}><X className="w-5 h-5 text-brand-dark" /></button>
                            </div>
                            <nav className="flex flex-col gap-1 p-6 flex-1 overflow-y-auto">
                                {navLinks.map((link, i) => (
                                    <motion.div key={link.href} initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: i * 0.07 }}>
                                        <Link href={link.href} onClick={() => setMobileOpen(false)}
                                            className={`font-outfit text-xl tracking-widest uppercase py-4 border-b border-brand-dark/10 block hover:text-brand-accent transition-colors ${pathname === link.href ? 'text-brand-accent' : 'text-brand-dark'}`}>
                                            {link.label}
                                        </Link>
                                    </motion.div>
                                ))}
                                <div className="mt-6 pt-6 border-t border-brand-dark/10 space-y-4">
                                    <Link href="/track-order" onClick={() => setMobileOpen(false)} className="font-outfit text-sm text-brand-dark/60 block hover:text-brand-accent transition-colors">Track Order</Link>
                                    <Link href="/faqs" onClick={() => setMobileOpen(false)} className="font-outfit text-sm text-brand-dark/60 block hover:text-brand-accent transition-colors">FAQs</Link>
                                    <Link href="/contact" onClick={() => setMobileOpen(false)} className="font-outfit text-sm text-brand-dark/60 block hover:text-brand-accent transition-colors">Contact</Link>
                                </div>
                            </nav>
                            <div className="p-6 border-t border-brand-dark/10 flex gap-4">
                                <Link href="/account" onClick={() => setMobileOpen(false)}><User className="w-5 h-5 text-brand-dark" /></Link>
                                <Link href="/cart" onClick={() => setMobileOpen(false)} className="relative">
                                    <ShoppingBag className="w-5 h-5 text-brand-dark" />
                                    {totalItems > 0 && <span className="absolute -top-2 -right-2 bg-brand-accent text-white text-[9px] w-4 h-4 rounded-full flex items-center justify-center font-bold">{totalItems}</span>}
                                </Link>
                            </div>
                        </motion.div>
                    </>
                )}
            </AnimatePresence>
        </>
    );
}
