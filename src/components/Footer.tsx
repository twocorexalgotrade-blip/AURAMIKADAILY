'use client';

import { motion } from 'framer-motion';
import { Instagram } from 'lucide-react';
import { useState } from 'react';
import Link from 'next/link';

const links = {
    Shop: [
        { label: 'All Jewelry', href: '/shop' },
        { label: 'Collections', href: '/collections' },
        { label: 'Gifting', href: '/gifting' },
        { label: 'New Arrivals', href: '/shop' },
    ],
    Info: [
        { label: 'About Us', href: '/story' },
        { label: 'Track Order', href: '/track-order' },
        { label: 'Returns & Refunds', href: '/returns' },
        { label: 'Shipping Policy', href: '/shipping-policy' },
        { label: 'Privacy Policy', href: '/privacy' },
    ],
    Connect: [
        { label: 'Instagram', href: 'https://instagram.com/auramika.daily' },
        { label: 'WhatsApp', href: 'https://wa.me/919876543210' },
        { label: 'Contact Us', href: '/contact' },
        { label: 'FAQs', href: '/faqs' },
    ],
};

export default function Footer() {
    const [email, setEmail] = useState('');
    const [subscribed, setSubscribed] = useState(false);

    const handleSubscribe = (e: React.FormEvent) => {
        e.preventDefault();
        if (email) { setSubscribed(true); }
    };

    return (
        <footer className="bg-brand-dark text-brand-light overflow-hidden">
            <div className="max-w-[1400px] mx-auto px-6 pt-24 pb-16 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-16 lg:gap-8 border-b border-brand-light/10">
                {/* Brand Column */}
                <div className="lg:col-span-2">
                    <h3 className="font-playfair text-2xl tracking-[0.2em] uppercase mb-4 text-brand-accent">Auramika Daily</h3>
                    <p className="font-outfit text-brand-light/60 max-w-sm leading-relaxed mb-8 text-sm">
                        Premium imitation jewelry for the modern Indian woman. Luxury-look. Real-feel. Prices that make sense.
                    </p>
                    <a href="https://instagram.com/auramika.daily" target="_blank" rel="noopener noreferrer"
                        className="inline-flex items-center gap-3 font-outfit text-sm tracking-wider text-brand-light/70 hover:text-brand-accent transition-colors">
                        <Instagram className="w-5 h-5" />
                        @auramika.daily
                    </a>

                    {/* Newsletter */}
                    <div className="mt-10">
                        <p className="font-outfit text-xs tracking-widest uppercase text-brand-light/40 mb-4">Get Early Access</p>
                        {subscribed ? (
                            <p className="font-outfit text-sm text-brand-accent">You're in! ✨ Watch your inbox.</p>
                        ) : (
                            <form onSubmit={handleSubscribe} className="flex gap-0">
                                <input type="email" placeholder="your@email.com" value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    className="flex-1 bg-transparent border border-brand-light/20 px-4 py-3 font-outfit text-sm focus:outline-none focus:border-brand-accent transition-colors placeholder:text-brand-light/30" />
                                <button type="submit" className="bg-brand-accent text-white px-6 py-3 font-outfit font-bold tracking-widest uppercase text-xs hover:opacity-80 transition-opacity">Join</button>
                            </form>
                        )}
                    </div>
                </div>

                {/* Link Columns */}
                {Object.entries(links).map(([section, items]) => (
                    <div key={section}>
                        <h4 className="font-outfit text-xs tracking-[0.3em] uppercase text-brand-light/40 mb-6">{section}</h4>
                        <ul className="space-y-4">
                            {items.map((item) => (
                                <li key={item.label}>
                                    {item.href.startsWith('http') ? (
                                        <a href={item.href} target="_blank" rel="noopener noreferrer" className="font-outfit text-sm text-brand-light/70 hover:text-brand-accent transition-colors">{item.label}</a>
                                    ) : (
                                        <Link href={item.href} className="font-outfit text-sm text-brand-light/70 hover:text-brand-accent transition-colors">{item.label}</Link>
                                    )}
                                </li>
                            ))}
                        </ul>
                    </div>
                ))}
            </div>

            {/* Massive Brand Name */}
            <div className="relative overflow-hidden py-8 md:py-12 select-none">
                <motion.p
                    initial={{ opacity: 0 }}
                    whileInView={{ opacity: 1 }}
                    viewport={{ once: true }}
                    transition={{ duration: 1.5 }}
                    className="font-playfair font-bold leading-none tracking-tighter text-[18vw] md:text-[16vw] text-transparent bg-clip-text bg-gradient-to-r from-brand-light/10 via-brand-light/30 to-brand-light/10 whitespace-nowrap text-center"
                >
                    AURAMIKA
                </motion.p>
            </div>

            {/* Bottom Bar */}
            <div className="max-w-[1400px] mx-auto px-6 pb-10 flex flex-col md:flex-row justify-between items-center gap-4 text-center">
                <p className="font-outfit text-xs text-brand-light/30 tracking-wider">
                    © 2026 Auramika Daily. All rights reserved. Premium Imitation Jewelry.
                </p>
                <div className="flex gap-6">
                    <Link href="/privacy" className="font-outfit text-xs text-brand-light/30 hover:text-brand-accent tracking-wider transition-colors">Privacy</Link>
                    <Link href="/returns" className="font-outfit text-xs text-brand-light/30 hover:text-brand-accent tracking-wider transition-colors">Returns</Link>
                    <Link href="/shipping-policy" className="font-outfit text-xs text-brand-light/30 hover:text-brand-accent tracking-wider transition-colors">Shipping</Link>
                </div>
            </div>
        </footer>
    );
}
