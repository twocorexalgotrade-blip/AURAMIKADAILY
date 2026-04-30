'use client';

import Link from "next/link";
import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { CheckCircle, Package, Truck, Star } from "lucide-react";

export default function OrderSuccessPage() {
    const [orderId] = useState(() => 'AUR' + Math.floor(Math.random() * 900000 + 100000));

    const steps = [
        { icon: CheckCircle, label: 'Order Confirmed', done: true },
        { icon: Package, label: 'Packing', done: false },
        { icon: Truck, label: 'Out for Delivery', done: false },
    ];

    return (
        <div className="min-h-screen bg-brand-light flex flex-col items-center justify-center px-6 py-20">
            <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.6, ease: [0.0, 0.0, 0.2, 1] }}
                className="max-w-lg w-full text-center"
            >
                {/* Checkmark Animation */}
                <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ type: 'spring', stiffness: 200, damping: 15, delay: 0.2 }}
                    className="w-24 h-24 rounded-full bg-green-50 flex items-center justify-center mx-auto mb-8"
                >
                    <CheckCircle className="w-14 h-14 text-green-500" />
                </motion.div>

                <h1 className="font-playfair text-4xl md:text-5xl text-brand-dark mb-3">Order Placed!</h1>
                <p className="font-outfit text-brand-dark/60 mb-2">Thank you for shopping with Auramika Daily 💛</p>
                <p className="font-outfit text-sm text-brand-dark/40 mb-10">Order ID: <span className="font-bold text-brand-dark">{orderId}</span></p>

                {/* Order Track Steps */}
                <div className="flex items-center justify-center gap-0 mb-12">
                    {steps.map((step, i) => (
                        <div key={i} className="flex items-center">
                            <div className="flex flex-col items-center">
                                <div className={`w-10 h-10 rounded-full flex items-center justify-center border-2 ${step.done ? 'bg-green-500 border-green-500' : 'border-brand-dark/20'}`}>
                                    <step.icon className={`w-5 h-5 ${step.done ? 'text-white' : 'text-brand-dark/30'}`} />
                                </div>
                                <p className={`font-outfit text-xs mt-2 text-center w-20 leading-tight ${step.done ? 'text-brand-dark' : 'text-brand-dark/30'}`}>{step.label}</p>
                            </div>
                            {i < steps.length - 1 && (
                                <div className={`w-16 h-px mb-6 mx-2 ${step.done ? 'bg-green-400' : 'bg-brand-dark/10'}`} />
                            )}
                        </div>
                    ))}
                </div>

                <div className="bg-white border border-brand-dark/8 p-6 mb-8 text-left">
                    <h3 className="font-outfit text-xs tracking-widest uppercase text-brand-dark/50 mb-4">What's Next?</h3>
                    <ul className="space-y-3">
                        {[
                            'You will receive a confirmation email shortly.',
                            'Your order will be shipped via Delhivery within 24-48 hours.',
                            'Track your order using the Order ID above.',
                        ].map((t, i) => (
                            <li key={i} className="font-outfit text-sm text-brand-dark/70 flex gap-3">
                                <span className="text-brand-accent font-bold flex-shrink-0">{i + 1}.</span> {t}
                            </li>
                        ))}
                    </ul>
                </div>

                {/* Rate Us */}
                <div className="mb-8">
                    <p className="font-outfit text-xs tracking-widest uppercase text-brand-dark/40 mb-3">Enjoying Auramika? Rate us!</p>
                    <div className="flex justify-center gap-2">
                        {[...Array(5)].map((_, i) => (
                            <Star key={i} className="w-8 h-8 text-yellow-400 fill-yellow-400 cursor-pointer hover:scale-125 transition-transform" />
                        ))}
                    </div>
                </div>

                <div className="flex flex-col sm:flex-row gap-3 justify-center">
                    <Link href="/shop" className="bg-brand-dark text-brand-light px-8 py-4 font-outfit font-bold tracking-widest uppercase hover:bg-brand-accent transition-colors text-sm">
                        Continue Shopping
                    </Link>
                    <Link href="/" className="border border-brand-dark/20 text-brand-dark px-8 py-4 font-outfit font-bold tracking-widest uppercase hover:border-brand-dark transition-colors text-sm">
                        Back to Home
                    </Link>
                </div>
            </motion.div>
        </div>
    );
}
