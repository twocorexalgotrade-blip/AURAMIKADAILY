'use client';

import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { allProducts } from "@/data/products";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft, Gift, Heart, ShoppingBag } from "lucide-react";
import { useCart } from "@/context/CartContext";
import { useState } from "react";

const occasions = [
    {
        icon: Heart, title: 'For Her', desc: "Romantic picks she'll absolutely love.", categories: ['Earrings', 'Rings']
    },
    { icon: Gift, title: 'For the Bestie', desc: 'BFF-worthy pieces for every bond.', categories: ['Bracelets', 'Chains'] },
    { icon: ShoppingBag, title: 'Self Gift', desc: 'Because YOU deserve it too.', categories: ['Rings', 'Earrings'] },
];

export default function GiftingPage() {
    const { addToCart } = useCart();
    const [addedId, setAddedId] = useState<number | null>(null);

    const handleAdd = (product: typeof allProducts[0]) => {
        addToCart(product);
        setAddedId(product.id);
        setTimeout(() => setAddedId(null), 1500);
    };

    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            {/* Dark Hero Banner */}
            <div className="bg-brand-dark text-brand-light pt-32 pb-20 px-4 sm:px-6">
                <div className="max-w-[1400px] mx-auto">
                    <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-light/40 hover:text-brand-light mb-10 group transition-colors">
                        <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back
                    </Link>
                    <p className="font-outfit text-xs tracking-[0.3em] uppercase text-brand-accent mb-4">Premium Imitation Jewelry</p>
                    <h1 className="font-playfair text-6xl md:text-8xl text-brand-light mb-6 leading-none">The Gift<br />She Deserves.</h1>
                    <p className="font-outfit text-brand-light/60 max-w-md leading-relaxed">Luxury-look jewelry without the luxury price tag. Every gift looks like it costs 10x more. That's the Auramika secret.</p>
                </div>
            </div>

            {/* Gift Box Visual */}
            <div className="bg-brand-dark">
                <div className="max-w-[1400px] mx-auto px-4 sm:px-6">
                    <div className="aspect-video md:aspect-[3/1] overflow-hidden">
                        <img src="/gifting_box.png" alt="Luxury Jewelry Gifting Box" className="w-full h-full object-cover opacity-80" />
                    </div>
                </div>
            </div>

            {/* Occasion Sections */}
            <div className="max-w-[1400px] mx-auto px-4 sm:px-6 py-20">
                {occasions.map((occ, oi) => {
                    const picks = allProducts.filter(p => occ.categories.includes(p.category)).slice(0, 4);
                    return (
                        <div key={oi} className="mb-24">
                            <div className="flex items-center gap-4 mb-8">
                                <div className="w-10 h-10 rounded-full bg-brand-dark flex items-center justify-center">
                                    <occ.icon className="w-5 h-5 text-brand-light" />
                                </div>
                                <div>
                                    <h2 className="font-playfair text-3xl md:text-4xl text-brand-dark">{occ.title}</h2>
                                    <p className="font-outfit text-sm text-brand-dark/50">{occ.desc}</p>
                                </div>
                            </div>
                            <div className="grid grid-cols-2 md:grid-cols-4 gap-5">
                                {picks.map(product => (
                                    <motion.div key={product.id} initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }} className="group">
                                        <Link href={`/product/${product.slug}`}>
                                            <div className="aspect-square overflow-hidden bg-white mb-4">
                                                <img src={product.image} alt={product.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700" />
                                            </div>
                                        </Link>
                                        <h3 className="font-outfit text-sm font-medium mb-1">{product.name}</h3>
                                        <div className="flex justify-between items-center">
                                            <span className="font-outfit text-sm font-semibold">₹ {product.price.toLocaleString('en-IN')}</span>
                                            <button onClick={() => handleAdd(product)}
                                                className={`p-2 border transition-all ${addedId === product.id ? 'bg-green-600 border-green-600' : 'border-brand-dark/20 hover:border-brand-dark'}`}>
                                                <ShoppingBag className={`w-3.5 h-3.5 ${addedId === product.id ? 'text-white' : 'text-brand-dark'}`} />
                                            </button>
                                        </div>
                                    </motion.div>
                                ))}
                            </div>
                        </div>
                    );
                })}

                {/* Gift Note Callout */}
                <div className="bg-brand-dark/5 border border-brand-dark/10 p-8 md:p-12 text-center">
                    <Gift className="w-10 h-10 text-brand-accent mx-auto mb-4" />
                    <h3 className="font-playfair text-3xl text-brand-dark mb-3">Add a Gift Note</h3>
                    <p className="font-outfit text-brand-dark/60 mb-6 max-w-sm mx-auto">Include a personalised message with your gift. All Auramika orders come in our signature luxury box.</p>
                    <Link href="/shop" className="inline-block bg-brand-dark text-brand-light px-10 py-4 font-outfit font-bold tracking-widest uppercase hover:bg-brand-accent transition-colors text-sm">
                        Shop Gifts
                    </Link>
                </div>
            </div>

            <Footer />
        </div>
    );
}
