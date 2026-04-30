'use client';

import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { allProducts } from "@/data/products";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";
import { useCart } from "@/context/CartContext";
import { ShoppingBag } from "lucide-react";
import { useState } from "react";

const collections = [
    { title: 'Everyday Gold', description: 'Minimalist pieces for your daily stack.', categories: ['Chains', 'Bracelets'] },
    { title: 'Night Out', description: 'Bold, statement jewelry for every evening.', categories: ['Earrings', 'Rings'] },
    { title: 'Bridal & Occasion', description: 'Elevated pieces for your big moments.', categories: ['Rings', 'Earrings', 'Chains'] },
];

export default function CollectionsPage() {
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
            <div className="max-w-[1400px] mx-auto px-4 sm:px-6 pt-32 pb-20">
                <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-10 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back
                </Link>
                <h1 className="font-playfair text-5xl md:text-7xl text-brand-dark mb-4">Collections</h1>
                <p className="font-outfit text-brand-dark/50 mb-20 max-w-lg">Curated sets for every mood, moment, and occasion. All premium imitation gold.</p>

                {collections.map((col, ci) => {
                    const colProducts = allProducts.filter(p => col.categories.includes(p.category)).slice(0, 4);
                    return (
                        <div key={ci} className="mb-24">
                            <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-4 mb-10 pb-4 border-b border-brand-dark/10">
                                <div>
                                    <p className="font-outfit text-xs tracking-[0.3em] uppercase text-brand-dark/40 mb-1">Collection {String(ci + 1).padStart(2, '0')}</p>
                                    <h2 className="font-playfair text-4xl md:text-5xl text-brand-dark">{col.title}</h2>
                                    <p className="font-outfit text-brand-dark/50 text-sm mt-2">{col.description}</p>
                                </div>
                                <Link href="/shop" className="font-outfit text-xs tracking-widest uppercase border-b border-brand-dark/30 pb-1 hover:text-brand-accent hover:border-brand-accent transition-colors whitespace-nowrap">
                                    View All →
                                </Link>
                            </div>
                            <div className="grid grid-cols-2 md:grid-cols-4 gap-5">
                                {colProducts.map(product => (
                                    <motion.div key={product.id} initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }} className="group">
                                        <Link href={`/product/${product.slug}`}>
                                            <div className="relative aspect-square overflow-hidden bg-white mb-4">
                                                <img src={product.image} alt={product.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700" />
                                                {product.badge && <span className="absolute top-3 left-3 font-outfit text-[10px] tracking-widest uppercase bg-brand-dark text-brand-light px-2 py-1">{product.badge}</span>}
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
            </div>
            <Footer />
        </div>
    );
}
