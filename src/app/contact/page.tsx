'use client';

import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft, Mail, Phone, Instagram, MessageCircle } from "lucide-react";
import { useState } from "react";

export default function ContactPage() {
    const [form, setForm] = useState({ name: '', email: '', subject: '', message: '' });
    const [sent, setSent] = useState(false);

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        setSent(true);
    };

    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[1100px] mx-auto px-4 sm:px-6 pt-32 pb-20">
                <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-10 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back
                </Link>
                <h1 className="font-playfair text-5xl md:text-7xl text-brand-dark mb-4">Get in Touch</h1>
                <p className="font-outfit text-brand-dark/50 mb-14 max-w-lg">We're here to help! Reach out to us for any questions, order issues, or just to say hi 💛</p>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-16">
                    {/* Contact Channels */}
                    <div>
                        <div className="space-y-6 mb-10">
                            {[
                                { icon: Mail, label: 'Email', value: 'support@auramikadaily.com', href: 'mailto:support@auramikadaily.com' },
                                { icon: Phone, label: 'Phone / WhatsApp', value: '+91 98765 43210', href: 'https://wa.me/919876543210' },
                                { icon: Instagram, label: 'Instagram', value: '@auramika.daily', href: 'https://instagram.com/auramika.daily' },
                                { icon: MessageCircle, label: 'WhatsApp Chat', value: 'Chat with us directly', href: 'https://wa.me/919876543210?text=Hi! I have a question about my order.' },
                            ].map((channel, i) => (
                                <motion.a key={i} href={channel.href} target="_blank" rel="noopener noreferrer"
                                    initial={{ opacity: 0, x: -20 }} whileInView={{ opacity: 1, x: 0 }} viewport={{ once: true }} transition={{ delay: i * 0.1 }}
                                    className="flex items-start gap-4 p-5 border border-brand-dark/8 bg-white hover:border-brand-accent transition-colors group">
                                    <channel.icon className="w-5 h-5 text-brand-accent mt-0.5 flex-shrink-0" />
                                    <div>
                                        <p className="font-outfit text-xs tracking-widest uppercase text-brand-dark/40 mb-1">{channel.label}</p>
                                        <p className="font-outfit text-brand-dark font-medium group-hover:text-brand-accent transition-colors">{channel.value}</p>
                                    </div>
                                </motion.a>
                            ))}
                        </div>
                        <div className="bg-brand-dark/5 p-5">
                            <p className="font-outfit text-xs tracking-widest uppercase text-brand-dark/40 mb-2">Support Hours</p>
                            <p className="font-outfit text-sm text-brand-dark/70">Monday–Saturday: 10am – 7pm IST</p>
                            <p className="font-outfit text-sm text-brand-dark/70">Sunday: Closed (emails answered next day)</p>
                        </div>
                    </div>

                    {/* Contact Form */}
                    <div>
                        {sent ? (
                            <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} className="flex flex-col items-center justify-center h-full text-center py-16 border border-green-200 bg-green-50">
                                <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mb-4">
                                    <Mail className="w-8 h-8 text-green-500" />
                                </div>
                                <h3 className="font-playfair text-2xl text-brand-dark mb-2">Message Sent!</h3>
                                <p className="font-outfit text-sm text-brand-dark/60">We'll get back to you within 24 hours. Check your email!</p>
                            </motion.div>
                        ) : (
                            <form onSubmit={handleSubmit} className="space-y-6">
                                {[
                                    { label: 'Your Name', id: 'name', placeholder: 'Priya Sharma' },
                                    { label: 'Email Address', id: 'email', type: 'email', placeholder: 'priya@email.com' },
                                    { label: 'Subject', id: 'subject', placeholder: 'Order query / Product question / Other' },
                                ].map(field => (
                                    <div key={field.id}>
                                        <label className="font-outfit text-xs tracking-widest uppercase text-brand-dark/50 block mb-2">{field.label}</label>
                                        <input type={field.type || 'text'} required value={form[field.id as keyof typeof form]}
                                            onChange={e => setForm(f => ({ ...f, [field.id]: e.target.value }))}
                                            placeholder={field.placeholder}
                                            className="w-full border-b border-brand-dark/20 bg-transparent py-3 font-outfit text-sm focus:outline-none focus:border-brand-dark transition-colors" />
                                    </div>
                                ))}
                                <div>
                                    <label className="font-outfit text-xs tracking-widest uppercase text-brand-dark/50 block mb-2">Message</label>
                                    <textarea required rows={5} value={form.message} onChange={e => setForm(f => ({ ...f, message: e.target.value }))}
                                        placeholder="Tell us how we can help..."
                                        className="w-full border border-brand-dark/20 bg-transparent p-4 font-outfit text-sm focus:outline-none focus:border-brand-dark transition-colors resize-none" />
                                </div>
                                <button type="submit" className="w-full bg-brand-dark text-brand-light py-4 font-outfit font-bold tracking-widest uppercase hover:bg-brand-accent transition-colors">
                                    Send Message
                                </button>
                            </form>
                        )}
                    </div>
                </div>
            </div>
            <Footer />
        </div>
    );
}
