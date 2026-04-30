'use client';
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft, Trash2, AlertTriangle, CheckCircle } from "lucide-react";
import { useState } from "react";

const steps = [
    { step: '01', title: 'Open the App', description: 'Launch the Auramika Daily app on your device.' },
    { step: '02', title: 'Go to Profile', description: 'Tap the Profile icon in the bottom navigation bar.' },
    { step: '03', title: 'Open Settings', description: 'Scroll down and tap "Settings" or the gear icon.' },
    { step: '04', title: 'Delete Account', description: 'Tap "Delete Account" and confirm your decision. Your account and data will be permanently removed within 30 days.' },
];

const dataDeleted = [
    'Your name, email, and phone number',
    'Delivery addresses and order history',
    'Wishlist and saved items',
    'Payment method references (actual card data is never stored by us)',
    'In-app messages and support history',
    'Profile preferences and personalisation data',
];

const dataRetained = [
    'Transaction records required by Indian financial regulations (up to 7 years)',
    'Anonymised analytics data that cannot be linked back to you',
];

export default function AccountDeletionPage() {
    const [form, setForm] = useState({ email: '', reason: '', confirm: '' });
    const [submitted, setSubmitted] = useState(false);

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        setSubmitted(true);
    };

    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[800px] mx-auto px-4 sm:px-6 pt-32 pb-20">
                <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-10 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back
                </Link>
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7 }}>
                    <div className="flex items-center gap-3 mb-4">
                        <Trash2 className="w-6 h-6 text-brand-dark/40" />
                        <p className="font-outfit text-xs tracking-widest uppercase text-brand-dark/40">Account Management</p>
                    </div>
                    <h1 className="font-playfair text-5xl md:text-6xl text-brand-dark mb-4">Delete Your Account</h1>
                    <p className="font-outfit text-brand-dark/50 mb-12">You can delete your Auramika Daily account at any time. This action is permanent and cannot be undone.</p>

                    {/* In-app steps */}
                    <h2 className="font-playfair text-2xl text-brand-dark mb-6">Delete via the App</h2>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-12">
                        {steps.map((s, i) => (
                            <motion.div key={i} initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.1 }}
                                className="border border-brand-dark/8 p-6 bg-white">
                                <p className="font-playfair text-3xl text-brand-dark/10 mb-3">{s.step}</p>
                                <h3 className="font-outfit font-semibold text-brand-dark text-sm mb-2">{s.title}</h3>
                                <p className="font-outfit text-xs text-brand-dark/60 leading-relaxed">{s.description}</p>
                            </motion.div>
                        ))}
                    </div>

                    {/* What gets deleted */}
                    <div className="space-y-8 mb-12">
                        <div className="border-b border-brand-dark/8 pb-8">
                            <h2 className="font-playfair text-xl text-brand-dark mb-4">What gets deleted</h2>
                            <ul className="space-y-2">
                                {dataDeleted.map((item, i) => (
                                    <li key={i} className="flex items-start gap-3 font-outfit text-sm text-brand-dark/70">
                                        <CheckCircle className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                                        {item}
                                    </li>
                                ))}
                            </ul>
                        </div>
                        <div className="border-b border-brand-dark/8 pb-8">
                            <h2 className="font-playfair text-xl text-brand-dark mb-4">What we must retain</h2>
                            <ul className="space-y-2">
                                {dataRetained.map((item, i) => (
                                    <li key={i} className="flex items-start gap-3 font-outfit text-sm text-brand-dark/70">
                                        <AlertTriangle className="w-4 h-4 text-amber-500 mt-0.5 flex-shrink-0" />
                                        {item}
                                    </li>
                                ))}
                            </ul>
                        </div>
                    </div>

                    {/* Web form alternative */}
                    <h2 className="font-playfair text-2xl text-brand-dark mb-4">Or request deletion via email</h2>
                    <p className="font-outfit text-sm text-brand-dark/50 mb-8">If you can't access the app, submit a request below. We'll process it within 30 days.</p>

                    {submitted ? (
                        <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }}
                            className="flex flex-col items-center justify-center py-16 border border-green-200 bg-green-50 text-center">
                            <CheckCircle className="w-12 h-12 text-green-500 mb-4" />
                            <h3 className="font-playfair text-2xl text-brand-dark mb-2">Request Received</h3>
                            <p className="font-outfit text-sm text-brand-dark/60 max-w-xs">We'll send a confirmation to your email and process your deletion within 30 days.</p>
                        </motion.div>
                    ) : (
                        <form onSubmit={handleSubmit} className="space-y-6">
                            <div>
                                <label className="font-outfit text-xs tracking-widest uppercase text-brand-dark/50 block mb-2">Email address on account</label>
                                <input type="email" required value={form.email} onChange={e => setForm(f => ({ ...f, email: e.target.value }))}
                                    placeholder="you@example.com"
                                    className="w-full border-b border-brand-dark/20 bg-transparent py-3 font-outfit text-sm focus:outline-none focus:border-brand-dark transition-colors" />
                            </div>
                            <div>
                                <label className="font-outfit text-xs tracking-widest uppercase text-brand-dark/50 block mb-2">Reason (optional)</label>
                                <select value={form.reason} onChange={e => setForm(f => ({ ...f, reason: e.target.value }))}
                                    className="w-full border-b border-brand-dark/20 bg-transparent py-3 font-outfit text-sm focus:outline-none focus:border-brand-dark transition-colors">
                                    <option value="">Select a reason</option>
                                    <option>I no longer use the app</option>
                                    <option>Privacy concerns</option>
                                    <option>Switching to another platform</option>
                                    <option>Too many notifications</option>
                                    <option>Other</option>
                                </select>
                            </div>
                            <div>
                                <label className="font-outfit text-xs tracking-widest uppercase text-brand-dark/50 block mb-2">Type "DELETE" to confirm</label>
                                <input type="text" required value={form.confirm} onChange={e => setForm(f => ({ ...f, confirm: e.target.value }))}
                                    placeholder="DELETE"
                                    className="w-full border-b border-brand-dark/20 bg-transparent py-3 font-outfit text-sm focus:outline-none focus:border-brand-dark transition-colors" />
                            </div>
                            <button type="submit" disabled={form.confirm !== 'DELETE'}
                                className="w-full bg-red-600 text-white py-4 font-outfit font-bold tracking-widest uppercase hover:bg-red-700 transition-colors disabled:opacity-40 disabled:cursor-not-allowed">
                                Submit Deletion Request
                            </button>
                        </form>
                    )}

                    <div className="mt-12 p-6 bg-brand-dark/5">
                        <p className="font-outfit text-sm text-brand-dark/60">Changed your mind? <Link href="/contact" className="underline text-brand-dark hover:text-brand-accent transition-colors">Contact us</Link> — we may be able to help with whatever brought you here.</p>
                    </div>
                </motion.div>
            </div>
            <Footer />
        </div>
    );
}
