'use client';
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft, Truck, CheckCircle } from "lucide-react";

export default function ShippingPage() {
    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[800px] mx-auto px-4 sm:px-6 pt-32 pb-20">
                <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-10 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back
                </Link>
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7 }}>
                    <h1 className="font-playfair text-5xl md:text-6xl text-brand-dark mb-4">Shipping Policy</h1>
                    <p className="font-outfit text-brand-dark/50 mb-12">Fast, reliable delivery across India — powered by Delhivery.</p>
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
                        {[
                            { label: 'Standard Delivery', time: '3–7 Business Days', price: '₹99 (Free above ₹999)' },
                            { label: 'Metro Cities', time: '2–4 Business Days', price: 'Same as above' },
                            { label: 'COD Available', time: 'Extra ₹50 fee', price: 'Pan-India' },
                        ].map((tier, i) => (
                            <div key={i} className="border border-brand-dark/10 p-6 bg-white">
                                <Truck className="w-6 h-6 text-brand-accent mb-3" />
                                <h3 className="font-outfit font-bold text-brand-dark mb-1 tracking-wide text-sm uppercase">{tier.label}</h3>
                                <p className="font-playfair text-2xl text-brand-dark mb-1">{tier.time}</p>
                                <p className="font-outfit text-xs text-brand-dark/50">{tier.price}</p>
                            </div>
                        ))}
                    </div>
                    <div className="space-y-6 font-outfit text-brand-dark/70 leading-relaxed text-sm">
                        {[
                            { title: 'Order Processing', content: 'Orders are processed within 24–48 hours on business days (Mon–Sat, excluding public holidays). You will receive a shipping confirmation email with a tracking link once dispatched.' },
                            { title: 'Tracking Your Order', content: 'Once shipped, you can track your order via the Delhivery tracking portal using the tracking ID shared in your email. You can also use our Track Order page.' },
                            { title: 'Delays', content: 'Delivery timelines are estimates and may be delayed due to natural events, public holidays, or carrier issues. We will notify you of any significant delays.' },
                            { title: 'Undeliverable Orders', content: 'If a delivery is attempted 3 times and fails, the package is returned to us. We will contact you to reschedule or issue a refund minus shipping cost.' },
                        ].map((s, i) => (
                            <div key={i} className="flex gap-4 border-b border-brand-dark/8 pb-6 last:border-0">
                                <CheckCircle className="w-4 h-4 text-brand-accent flex-shrink-0 mt-0.5" />
                                <div>
                                    <h4 className="font-bold text-brand-dark mb-1">{s.title}</h4>
                                    <p>{s.content}</p>
                                </div>
                            </div>
                        ))}
                    </div>
                </motion.div>
            </div>
            <Footer />
        </div>
    );
}
