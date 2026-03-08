'use client';

import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";
import { useState } from "react";
import { Package, Truck, CheckCircle } from "lucide-react";

export default function TrackOrderPage() {
    const [orderId, setOrderId] = useState('');
    const [email, setEmail] = useState('');
    const [result, setResult] = useState<null | 'found' | 'notfound'>(null);

    const handleTrack = () => {
        if (orderId.startsWith('AUR') && email.includes('@')) {
            setResult('found');
        } else {
            setResult('notfound');
        }
    };

    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[700px] mx-auto px-4 sm:px-6 pt-32 pb-20">
                <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-10 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back
                </Link>
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7 }}>
                    <h1 className="font-playfair text-5xl md:text-6xl text-brand-dark mb-4">Track Your Order</h1>
                    <p className="font-outfit text-brand-dark/50 mb-12">Enter your order ID and email to see the latest status of your delivery.</p>
                    <div className="space-y-5 mb-6">
                        <div>
                            <label className="font-outfit text-xs tracking-widest uppercase text-brand-dark/50 block mb-2">Order ID</label>
                            <input value={orderId} onChange={e => setOrderId(e.target.value)} placeholder="e.g. AUR123456"
                                className="w-full border-b border-brand-dark/20 bg-transparent py-3 font-outfit text-base focus:outline-none focus:border-brand-dark transition-colors" />
                        </div>
                        <div>
                            <label className="font-outfit text-xs tracking-widest uppercase text-brand-dark/50 block mb-2">Email Address</label>
                            <input value={email} onChange={e => setEmail(e.target.value)} placeholder="your@email.com" type="email"
                                className="w-full border-b border-brand-dark/20 bg-transparent py-3 font-outfit text-base focus:outline-none focus:border-brand-dark transition-colors" />
                        </div>
                        <button onClick={handleTrack} className="w-full bg-brand-dark text-brand-light py-4 font-outfit font-bold tracking-widest uppercase hover:bg-brand-accent transition-colors">
                            Track Order
                        </button>
                    </div>
                    {result === 'found' && (
                        <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} className="border border-brand-dark/10 bg-white p-6">
                            <h3 className="font-playfair text-2xl text-brand-dark mb-6">Order {orderId}</h3>
                            <div className="flex items-center gap-0">
                                {[{ icon: CheckCircle, label: 'Confirmed', done: true }, { icon: Package, label: 'Packed', done: true }, { icon: Truck, label: 'Shipped', done: false }].map((s, i, arr) => (
                                    <div key={i} className="flex items-center">
                                        <div className="flex flex-col items-center">
                                            <div className={`w-10 h-10 rounded-full flex items-center justify-center border-2 ${s.done ? 'bg-green-500 border-green-500' : 'border-brand-dark/20'}`}>
                                                <s.icon className={`w-5 h-5 ${s.done ? 'text-white' : 'text-brand-dark/30'}`} />
                                            </div>
                                            <p className={`font-outfit text-xs mt-2 text-center ${s.done ? 'text-brand-dark' : 'text-brand-dark/30'}`}>{s.label}</p>
                                        </div>
                                        {i < arr.length - 1 && <div className={`w-16 h-px mb-5 mx-2 ${s.done ? 'bg-green-400' : 'bg-brand-dark/10'}`} />}
                                    </div>
                                ))}
                            </div>
                            <p className="font-outfit text-sm text-brand-dark/60 mt-6 italic">Expected delivery: 2-4 business days via Delhivery.</p>
                        </motion.div>
                    )}
                    {result === 'notfound' && (
                        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="border border-red-200 bg-red-50 p-5">
                            <p className="font-outfit text-sm text-red-600">No order found with that ID and email. Please double-check and try again, or <Link href="/contact" className="underline">contact us</Link>.</p>
                        </motion.div>
                    )}
                </motion.div>
            </div>
            <Footer />
        </div>
    );
}
