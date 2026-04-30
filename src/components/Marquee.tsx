'use client';

import { motion } from 'framer-motion';

export default function Marquee() {
    const text = " PREMIUM IMITATION JEWELRY • YOUR VIBE YOUR RULES • LUXURY FOR ALL •";

    return (
        <div className="w-full bg-brand-accent text-brand-light py-3 md:py-4 overflow-hidden flex whitespace-nowrap border-y border-brand-dark/20">
            <motion.div
                className="flex space-x-6 items-center"
                animate={{ x: [0, -1200] }}
                transition={{ repeat: Infinity, ease: "linear", duration: 18 }}
            >
                <span className="text-sm sm:text-lg md:text-2xl font-outfit uppercase tracking-widest font-bold px-4">{text}</span>
                <span className="text-sm sm:text-lg md:text-2xl font-outfit uppercase tracking-widest font-bold px-4">{text}</span>
                <span className="text-sm sm:text-lg md:text-2xl font-outfit uppercase tracking-widest font-bold px-4">{text}</span>
                <span className="text-sm sm:text-lg md:text-2xl font-outfit uppercase tracking-widest font-bold px-4">{text}</span>
            </motion.div>
        </div>
    );
}
