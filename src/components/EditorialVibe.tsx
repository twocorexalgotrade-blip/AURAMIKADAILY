'use client';

import { motion } from 'framer-motion';

export default function EditorialVibe() {
    return (
        <section className="py-16 md:py-24 lg:py-32 px-4 sm:px-6 bg-brand-light w-full overflow-hidden">
            <div className="max-w-7xl mx-auto">
                <div className="text-center mb-12 md:mb-20 lg:mb-24">
                    <motion.h2
                        initial={{ opacity: 0, y: 30 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true, margin: '-80px' }}
                        transition={{ duration: 1 }}
                        className="font-playfair text-4xl sm:text-5xl md:text-6xl lg:text-8xl text-brand-dark mb-4 tracking-tight leading-none"
                    >
                        MADE FOR<br />THE MAIN CHARACTER.
                    </motion.h2>
                    <p className="font-outfit uppercase tracking-[0.3em] text-brand-dark/50 text-xs sm:text-sm">Not your average jewelry brand.</p>
                </div>

                {/* Mobile: single column stack | Desktop: asymmetric */}
                <div className="flex flex-col md:grid md:grid-cols-12 gap-5 md:gap-8 lg:gap-16 items-start">

                    {/* Left: Skater — full width on mobile, 5-cols on desktop */}
                    <motion.div
                        initial={{ opacity: 0, y: 40 }}
                        whileInView={{ opacity: 1, y: 0 }}
                        viewport={{ once: true, margin: '-80px' }}
                        transition={{ duration: 1 }}
                        className="w-full md:col-span-5 relative aspect-[3/4] md:h-[700px] lg:h-[800px] md:aspect-auto"
                    >
                        <img src="/montage_skateboard_1772970439300.png" alt="Skater" className="w-full h-full object-cover rounded-sm" />
                    </motion.div>

                    {/* Right column: two images stacked */}
                    <div className="w-full md:col-span-7 flex flex-col gap-5 md:gap-8 lg:gap-16 md:pt-16 lg:pt-32">
                        <motion.div
                            initial={{ opacity: 0, x: 30 }}
                            whileInView={{ opacity: 1, x: 0 }}
                            viewport={{ once: true, margin: '-80px' }}
                            transition={{ duration: 1, delay: 0.15 }}
                            className="relative w-full aspect-video md:aspect-[4/3]"
                        >
                            <img src="/montage_dj_1772970423198.png" alt="DJ" className="w-full h-full object-cover rounded-sm" />
                            <p className="font-playfair text-4xl md:text-6xl text-white drop-shadow-xl italic absolute bottom-4 left-4 md:bottom-8 md:left-8 hidden md:block mix-blend-difference">SWEAT<br />PROOF</p>
                        </motion.div>

                        <motion.div
                            initial={{ opacity: 0, y: 40 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            viewport={{ once: true, margin: '-80px' }}
                            transition={{ duration: 1, delay: 0.3 }}
                            className="relative w-full aspect-[3/4] md:aspect-[3/4]"
                        >
                            <img src="/montage_traditional_1772970453777.png" alt="Traditional" className="w-full h-full object-cover rounded-sm" />
                            <div className="absolute inset-0 bg-gradient-to-t from-brand-dark via-transparent to-transparent flex items-end p-6 md:p-10 lg:p-12">
                                <h3 className="font-playfair text-3xl sm:text-4xl md:text-5xl text-brand-light">
                                    Royal.<br /><span className="italic opacity-80 font-light">Without the price tag.</span>
                                </h3>
                            </div>
                        </motion.div>
                    </div>

                </div>
            </div>
        </section>
    );
}
