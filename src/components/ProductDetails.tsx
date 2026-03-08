'use client';

import { useState } from 'react';
import { ShieldCheck, Truck } from 'lucide-react';
import Link from 'next/link';

export default function ProductDetails() {
    const [pincode, setPincode] = useState('');
    const [deliveryMsg, setDeliveryMsg] = useState('');

    const checkPincode = () => {
        if (pincode.length === 6) {
            setDeliveryMsg('✓ Delivery available in 2-3 business days via Delhivery.');
        } else {
            setDeliveryMsg('Please enter a valid 6-digit pincode.');
        }
    };

    return (
        <section className="bg-brand-light py-16 md:py-24 lg:py-32 px-4 sm:px-6">
            <div className="max-w-[1400px] mx-auto">

                {/* Mobile: stack | Desktop: side-by-side with sticky image */}
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 lg:gap-24 items-start">

                    {/* Image */}
                    <div className="w-full aspect-square lg:aspect-auto lg:h-[85vh] lg:sticky lg:top-24 overflow-hidden">
                        <img src="/hero_last_frame.png" alt="Eternity Gold Link Chain" className="w-full h-full object-cover" />
                    </div>

                    {/* Content */}
                    <div className="flex flex-col justify-center py-4 lg:py-16">
                        <span className="font-outfit text-xs tracking-[0.3em] uppercase text-brand-dark/40 mb-4">Featured Piece</span>
                        <h2 className="font-playfair text-3xl sm:text-4xl md:text-5xl lg:text-6xl text-brand-dark mb-4 leading-tight">
                            Eternity Gold<br />Chunky Chain
                        </h2>
                        <p className="font-outfit text-xl md:text-2xl text-brand-dark/80 mb-6 font-light tracking-wider">₹ 2,999.00
                            <span className="text-base text-brand-dark/30 line-through ml-3">₹ 5,499.00</span>
                            <span className="text-sm text-green-600 font-bold ml-2">45% OFF</span>
                        </p>

                        <div className="w-12 h-px bg-brand-dark/20 mb-6" />

                        <div className="font-outfit text-brand-dark/70 leading-relaxed mb-8 space-y-4 text-sm md:text-base">
                            <p>
                                Our most-loved piece. Crafted with premium 18k imitation gold plating — looks exactly like the real thing, at a price that makes sense.
                            </p>
                            <ul className="space-y-2">
                                {['Premium 18k gold plating', 'Tarnish-resistant finish', 'Hypoallergenic & skin-safe', 'Waterproof — wear it everywhere', 'Lobster clasp closure'].map(f => (
                                    <li key={f} className="flex items-center gap-2">
                                        <span className="w-1 h-1 rounded-full bg-brand-accent flex-shrink-0" />
                                        {f}
                                    </li>
                                ))}
                            </ul>
                        </div>

                        {/* Pincode check */}
                        <div className="mb-8 p-5 border border-brand-dark/10">
                            <div className="flex items-center gap-3 mb-4 font-outfit font-medium text-sm">
                                <Truck className="w-4 h-4 text-brand-accent" />
                                <span className="tracking-wide uppercase">Check Delivery</span>
                            </div>
                            <div className="flex gap-3">
                                <input type="text" placeholder="Enter 6-digit Pincode"
                                    className="flex-1 bg-transparent border-b border-brand-dark/20 py-2 font-outfit text-sm focus:outline-none focus:border-brand-accent transition-colors"
                                    value={pincode} onChange={(e) => setPincode(e.target.value)} maxLength={6} />
                                <button onClick={checkPincode} className="font-outfit text-xs tracking-wider uppercase hover:text-brand-accent transition-colors px-3">Check</button>
                            </div>
                            {deliveryMsg && <p className="mt-3 text-xs font-outfit text-brand-dark/60 italic">{deliveryMsg}</p>}
                        </div>

                        {/* CTAs */}
                        <div className="flex flex-col sm:flex-row gap-3 mb-8">
                            <Link href="/product/classic-rope-chain" className="flex-1 bg-brand-dark text-brand-light py-4 font-outfit font-bold tracking-widest uppercase text-center hover:bg-brand-accent transition-colors text-sm">
                                View Full Details
                            </Link>
                            <Link href="/shop" className="flex-1 border border-brand-dark text-brand-dark py-4 font-outfit font-bold tracking-widest uppercase text-center hover:bg-brand-dark/5 transition-colors text-sm">
                                Shop All
                            </Link>
                        </div>

                        {/* Trust */}
                        <div className="flex items-center gap-2 text-brand-dark/40 pt-6 border-t border-brand-dark/10">
                            <ShieldCheck className="w-4 h-4 text-brand-accent flex-shrink-0" />
                            <span className="font-outfit text-xs tracking-wider">100% Secure. Easy Returns. COD Available.</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>
    );
}
