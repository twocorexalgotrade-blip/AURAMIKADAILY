'use client';
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft, Mail, MessageSquare, Clock, Package, RotateCcw, CreditCard, Smartphone } from "lucide-react";

const topics = [
    {
        icon: Package,
        title: 'Orders & Delivery',
        description: 'Track an order, change delivery address, or report a missing parcel.',
        links: [
            { label: 'Track your order', href: '/track-order' },
            { label: 'View FAQs on shipping', href: '/faqs' },
        ],
    },
    {
        icon: RotateCcw,
        title: 'Returns & Refunds',
        description: 'Return an item, check refund status, or report a damaged product.',
        links: [
            { label: 'Returns policy', href: '/returns' },
            { label: 'View FAQs on returns', href: '/faqs' },
        ],
    },
    {
        icon: CreditCard,
        title: 'Payments & Billing',
        description: 'Payment failed, duplicate charge, or need an invoice.',
        links: [
            { label: 'Contact support', href: '/contact' },
        ],
    },
    {
        icon: Smartphone,
        title: 'App Issues',
        description: 'App crash, login problems, or account access issues.',
        links: [
            { label: 'Contact support', href: '/contact' },
            { label: 'Delete your account', href: '/delete-account' },
        ],
    },
];

export default function SupportPage() {
    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[800px] mx-auto px-4 sm:px-6 pt-32 pb-20">
                <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-10 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back
                </Link>
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7 }}>
                    <h1 className="font-playfair text-5xl md:text-6xl text-brand-dark mb-4">Support</h1>
                    <p className="font-outfit text-brand-dark/50 mb-12">
                        We're here to help. Reach out via any of the channels below — we typically respond within a few hours.
                    </p>

                    {/* Contact Channels */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-14">
                        <a href="mailto:support@auramikadaily.com"
                            className="group flex items-start gap-4 p-6 border border-brand-dark/10 hover:border-brand-accent transition-colors">
                            <Mail className="w-5 h-5 text-brand-dark/40 group-hover:text-brand-accent transition-colors flex-shrink-0 mt-0.5" />
                            <div>
                                <p className="font-outfit font-semibold text-sm text-brand-dark mb-1">Email Support</p>
                                <p className="font-outfit text-xs text-brand-dark/50">support@auramikadaily.com</p>
                                <p className="font-outfit text-xs text-brand-dark/40 mt-1 flex items-center gap-1">
                                    <Clock className="w-3 h-3" /> Replies within 24 hours
                                </p>
                            </div>
                        </a>

                        <a href="https://wa.me/918369296841" target="_blank" rel="noopener noreferrer"
                            className="group flex items-start gap-4 p-6 border border-brand-dark/10 hover:border-brand-accent transition-colors">
                            <MessageSquare className="w-5 h-5 text-brand-dark/40 group-hover:text-brand-accent transition-colors flex-shrink-0 mt-0.5" />
                            <div>
                                <p className="font-outfit font-semibold text-sm text-brand-dark mb-1">WhatsApp</p>
                                <p className="font-outfit text-xs text-brand-dark/50">+91 83692 96841</p>
                                <p className="font-outfit text-xs text-brand-dark/40 mt-1 flex items-center gap-1">
                                    <Clock className="w-3 h-3" /> Mon–Sat, 10am–7pm IST
                                </p>
                            </div>
                        </a>
                    </div>

                    {/* Topic Grid */}
                    <h2 className="font-playfair text-2xl text-brand-dark mb-6">What do you need help with?</h2>
                    <div className="space-y-4 mb-14">
                        {topics.map((topic, i) => {
                            const Icon = topic.icon;
                            return (
                                <div key={i} className="border border-brand-dark/8 p-6">
                                    <div className="flex items-start gap-4">
                                        <Icon className="w-5 h-5 text-brand-dark/40 flex-shrink-0 mt-0.5" />
                                        <div className="flex-1">
                                            <h3 className="font-outfit font-semibold text-sm text-brand-dark mb-1">{topic.title}</h3>
                                            <p className="font-outfit text-sm text-brand-dark/50 mb-3">{topic.description}</p>
                                            <div className="flex flex-wrap gap-4">
                                                {topic.links.map((link, j) => (
                                                    <Link key={j} href={link.href}
                                                        className="font-outfit text-xs text-brand-dark/60 underline hover:text-brand-accent transition-colors">
                                                        {link.label}
                                                    </Link>
                                                ))}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            );
                        })}
                    </div>

                    {/* Legal Links */}
                    <div className="border-t border-brand-dark/8 pt-8">
                        <p className="font-outfit text-xs text-brand-dark/40 tracking-widest uppercase mb-4">Legal</p>
                        <div className="flex flex-wrap gap-6">
                            <Link href="/privacy" className="font-outfit text-sm text-brand-dark/60 hover:text-brand-accent transition-colors underline">Privacy Policy</Link>
                            <Link href="/terms" className="font-outfit text-sm text-brand-dark/60 hover:text-brand-accent transition-colors underline">Terms of Service</Link>
                            <Link href="/returns" className="font-outfit text-sm text-brand-dark/60 hover:text-brand-accent transition-colors underline">Returns Policy</Link>
                            <Link href="/shipping-policy" className="font-outfit text-sm text-brand-dark/60 hover:text-brand-accent transition-colors underline">Shipping Policy</Link>
                            <Link href="/delete-account" className="font-outfit text-sm text-brand-dark/60 hover:text-brand-accent transition-colors underline">Delete Account</Link>
                        </div>
                    </div>
                </motion.div>
            </div>
            <Footer />
        </div>
    );
}
