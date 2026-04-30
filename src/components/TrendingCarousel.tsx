'use client';

import { motion } from 'framer-motion';
import { useRef, useEffect, useState } from 'react';
import Link from 'next/link';
import { allProducts } from '@/data/products';

export default function TrendingCarousel() {
    const carouselRef = useRef<HTMLDivElement>(null);
    const [width, setWidth] = useState(0);

    useEffect(() => {
        const el = carouselRef.current;
        if (!el) return;
        const update = () => setWidth(el.scrollWidth - el.offsetWidth);
        update();
        window.addEventListener('resize', update);
        return () => window.removeEventListener('resize', update);
    }, []);

    // Use allProducts for real slugs
    const products = allProducts.slice(0, 6).map(p => ({
        id: p.id,
        slug: p.slug,
        name: p.name,
        price: `₹ ${p.price.toLocaleString('en-IN')}`,
        image: p.image,
        originalPrice: `₹ ${p.originalPrice.toLocaleString('en-IN')}`,
    }));

    return (
        <section className="py-16 md:py-24 lg:py-32 bg-brand-light overflow-hidden">
            <div className="max-w-[1400px] mx-auto px-4 sm:px-6 mb-8 md:mb-12 flex justify-between items-end">
                <div>
                    <h2 className="font-playfair text-3xl sm:text-4xl md:text-5xl lg:text-6xl text-brand-dark mb-2 md:mb-4">Everyday Luxury</h2>
                    <p className="font-outfit text-brand-dark/50 tracking-widest uppercase text-xs sm:text-sm">Most covetable pieces, trending now.</p>
                </div>
                <p className="hidden sm:block font-outfit opacity-40 text-xs sm:text-sm uppercase tracking-widest">Drag to explore →</p>
            </div>

            <div ref={carouselRef} className="cursor-grab active:cursor-grabbing overflow-hidden">
                <motion.div
                    drag="x"
                    dragConstraints={{ right: 0, left: -width }}
                    whileTap={{ cursor: 'grabbing' }}
                    className="flex gap-4 sm:gap-6 md:gap-8 px-4 sm:px-6"
                    style={{ paddingRight: 24 }}
                >
                    {products.map((product) => (
                        <motion.div
                            key={product.id}
                            className="min-w-[200px] sm:min-w-[260px] md:min-w-[340px] lg:min-w-[400px] flex-shrink-0 group"
                            whileHover={{ scale: 0.98 }}
                            transition={{ duration: 0.3 }}
                        >
                            <Link href={`/product/${product.slug}`} draggable={false}>
                                <div className="aspect-[3/4] overflow-hidden bg-brand-dark/5 mb-3 md:mb-6 relative">
                                    <img
                                        src={product.image}
                                        alt={product.name}
                                        className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700 ease-out"
                                        draggable="false"
                                    />
                                    <div className="absolute inset-0 bg-brand-dark/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none" />
                                </div>
                                <div className="flex justify-between items-start font-outfit px-1">
                                    <h3 className="text-sm sm:text-base md:text-lg text-brand-dark font-medium leading-snug pr-2">{product.name}</h3>
                                    <div className="text-right flex-shrink-0">
                                        <p className="text-brand-dark font-semibold text-sm md:text-base">{product.price}</p>
                                        <p className="text-brand-dark/40 text-xs line-through">{product.originalPrice}</p>
                                    </div>
                                </div>
                            </Link>
                        </motion.div>
                    ))}
                </motion.div>
            </div>
        </section>
    );
}
