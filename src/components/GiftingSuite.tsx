'use client';

import { motion } from 'framer-motion';
import { ArrowUpRight } from 'lucide-react';
import Link from 'next/link';

export default function GiftingSuite() {
    return (
        <section className="w-full bg-brand-dark text-brand-light flex flex-col md:flex-row">
            {/* Left: Self */}
            <motion.div
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 1 }}
                className="flex-1 border-b md:border-b-0 md:border-r border-brand-light/10 flex flex-col justify-between p-8 sm:p-10 md:p-16 relative overflow-hidden group hover:bg-brand-accent/5 transition-colors duration-500 min-h-[50vh] md:min-h-[80vh]"
            >
                <div className="absolute top-6 right-6 md:top-12 md:right-12 opacity-0 group-hover:opacity-100 transition-all duration-300 group-hover:translate-x-1 group-hover:-translate-y-1">
                    <ArrowUpRight className="w-7 h-7 md:w-10 md:h-10" />
                </div>

                <div>
                    <p className="font-outfit uppercase tracking-[0.3em] text-xs text-brand-light/50 mb-3 font-bold">Treat Yourself</p>
                    <h2 className="font-playfair text-3xl sm:text-4xl md:text-5xl lg:text-6xl leading-tight mb-4">
                        Curated for the<br />Main Character.
                    </h2>
                </div>

                <div>
                    <p className="font-outfit text-brand-light/70 max-w-xs mb-6 leading-relaxed text-sm md:text-base">
                        You don't need a reason. Elevate your everyday stack with our boldest imitation gold pieces.
                    </p>
                    <Link href="/shop" className="font-outfit uppercase tracking-widest text-xs sm:text-sm border-b border-brand-light pb-1 hover:text-brand-accent hover:border-brand-accent transition-colors">
                        Shop Self Love
                    </Link>
                </div>
            </motion.div>

            {/* Right: Gifting */}
            <motion.div
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 1, delay: 0.2 }}
                className="flex-1 flex flex-col justify-between p-8 sm:p-10 md:p-16 relative overflow-hidden group hover:bg-brand-light/5 transition-colors duration-500 min-h-[50vh] md:min-h-[80vh]"
            >
                {/* Background image */}
                <div className="absolute inset-0 z-0">
                    <img src="/gifting_box.png" alt="Gifting" className="w-full h-full object-cover opacity-20 group-hover:opacity-30 transition-opacity duration-700 mix-blend-luminosity" />
                    <div className="absolute inset-0 bg-gradient-to-t from-brand-dark via-brand-dark/60 to-transparent" />
                </div>

                <div className="absolute top-6 right-6 md:top-12 md:right-12 opacity-0 group-hover:opacity-100 transition-all duration-300 group-hover:translate-x-1 group-hover:-translate-y-1 z-10">
                    <ArrowUpRight className="w-7 h-7 md:w-10 md:h-10" />
                </div>

                <div className="z-10 relative">
                    <p className="font-outfit uppercase tracking-[0.3em] text-xs text-brand-light/50 mb-3 font-bold">Gifting Suite</p>
                    <h2 className="font-playfair text-3xl sm:text-4xl md:text-5xl lg:text-6xl leading-tight">
                        The Ultimate<br />Gift.
                    </h2>
                </div>

                <div className="z-10 relative">
                    <p className="font-outfit text-brand-light/70 max-w-xs mb-6 leading-relaxed text-sm md:text-base">
                        From birthdays to anniversaries — waterproof, forever, and looks real. That's the Auramika secret.
                    </p>
                    <div className="flex flex-wrap gap-3">
                        {['For Her', 'For Him', 'Anniversaries'].map(tag => (
                            <Link key={tag} href="/gifting"
                                className="font-outfit uppercase tracking-widest text-xs border border-brand-light/20 px-4 py-2 rounded-full hover:bg-brand-light hover:text-brand-dark transition-colors">
                                {tag}
                            </Link>
                        ))}
                    </div>
                </div>
            </motion.div>
        </section>
    );
}
