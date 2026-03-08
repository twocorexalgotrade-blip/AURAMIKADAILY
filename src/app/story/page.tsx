'use client';

import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";

export default function AboutPage() {
    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[900px] mx-auto px-4 sm:px-6 pt-32 pb-20">
                <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-10 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back to Home
                </Link>

                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.8 }}>
                    <h1 className="font-playfair text-5xl md:text-7xl text-brand-dark mb-8 leading-tight">Our Story</h1>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-12 mb-16">
                        <div>
                            <img src="/moodboard_girl_street.png" alt="Auramika Story" className="w-full aspect-square object-cover" />
                        </div>
                        <div className="flex flex-col justify-center">
                            <h2 className="font-playfair text-3xl text-brand-dark mb-6">Luxury shouldn't be a privilege.</h2>
                            <p className="font-outfit text-brand-dark/70 leading-relaxed mb-4">
                                Auramika Daily was born from a simple idea — why should you have to choose between looking expensive and being broke?
                            </p>
                            <p className="font-outfit text-brand-dark/70 leading-relaxed">
                                Founded in 2024, we crafted a line of premium imitation jewelry that looks and feels exactly like fine gold jewelry, at prices that make sense for the modern Indian woman and man.
                            </p>
                        </div>
                    </div>

                    <div className="w-full h-px bg-brand-dark/10 mb-16" />

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-16">
                        {[
                            { number: '50K+', label: 'Happy Customers' },
                            { number: '200+', label: 'Unique Designs' },
                            { number: '4.8★', label: 'Average Rating' },
                        ].map((stat, i) => (
                            <motion.div key={i} initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }} transition={{ delay: i * 0.1 }} className="text-center">
                                <p className="font-playfair text-6xl text-brand-dark mb-2">{stat.number}</p>
                                <p className="font-outfit text-sm tracking-widest uppercase text-brand-dark/50">{stat.label}</p>
                            </motion.div>
                        ))}
                    </div>

                    <div className="bg-brand-dark text-brand-light p-10 md:p-16">
                        <h2 className="font-playfair text-3xl md:text-5xl mb-6">The Auramika Promise</h2>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            {['18k Gold Plated for a real gold look', 'Waterproof — sweat, shower, swim', 'Hypoallergenic & skin-safe materials', 'Tarnish-resistant for lasting shine', 'Accessible luxury pricing', 'Fast delivery across India'].map((p, i) => (
                                <div key={i} className="flex items-start gap-3 font-outfit text-sm text-brand-light/80">
                                    <span className="text-brand-accent mt-0.5">✦</span> {p}
                                </div>
                            ))}
                        </div>
                    </div>
                </motion.div>
            </div>
            <Footer />
        </div>
    );
}
