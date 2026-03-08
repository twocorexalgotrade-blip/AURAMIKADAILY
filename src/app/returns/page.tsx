'use client';
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";

export default function ReturnsPage() {
    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[800px] mx-auto px-4 sm:px-6 pt-32 pb-20">
                <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-10 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back
                </Link>
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7 }}>
                    <h1 className="font-playfair text-5xl md:text-6xl text-brand-dark mb-4">Returns & Refunds</h1>
                    <p className="font-outfit text-brand-dark/50 mb-12">We want you to love your Auramika piece. If something isn't right, we'll make it right.</p>
                    <div className="space-y-8 font-outfit text-brand-dark/70 leading-relaxed">
                        {[
                            { title: 'Return Window', content: 'We accept returns within 7 days of delivery. Items must be unworn, undamaged, and in original packaging with all tags intact.' },
                            { title: 'Non-Returnable Items', content: 'Items marked as "Final Sale", earrings (for hygiene reasons), and customised/personalised pieces cannot be returned.' },
                            { title: 'How to Initiate a Return', content: 'Email support@auramikadaily.com with your Order ID, the item name, and reason for return. We will arrange a free reverse pickup within 2 business days.' },
                            { title: 'Refund Processing', content: 'Once we receive and inspect your item, refunds are processed within 5–7 business days to your original payment method. UPI / bank transfers may take 1–3 additional days depending on your bank.' },
                            { title: 'Damaged or Defective Items', content: 'If you receive a damaged, defective, or incorrect item, please email us with a photo within 48 hours of delivery. We will send a replacement at no additional cost.' },
                            { title: 'COD Orders', content: 'For Cash on Delivery orders, refunds will be made via bank transfer. Please share your bank account details when initiating the return.' },
                        ].map((section, i) => (
                            <div key={i} className="border-b border-brand-dark/8 pb-8 last:border-0">
                                <h2 className="font-playfair text-xl text-brand-dark mb-3">{section.title}</h2>
                                <p className="text-sm">{section.content}</p>
                            </div>
                        ))}
                    </div>
                    <div className="mt-12 p-6 bg-brand-dark text-brand-light">
                        <p className="font-outfit text-sm">Still have questions? <Link href="/contact" className="underline text-brand-accent hover:text-brand-light transition-colors">Contact our support team</Link> — we respond within 24 hours.</p>
                    </div>
                </motion.div>
            </div>
            <Footer />
        </div>
    );
}
