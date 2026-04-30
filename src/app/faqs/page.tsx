'use client';

import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { motion } from "framer-motion";
import { ChevronLeft, ChevronDown } from "lucide-react";
import Link from "next/link";
import { useState } from "react";

const faqSections = [
    {
        title: 'Orders & Shipping',
        faqs: [
            { q: 'How long does delivery take?', a: 'We ship via Delhivery. Standard delivery takes 3-7 business days across India. Metros typically receive orders in 2-4 days.' },
            { q: 'Is there free shipping?', a: 'Yes! Orders above ₹999 get FREE delivery. Below that, a flat ₹99 shipping fee applies.' },
            { q: 'Do you offer COD (Cash on Delivery)?', a: 'Yes! COD is available across India for all orders. A small COD handling fee of ₹50 may apply.' },
            { q: 'Can I change my delivery address?', a: 'Address changes can only be made within 1 hour of placing your order. Contact us immediately at support@auramikadaily.com.' },
        ]
    },
    {
        title: 'Products & Quality',
        faqs: [
            { q: 'Is this real gold jewelry?', a: 'No, we sell premium imitation jewelry. All our pieces are 18k gold-plated over a brass/copper base. They look and feel exactly like real gold at a fraction of the price.' },
            { q: 'Will the jewelry tarnish?', a: 'Our pieces are tarnish-resistant and waterproof. With proper care (avoid perfume & chemicals), they last 1-2 years easily.' },
            { q: 'Is it safe for sensitive skin?', a: 'All our jewelry is hypoallergenic and nickel-free, making it safe for daily wear even for sensitive skin types.' },
            { q: 'Can I wear it in the shower / swimming pool?', a: 'Yes! Our pieces are waterproof. However, prolonged exposure to chlorinated water may reduce their lifespan.' },
        ]
    },
    {
        title: 'Returns & Refunds',
        faqs: [
            { q: 'What is the return policy?', a: 'We offer hassle-free returns within 7 days of delivery. Items must be unused and in original packaging.' },
            { q: 'How do I return an order?', a: 'Email support@auramikadaily.com with your order ID and reason for return. We will arrange a pickup within 2 business days.' },
            { q: 'How long does a refund take?', a: 'Refunds are processed within 5-7 business days to your original payment method after we receive the returned item.' },
        ]
    },
];

export default function FAQPage() {
    const [openIndex, setOpenIndex] = useState<string | null>(null);

    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[800px] mx-auto px-4 sm:px-6 pt-32 pb-20">
                <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-10 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back
                </Link>
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7 }}>
                    <h1 className="font-playfair text-5xl md:text-6xl text-brand-dark mb-4">FAQs</h1>
                    <p className="font-outfit text-brand-dark/50 mb-14">Got questions? We've got answers. If you don't find what you're looking for, <Link href="/contact" className="underline hover:text-brand-accent">contact us</Link>.</p>

                    {faqSections.map((section, si) => (
                        <div key={si} className="mb-12">
                            <h2 className="font-playfair text-2xl text-brand-dark mb-6 pb-4 border-b border-brand-dark/10">{section.title}</h2>
                            <div className="space-y-2">
                                {section.faqs.map((faq, fi) => {
                                    const key = `${si}-${fi}`;
                                    return (
                                        <div key={fi} className="border border-brand-dark/8 overflow-hidden">
                                            <button onClick={() => setOpenIndex(openIndex === key ? null : key)}
                                                className="w-full flex justify-between items-center p-5 text-left hover:bg-brand-dark/2 transition-colors">
                                                <span className="font-outfit text-sm md:text-base text-brand-dark font-medium pr-4">{faq.q}</span>
                                                <ChevronDown className={`w-4 h-4 text-brand-dark/40 flex-shrink-0 transition-transform duration-300 ${openIndex === key ? 'rotate-180' : ''}`} />
                                            </button>
                                            {openIndex === key && (
                                                <motion.div initial={{ height: 0, opacity: 0 }} animate={{ height: 'auto', opacity: 1 }} transition={{ duration: 0.3 }} className="px-5 pb-5">
                                                    <p className="font-outfit text-sm text-brand-dark/60 leading-relaxed">{faq.a}</p>
                                                </motion.div>
                                            )}
                                        </div>
                                    );
                                })}
                            </div>
                        </div>
                    ))}
                </motion.div>
            </div>
            <Footer />
        </div>
    );
}
