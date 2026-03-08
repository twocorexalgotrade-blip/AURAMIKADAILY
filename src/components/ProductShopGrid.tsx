'use client';

import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ShoppingBag, Heart } from 'lucide-react';

const categories = ['All', 'Chains', 'Rings', 'Earrings', 'Bracelets'];

const products = [
    { id: 1, name: "Classic Rope Chain", price: 1499, originalPrice: 2999, category: "Chains", image: "/product_chain.png", badge: "Bestseller" },
    { id: 2, name: "Starlit Zirconia Hoops", price: 2199, originalPrice: 3999, category: "Earrings", image: "/category_earrings_1772969724288.png", badge: "New" },
    { id: 3, name: "Eternity Statement Ring", price: 2999, originalPrice: 4999, category: "Rings", image: "/category_rings_1772969707703.png", badge: null },
    { id: 4, name: "Bold Wrist Stack", price: 1899, originalPrice: 3499, category: "Bracelets", image: "/category_bracelets_1772969743501.png", badge: "Hot" },
    { id: 5, name: "Vintage Pendant Drop", price: 1199, originalPrice: 2199, category: "Chains", image: "/product_pendant.png", badge: "Sale" },
    { id: 6, name: "Dainty Gold Chain", price: 999, originalPrice: 1999, category: "Chains", image: "/moodboard_neck_chain.png", badge: null },
    { id: 7, name: "Chunky Statement Cuff", price: 1699, originalPrice: 3199, category: "Bracelets", image: "/moodboard_wrist.png", badge: "New" },
    { id: 8, name: "Mini Hoop Set — 3 Pairs", price: 1499, originalPrice: 2799, category: "Earrings", image: "/product_bracelet.png", badge: null },
];

export default function ProductShopGrid() {
    const [activeCategory, setActiveCategory] = useState('All');
    const [wishlist, setWishlist] = useState<number[]>([]);

    const filtered = activeCategory === 'All' ? products : products.filter(p => p.category === activeCategory);

    const toggleWishlist = (id: number) => {
        setWishlist(prev => prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]);
    };

    return (
        <section className="py-20 md:py-28 bg-[#F8F5F0]" id="shop">
            <div className="max-w-[1400px] mx-auto px-4 sm:px-6">

                {/* Header */}
                <div className="mb-12 md:mb-16 flex flex-col md:flex-row md:items-end md:justify-between gap-6">
                    <div>
                        <h2 className="font-playfair text-4xl md:text-6xl text-brand-dark mb-3">Shop All</h2>
                        <p className="font-outfit text-brand-dark/50 tracking-[0.15em] uppercase text-xs md:text-sm">
                            {products.length} Premium Pieces
                        </p>
                    </div>
                    {/* Category Tabs */}
                    <div className="flex flex-wrap gap-2">
                        {categories.map(cat => (
                            <button
                                key={cat}
                                onClick={() => setActiveCategory(cat)}
                                className={`font-outfit text-xs tracking-widest uppercase px-4 py-2 border transition-all duration-300 ${activeCategory === cat
                                        ? 'bg-brand-dark text-brand-light border-brand-dark'
                                        : 'bg-transparent text-brand-dark/60 border-brand-dark/20 hover:border-brand-dark hover:text-brand-dark'
                                    }`}
                            >
                                {cat}
                            </button>
                        ))}
                    </div>
                </div>

                {/* Product Grid */}
                <motion.div
                    layout
                    className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 md:gap-6 lg:gap-8"
                >
                    <AnimatePresence mode="popLayout">
                        {filtered.map((product) => (
                            <motion.div
                                key={product.id}
                                layout
                                initial={{ opacity: 0, scale: 0.95 }}
                                animate={{ opacity: 1, scale: 1 }}
                                exit={{ opacity: 0, scale: 0.9 }}
                                transition={{ duration: 0.4 }}
                                className="group"
                            >
                                {/* Image Container */}
                                <div className="relative aspect-square overflow-hidden bg-white mb-4">
                                    <img
                                        src={product.image}
                                        alt={product.name}
                                        className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105"
                                    />

                                    {/* Badge */}
                                    {product.badge && (
                                        <div className="absolute top-3 left-3">
                                            <span className="font-outfit text-[10px] tracking-widest uppercase bg-brand-dark text-brand-light px-2 py-1">
                                                {product.badge}
                                            </span>
                                        </div>
                                    )}

                                    {/* Wishlist */}
                                    <button
                                        onClick={() => toggleWishlist(product.id)}
                                        className="absolute top-3 right-3 w-8 h-8 flex items-center justify-center bg-white/80 backdrop-blur-sm"
                                    >
                                        <Heart
                                            className={`w-4 h-4 transition-colors ${wishlist.includes(product.id) ? 'fill-red-500 text-red-500' : 'text-brand-dark/50'}`}
                                        />
                                    </button>

                                    {/* Add to Cart Overlay */}
                                    <div className="absolute bottom-0 left-0 right-0 translate-y-full group-hover:translate-y-0 transition-transform duration-300 bg-brand-dark text-brand-light">
                                        <button className="w-full py-3 font-outfit text-xs tracking-[0.2em] uppercase flex items-center justify-center gap-2 hover:bg-brand-accent transition-colors">
                                            <ShoppingBag className="w-4 h-4" />
                                            Add to Bag
                                        </button>
                                    </div>
                                </div>

                                {/* Info */}
                                <div>
                                    <h3 className="font-outfit text-sm md:text-base text-brand-dark font-medium mb-1 leading-snug">{product.name}</h3>
                                    <div className="flex items-center gap-2">
                                        <span className="font-outfit text-brand-dark font-semibold text-sm md:text-base">₹ {product.price.toLocaleString('en-IN')}</span>
                                        <span className="font-outfit text-brand-dark/40 text-xs line-through">₹ {product.originalPrice.toLocaleString('en-IN')}</span>
                                        <span className="font-outfit text-green-600 text-xs font-bold">
                                            {Math.round((1 - product.price / product.originalPrice) * 100)}% OFF
                                        </span>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                    </AnimatePresence>
                </motion.div>

                {/* View All CTA */}
                <div className="mt-16 text-center">
                    <button className="font-outfit uppercase tracking-widest text-sm border border-brand-dark text-brand-dark px-12 py-4 hover:bg-brand-dark hover:text-brand-light transition-all duration-300">
                        View All {products.length}+ Products
                    </button>
                </div>

            </div>
        </section>
    );
}
