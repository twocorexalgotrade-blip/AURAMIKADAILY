'use client';

import { motion } from 'framer-motion';

const categories = [
    { title: "Statement Rings", image: "/category_rings_1772969707703.png" },
    { title: "Trendy Hoops", image: "/category_earrings_1772969724288.png" },
    { title: "Wrist Stacks", image: "/category_bracelets_1772969743501.png" },
    { title: "Gold Chains", image: "/product_chain.png" },
];

export default function FeaturedCategories() {
    return (
        <section className="py-16 md:py-24 lg:py-32 px-4 sm:px-6 bg-brand-light w-full">
            <div className="max-w-[1400px] mx-auto">
                <div className="mb-10 md:mb-16 lg:mb-24 text-center">
                    <h2 className="font-playfair text-3xl sm:text-4xl md:text-5xl lg:text-6xl text-brand-dark mb-3">Shop By Category</h2>
                    <p className="font-outfit text-brand-dark/50 tracking-[0.2em] uppercase text-xs sm:text-sm">See It. Love It. Stack It.</p>
                </div>

                {/* Mobile: 2-col grid | Desktop: asymmetric */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-5">
                    {/* Large left tile — spans 2 rows on desktop */}
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true, margin: '-80px' }}
                        transition={{ duration: 0.8 }}
                        className="relative overflow-hidden group cursor-pointer col-span-1 row-span-1 md:row-span-2 aspect-[3/4] md:aspect-auto md:h-full min-h-[250px] sm:min-h-[300px]"
                        style={{ gridRow: 'span 2' }}
                    >
                        <img src={categories[0].image} alt={categories[0].title} className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-105" />
                        <div className="absolute inset-0 bg-gradient-to-t from-brand-dark/80 via-transparent to-transparent" />
                        <div className="absolute bottom-4 left-4 md:bottom-8 md:left-8 z-10">
                            <h3 className="font-playfair text-white text-lg sm:text-xl md:text-3xl mb-1">{categories[0].title}</h3>
                            <p className="font-outfit text-white/70 text-xs tracking-widest uppercase group-hover:text-brand-accent transition-colors">Shop Now →</p>
                        </div>
                    </motion.div>

                    {/* Top right */}
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true, margin: '-80px' }}
                        transition={{ duration: 0.8, delay: 0.1 }}
                        className="relative overflow-hidden group cursor-pointer col-span-1 aspect-square md:col-span-2 md:aspect-[16/9]"
                    >
                        <img src={categories[1].image} alt={categories[1].title} className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-105" />
                        <div className="absolute inset-0 bg-gradient-to-t from-brand-dark/80 via-transparent to-transparent" />
                        <div className="absolute bottom-4 left-4 md:bottom-6 md:left-6 z-10">
                            <h3 className="font-playfair text-white text-lg sm:text-xl md:text-2xl mb-1">{categories[1].title}</h3>
                            <p className="font-outfit text-white/70 text-xs tracking-widest uppercase group-hover:text-brand-accent transition-colors">Shop Now →</p>
                        </div>
                    </motion.div>

                    {/* Bottom right wide */}
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true, margin: '-80px' }}
                        transition={{ duration: 0.8, delay: 0.2 }}
                        className="relative overflow-hidden group cursor-pointer col-span-1 aspect-square md:col-span-2 md:aspect-[16/9]"
                    >
                        <img src={categories[2].image} alt={categories[2].title} className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-105" />
                        <div className="absolute inset-0 bg-gradient-to-t from-brand-dark/80 via-transparent to-transparent" />
                        <div className="absolute bottom-4 left-4 md:bottom-6 md:left-6 z-10">
                            <h3 className="font-playfair text-white text-lg sm:text-xl md:text-2xl mb-1">{categories[2].title}</h3>
                            <p className="font-outfit text-white/70 text-xs tracking-widest uppercase group-hover:text-brand-accent transition-colors">Shop Now →</p>
                        </div>
                    </motion.div>

                    {/* Hidden 4th on mobile, shown on desktop */}
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true, margin: '-80px' }}
                        transition={{ duration: 0.8, delay: 0.3 }}
                        className="relative overflow-hidden group cursor-pointer col-span-2 aspect-[2/1] md:col-span-1 md:aspect-[3/4]"
                    >
                        <img src={categories[3].image} alt={categories[3].title} className="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-105" />
                        <div className="absolute inset-0 bg-gradient-to-t from-brand-dark/80 via-transparent to-transparent" />
                        <div className="absolute bottom-4 left-4 md:bottom-8 md:left-8 z-10">
                            <h3 className="font-playfair text-white text-lg sm:text-xl md:text-2xl mb-1">{categories[3].title}</h3>
                            <p className="font-outfit text-white/70 text-xs tracking-widest uppercase group-hover:text-brand-accent transition-colors">Shop Now →</p>
                        </div>
                    </motion.div>
                </div>
            </div>
        </section>
    );
}
