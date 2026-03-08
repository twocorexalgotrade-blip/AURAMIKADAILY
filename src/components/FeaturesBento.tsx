'use client';

import { motion } from 'framer-motion';
import { Droplets, ShieldCheck, Sparkles, Heart } from 'lucide-react';

const features = [
    { icon: <Droplets className="w-7 h-7 text-brand-accent" />, title: "100% Waterproof", body: "Sweat it, shower in it, live in it. Designed for everyday wear." },
    { icon: <ShieldCheck className="w-7 h-7 text-brand-accent" />, title: "Hypoallergenic", body: "Nickel-free, skin-safe. Safe for sensitive skin at every price point." },
    { icon: <Sparkles className="w-7 h-7 text-brand-accent" />, title: "18K Look & Feel", body: "Premium imitation gold that looks exactly like the real thing." },
    { icon: <Heart className="w-7 h-7 text-brand-accent" />, title: "Accessible Luxury", body: "Because luxury shouldn't be a privilege. Stack more, spend less." },
];

const moodboard = [
    { src: "/moodboard_girl_street.png", alt: "Street style with gold chain", caption: "@auramika.daily" },
    { src: "/moodboard_wrist.png", alt: "Wrist stack", caption: "@auramika.daily" },
    { src: "/moodboard_neck_chain.png", alt: "Gold rope chain editorial", caption: "@auramika.daily" },
    { src: "/category_earrings_1772969724288.png", alt: "Hoop earrings", caption: "@auramika.daily" },
    { src: "/category_bracelets_1772969743501.png", alt: "Wrist stacks styled", caption: "@auramika.daily" },
    { src: "/hero_last_frame_1772968275780.png", alt: "Product flat lay", caption: "@auramika.daily" },
];

const containerVariants = {
    hidden: {},
    visible: { transition: { staggerChildren: 0.1 } },
};

const itemVariants = {
    hidden: { opacity: 0, scale: 0.95 },
    visible: { opacity: 1, scale: 1, transition: { duration: 0.6, ease: [0.0, 0.0, 0.2, 1] as const } },
};

export default function FeaturesBento() {
    return (
        <section className="bg-brand-light py-24 md:py-32">

            {/* Features Grid */}
            <div className="max-w-[1400px] mx-auto px-6 mb-24 md:mb-36">
                <div className="mb-16 text-center">
                    <h2 className="font-playfair text-4xl md:text-6xl text-brand-dark mb-4">The Auramika Promise</h2>
                    <p className="font-outfit text-brand-dark/50 tracking-[0.2em] uppercase text-sm">Fashion without compromise.</p>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
                    {features.map((feat, i) => (
                        <motion.div
                            key={i}
                            initial={{ opacity: 0, y: 30 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            viewport={{ once: true, margin: '-50px' }}
                            transition={{ duration: 0.7, delay: i * 0.1 }}
                            className="group p-8 border border-brand-dark/8 hover:border-brand-accent/50 transition-all duration-500 relative overflow-hidden"
                        >
                            <div className="absolute inset-0 bg-brand-accent/3 opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
                            <div className="mb-6">{feat.icon}</div>
                            <h3 className="font-playfair text-xl text-brand-dark mb-3">{feat.title}</h3>
                            <p className="font-outfit text-sm text-brand-dark/60 leading-relaxed">{feat.body}</p>
                        </motion.div>
                    ))}
                </div>
            </div>

            {/* IG Mood Board */}
            <div className="max-w-[1400px] mx-auto px-6">
                <div className="mb-12 md:mb-16 flex flex-col md:flex-row justify-between items-end gap-4">
                    <div>
                        <h2 className="font-playfair text-4xl md:text-6xl text-brand-dark mb-2">As Seen On</h2>
                        <p className="font-outfit text-brand-dark/50 tracking-[0.2em] uppercase text-sm">The Community</p>
                    </div>
                    <a
                        href="https://instagram.com/auramika.daily"
                        target="_blank"
                        rel="noopener noreferrer"
                        className="font-outfit text-sm tracking-widest uppercase border-b border-brand-dark/30 pb-1 hover:text-brand-accent hover:border-brand-accent transition-colors whitespace-nowrap"
                    >
                        Follow @auramika.daily →
                    </a>
                </div>

                <motion.div
                    className="grid grid-cols-2 md:grid-cols-3 gap-3 md:gap-4"
                    variants={containerVariants}
                    initial="hidden"
                    whileInView="visible"
                    viewport={{ once: true, margin: '-100px' }}
                >
                    {moodboard.map((item, i) => (
                        <motion.div key={i} variants={itemVariants} className="relative aspect-square overflow-hidden group cursor-pointer">
                            <img
                                src={item.src}
                                alt={item.alt}
                                className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105"
                            />
                            <div className="absolute inset-0 bg-brand-dark/50 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center">
                                <div className="text-center text-white">
                                    <p className="font-outfit text-sm tracking-widest">{item.caption}</p>
                                </div>
                            </div>
                        </motion.div>
                    ))}
                </motion.div>
            </div>

        </section>
    );
}
