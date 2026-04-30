'use client';

import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { allProducts } from "@/data/products";
import { useCart, Product } from "@/context/CartContext";
import { motion, AnimatePresence } from "framer-motion";
import Link from "next/link";
import { useState, useEffect } from "react";
import { ShoppingBag, Heart, SlidersHorizontal, X } from "lucide-react";

const categories = ['All', 'Chains', 'Rings', 'Earrings', 'Bracelets'];
const sortOptions = ['Featured', 'Price: Low to High', 'Price: High to Low', 'New Arrivals'];

export default function ShopPage() {
    const { addToCart } = useCart();
    const [activeCategory, setActiveCategory] = useState('All');
    const [sortBy, setSortBy] = useState('Featured');
    const [wishlist, setWishlist] = useState<number[]>([]);
    const [filterOpen, setFilterOpen] = useState(false);
    const [addedId, setAddedId] = useState<number | null>(null);
    const [dbProducts, setDbProducts] = useState<Product[]>([]);

    useEffect(() => {
        fetch('/api/products')
            .then(res => res.json())
            .then(data => { if (Array.isArray(data)) setDbProducts(data); })
            .catch(() => {}); // silently fail — hardcoded products still show
    }, []);

    const allCombined = [...allProducts, ...dbProducts];

    const filtered = allCombined
        .filter(p => activeCategory === 'All' || p.category === activeCategory)
        .sort((a, b) => {
            if (sortBy === 'Price: Low to High') return a.price - b.price;
            if (sortBy === 'Price: High to Low') return b.price - a.price;
            return 0;
        });

    const toggleWishlist = (id: number) => setWishlist(prev => prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]);

    const handleAdd = (product: Product) => {
        addToCart(product);
        setAddedId(product.id);
        setTimeout(() => setAddedId(null), 1500);
    };

    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />

            {/* Page Header */}
            <div className="pt-32 pb-12 px-4 sm:px-6 max-w-[1400px] mx-auto">
                <p className="font-outfit text-xs tracking-[0.3em] uppercase text-brand-dark/50 mb-2">
                    Home / Shop
                </p>
                <h1 className="font-playfair text-5xl md:text-7xl text-brand-dark mb-2">Shop All</h1>
                <p className="font-outfit text-brand-dark/50 text-sm">{filtered.length} products</p>
            </div>

            {/* Filters Bar */}
            <div className="sticky top-16 z-30 bg-brand-light/95 backdrop-blur-md border-y border-brand-dark/10">
                <div className="max-w-[1400px] mx-auto px-4 sm:px-6 py-4 flex justify-between items-center gap-4">
                    <div className="flex gap-2 overflow-x-auto pb-1 scrollbar-hide">
                        {categories.map(cat => (
                            <button
                                key={cat}
                                onClick={() => setActiveCategory(cat)}
                                className={`font-outfit text-xs tracking-widest uppercase px-4 py-2 border whitespace-nowrap transition-all duration-200 ${activeCategory === cat ? 'bg-brand-dark text-brand-light border-brand-dark' : 'border-brand-dark/20 text-brand-dark/60 hover:border-brand-dark hover:text-brand-dark'
                                    }`}
                            >
                                {cat}
                            </button>
                        ))}
                    </div>
                    <div className="flex items-center gap-3 flex-shrink-0">
                        <select
                            value={sortBy}
                            onChange={e => setSortBy(e.target.value)}
                            className="font-outfit text-xs tracking-wider text-brand-dark/70 border-0 bg-transparent cursor-pointer focus:outline-none hidden md:block"
                        >
                            {sortOptions.map(o => <option key={o}>{o}</option>)}
                        </select>
                        <button onClick={() => setFilterOpen(true)} className="flex items-center gap-1 font-outfit text-xs tracking-widest uppercase text-brand-dark/60">
                            <SlidersHorizontal className="w-4 h-4" /> Filter
                        </button>
                    </div>
                </div>
            </div>

            {/* Product Grid */}
            <div className="max-w-[1400px] mx-auto px-4 sm:px-6 py-12">
                <motion.div layout className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4 md:gap-6 lg:gap-8">
                    <AnimatePresence mode="popLayout">
                        {filtered.map(product => (
                            <motion.div
                                key={product.id}
                                layout
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                exit={{ opacity: 0 }}
                                transition={{ duration: 0.35 }}
                                className="group"
                            >
                                <Link href={`/product/${product.slug}`}>
                                    <div className="relative aspect-square overflow-hidden bg-white mb-4 cursor-pointer">
                                        <img src={product.image} alt={product.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700" />
                                        {product.badge && (
                                            <span className="absolute top-3 left-3 font-outfit text-[10px] tracking-widest uppercase bg-brand-dark text-brand-light px-2 py-1">
                                                {product.badge}
                                            </span>
                                        )}
                                        <button onClick={e => { e.preventDefault(); toggleWishlist(product.id); }}
                                            className="absolute top-3 right-3 w-8 h-8 flex items-center justify-center bg-white/90">
                                            <Heart className={`w-4 h-4 ${wishlist.includes(product.id) ? 'fill-red-500 text-red-500' : 'text-brand-dark/40'}`} />
                                        </button>
                                    </div>
                                </Link>
                                <h3 className="font-outfit text-sm md:text-base text-brand-dark font-medium mb-1">{product.name}</h3>
                                <div className="flex items-center gap-2 mb-3">
                                    <span className="font-outfit font-semibold text-sm">₹ {product.price.toLocaleString('en-IN')}</span>
                                    <span className="font-outfit text-brand-dark/30 text-xs line-through">₹ {product.originalPrice.toLocaleString('en-IN')}</span>
                                    <span className="font-outfit text-green-600 text-xs font-bold">{Math.round((1 - product.price / product.originalPrice) * 100)}% OFF</span>
                                </div>
                                <button
                                    onClick={() => handleAdd(product)}
                                    className={`w-full py-3 font-outfit text-xs tracking-widest uppercase flex items-center justify-center gap-2 transition-all duration-200 border ${addedId === product.id ? 'bg-green-600 text-white border-green-600' : 'border-brand-dark text-brand-dark hover:bg-brand-dark hover:text-brand-light'
                                        }`}
                                >
                                    <ShoppingBag className="w-3 h-3" />
                                    {addedId === product.id ? 'Added ✓' : 'Add to Bag'}
                                </button>
                            </motion.div>
                        ))}
                    </AnimatePresence>
                </motion.div>
            </div>

            {/* Filter Drawer (Mobile) */}
            <AnimatePresence>
                {filterOpen && (
                    <>
                        <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
                            onClick={() => setFilterOpen(false)} className="fixed inset-0 z-[60] bg-brand-dark/50" />
                        <motion.div initial={{ x: '100%' }} animate={{ x: 0 }} exit={{ x: '100%' }}
                            transition={{ type: 'spring', damping: 25, stiffness: 200 }}
                            className="fixed top-0 right-0 z-[70] h-full w-[80vw] max-w-sm bg-brand-light p-8">
                            <div className="flex justify-between items-center mb-8">
                                <h3 className="font-playfair text-2xl">Filter</h3>
                                <button onClick={() => setFilterOpen(false)}><X className="w-5 h-5" /></button>
                            </div>
                            <div className="mb-8">
                                <h4 className="font-outfit text-xs tracking-widest uppercase text-brand-dark/50 mb-4">Sort By</h4>
                                {sortOptions.map(o => (
                                    <button key={o} onClick={() => { setSortBy(o); setFilterOpen(false); }}
                                        className={`block w-full text-left font-outfit text-base py-3 border-b border-brand-dark/10 ${sortBy === o ? 'text-brand-accent font-bold' : 'text-brand-dark/70'}`}>
                                        {o}
                                    </button>
                                ))}
                            </div>
                        </motion.div>
                    </>
                )}
            </AnimatePresence>

            <Footer />
        </div>
    );
}
