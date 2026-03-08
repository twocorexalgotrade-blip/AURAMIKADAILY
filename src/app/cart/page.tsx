'use client';

import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { useCart } from "@/context/CartContext";
import { motion, AnimatePresence } from "framer-motion";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ChevronLeft, Trash2, Plus, Minus, ShoppingBag, Tag } from "lucide-react";
import { useState } from "react";

export default function CartPage() {
    const { cart, removeFromCart, updateQty, subtotal, clearCart } = useCart();
    const router = useRouter();
    const [coupon, setCoupon] = useState('');
    const [discount, setDiscount] = useState(0);
    const [couponMsg, setCouponMsg] = useState('');

    const COUPON_CODES: Record<string, number> = { 'AURAMIKA10': 10, 'FIRST20': 20, 'LUXE15': 15 };

    const applyCoupon = () => {
        const pct = COUPON_CODES[coupon.toUpperCase()];
        if (pct) { setDiscount(pct); setCouponMsg(`✓ ${pct}% discount applied!`); }
        else { setDiscount(0); setCouponMsg('Invalid coupon code.'); }
    };

    const discountAmount = Math.round(subtotal * discount / 100);
    const deliveryFee = subtotal > 999 ? 0 : 99;
    const total = subtotal - discountAmount + deliveryFee;

    if (cart.length === 0) {
        return (
            <div className="min-h-screen bg-brand-light flex flex-col">
                <Navigation />
                <div className="flex-1 flex flex-col items-center justify-center px-6 text-center pt-20">
                    <ShoppingBag className="w-16 h-16 text-brand-dark/20 mb-6" />
                    <h2 className="font-playfair text-4xl text-brand-dark mb-4">Your bag is empty</h2>
                    <p className="font-outfit text-brand-dark/50 mb-8">Looks like you haven't added anything yet.</p>
                    <Link href="/shop" className="font-outfit uppercase tracking-widest text-sm bg-brand-dark text-brand-light px-10 py-4 hover:bg-brand-accent transition-colors">
                        Start Shopping
                    </Link>
                </div>
                <Footer />
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[1200px] mx-auto px-4 sm:px-6 pt-28 pb-16">
                <button onClick={() => router.back()} className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-8 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Continue Shopping
                </button>
                <h1 className="font-playfair text-4xl md:text-6xl text-brand-dark mb-12">Your Bag</h1>

                <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
                    {/* Line Items */}
                    <div className="lg:col-span-2 space-y-6">
                        <AnimatePresence>
                            {cart.map(item => (
                                <motion.div key={item.id} initial={{ opacity: 1 }} exit={{ opacity: 0, x: -20 }} transition={{ duration: 0.3 }}
                                    className="flex gap-5 p-4 bg-white border border-brand-dark/8">
                                    <Link href={`/product/${item.slug}`}>
                                        <div className="w-24 h-24 flex-shrink-0 overflow-hidden bg-brand-dark/5">
                                            <img src={item.image} alt={item.name} className="w-full h-full object-cover" />
                                        </div>
                                    </Link>
                                    <div className="flex-1 min-w-0">
                                        <div className="flex justify-between items-start mb-1">
                                            <h3 className="font-outfit font-medium text-brand-dark leading-tight pr-2">{item.name}</h3>
                                            <button onClick={() => removeFromCart(item.id)} className="text-brand-dark/30 hover:text-red-500 transition-colors flex-shrink-0 ml-2">
                                                <Trash2 className="w-4 h-4" />
                                            </button>
                                        </div>
                                        <p className="font-outfit text-xs text-brand-dark/40 mb-3">{item.category}</p>
                                        <div className="flex items-center justify-between">
                                            <div className="flex items-center border border-brand-dark/20">
                                                <button onClick={() => item.quantity === 1 ? removeFromCart(item.id) : updateQty(item.id, item.quantity - 1)} className="px-3 py-1.5 hover:bg-brand-dark/5 transition-colors"><Minus className="w-3 h-3" /></button>
                                                <span className="font-outfit text-sm px-3 py-1.5 border-x border-brand-dark/20 min-w-[40px] text-center">{item.quantity}</span>
                                                <button onClick={() => updateQty(item.id, item.quantity + 1)} className="px-3 py-1.5 hover:bg-brand-dark/5 transition-colors"><Plus className="w-3 h-3" /></button>
                                            </div>
                                            <span className="font-outfit font-semibold text-brand-dark">₹ {(item.price * item.quantity).toLocaleString('en-IN')}</span>
                                        </div>
                                    </div>
                                </motion.div>
                            ))}
                        </AnimatePresence>
                    </div>

                    {/* Order Summary */}
                    <div className="lg:col-span-1">
                        <div className="bg-white border border-brand-dark/8 p-6 lg:sticky lg:top-28">
                            <h2 className="font-playfair text-2xl text-brand-dark mb-6">Order Summary</h2>

                            {/* Coupon */}
                            <div className="mb-6">
                                <div className="flex items-center gap-2 mb-2">
                                    <Tag className="w-4 h-4 text-brand-accent" />
                                    <span className="font-outfit text-xs tracking-widest uppercase text-brand-dark/50">Coupon code</span>
                                </div>
                                <div className="flex gap-2">
                                    <input value={coupon} onChange={e => setCoupon(e.target.value)} placeholder="AURAMIKA10"
                                        className="flex-1 border-b border-brand-dark/20 bg-transparent py-2 font-outfit text-sm focus:outline-none focus:border-brand-accent transition-colors" />
                                    <button onClick={applyCoupon} className="font-outfit text-xs tracking-wider uppercase hover:text-brand-accent transition-colors">Apply</button>
                                </div>
                                {couponMsg && <p className={`mt-2 font-outfit text-xs ${discount > 0 ? 'text-green-600' : 'text-red-500'}`}>{couponMsg}</p>}
                            </div>

                            <div className="space-y-3 mb-6 pb-6 border-b border-brand-dark/10">
                                <div className="flex justify-between font-outfit text-sm text-brand-dark/70">
                                    <span>Subtotal ({cart.reduce((s, i) => s + i.quantity, 0)} items)</span>
                                    <span>₹ {subtotal.toLocaleString('en-IN')}</span>
                                </div>
                                {discountAmount > 0 && (
                                    <div className="flex justify-between font-outfit text-sm text-green-600">
                                        <span>Coupon ({discount}% off)</span>
                                        <span>- ₹ {discountAmount.toLocaleString('en-IN')}</span>
                                    </div>
                                )}
                                <div className="flex justify-between font-outfit text-sm text-brand-dark/70">
                                    <span>Delivery</span>
                                    <span>{deliveryFee === 0 ? <span className="text-green-600">FREE</span> : `₹ ${deliveryFee}`}</span>
                                </div>
                            </div>
                            <div className="flex justify-between font-playfair text-xl text-brand-dark mb-6">
                                <span>Total</span>
                                <span>₹ {total.toLocaleString('en-IN')}</span>
                            </div>
                            {deliveryFee > 0 && (
                                <p className="font-outfit text-xs text-brand-dark/40 mb-6">Add ₹ {(999 - subtotal).toLocaleString('en-IN')} more for FREE delivery.</p>
                            )}
                            <Link href="/checkout" className="block w-full bg-brand-dark text-brand-light text-center py-4 font-outfit font-bold tracking-widest uppercase hover:bg-brand-accent transition-colors">
                                Proceed to Checkout
                            </Link>
                            <Link href="/shop" className="block mt-3 text-center font-outfit text-xs tracking-widest uppercase text-brand-dark/50 hover:text-brand-dark transition-colors py-2">
                                Continue Shopping
                            </Link>
                        </div>
                    </div>
                </div>
            </div>
            <Footer />
        </div>
    );
}
