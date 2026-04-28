'use client';
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft, AlertTriangle, Mail, MessageSquare } from "lucide-react";

const whatGetsDeleted = [
    'Your profile information (name, phone number, email)',
    'Saved addresses and delivery preferences',
    'Wishlist and saved items',
    'Order history and transaction records visible in the app',
    'Custom order requests and stylist consultations',
];

const whatIsRetained = [
    'Transaction records required for tax and financial compliance (retained for up to 7 years under Indian law)',
    'Any data required by law enforcement or legal proceedings',
    'Anonymised and aggregated analytics data that cannot identify you',
];

export default function DeleteAccountPage() {
    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[800px] mx-auto px-4 sm:px-6 pt-32 pb-20">
                <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-10 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back
                </Link>
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7 }}>
                    <h1 className="font-playfair text-5xl md:text-6xl text-brand-dark mb-4">Delete Account</h1>
                    <p className="font-outfit text-brand-dark/50 mb-12">
                        We're sorry to see you go. You can delete your AURAMIKA account at any time. This action is permanent and cannot be undone.
                    </p>

                    {/* Warning Banner */}
                    <div className="flex gap-4 p-5 border border-amber-200 bg-amber-50 mb-10">
                        <AlertTriangle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
                        <p className="font-outfit text-sm text-amber-800">
                            Account deletion is irreversible. All your data will be permanently removed. Make sure you have completed any pending orders before proceeding.
                        </p>
                    </div>

                    <div className="space-y-8 font-outfit text-brand-dark/70 leading-relaxed">

                        {/* Method 1 — In-App */}
                        <div className="border-b border-brand-dark/8 pb-8">
                            <h2 className="font-playfair text-xl text-brand-dark mb-4">Option 1: Delete via the App</h2>
                            <p className="text-sm mb-4">The quickest way to delete your account is directly from the AURAMIKA app:</p>
                            <ol className="list-decimal list-inside space-y-2 text-sm pl-2">
                                <li>Open the AURAMIKA app and sign in.</li>
                                <li>Tap the <strong>Profile</strong> icon in the bottom navigation.</li>
                                <li>Scroll down and tap <strong>Account Settings</strong>.</li>
                                <li>Tap <strong>Delete Account</strong>.</li>
                                <li>Confirm by entering your phone number and tapping <strong>Delete permanently</strong>.</li>
                            </ol>
                            <p className="text-sm mt-4 text-brand-dark/50">Your account will be deleted within 30 days of the request.</p>
                        </div>

                        {/* Method 2 — Email */}
                        <div className="border-b border-brand-dark/8 pb-8">
                            <h2 className="font-playfair text-xl text-brand-dark mb-4">Option 2: Request via Email</h2>
                            <p className="text-sm mb-4">
                                If you cannot access the app, email us from the phone number or email linked to your account:
                            </p>
                            <div className="bg-brand-dark/4 p-5 space-y-2 text-sm">
                                <p><strong>To:</strong> privacy@auramika.in</p>
                                <p><strong>Subject:</strong> Account Deletion Request</p>
                                <p><strong>Body:</strong> Please include your registered phone number and full name. We may need to verify your identity before proceeding.</p>
                            </div>
                            <p className="text-sm mt-4 text-brand-dark/50">We will process your request within 7 business days and send a confirmation email.</p>
                        </div>

                        {/* What gets deleted */}
                        <div className="border-b border-brand-dark/8 pb-8">
                            <h2 className="font-playfair text-xl text-brand-dark mb-4">What Gets Deleted</h2>
                            <ul className="space-y-2 text-sm">
                                {whatGetsDeleted.map((item, i) => (
                                    <li key={i} className="flex items-start gap-2">
                                        <span className="text-green-600 mt-0.5">✓</span>
                                        {item}
                                    </li>
                                ))}
                            </ul>
                        </div>

                        {/* What is retained */}
                        <div className="border-b border-brand-dark/8 pb-8">
                            <h2 className="font-playfair text-xl text-brand-dark mb-4">What We May Retain</h2>
                            <p className="text-sm mb-4">Certain data must be retained by law even after account deletion:</p>
                            <ul className="space-y-2 text-sm">
                                {whatIsRetained.map((item, i) => (
                                    <li key={i} className="flex items-start gap-2">
                                        <span className="text-brand-dark/40 mt-0.5">•</span>
                                        {item}
                                    </li>
                                ))}
                            </ul>
                        </div>

                        {/* Privacy Policy */}
                        <div className="pb-8">
                            <h2 className="font-playfair text-xl text-brand-dark mb-3">Privacy Policy</h2>
                            <p className="text-sm">
                                For full details on how we handle your data, please read our{' '}
                                <Link href="/privacy" className="underline text-brand-dark hover:text-brand-accent transition-colors">Privacy Policy</Link>.
                            </p>
                        </div>
                    </div>

                    {/* Contact CTA */}
                    <div className="mt-4 p-6 bg-brand-dark text-brand-light">
                        <p className="font-outfit text-sm mb-4">Need help or have questions before deleting?</p>
                        <div className="flex flex-col sm:flex-row gap-4">
                            <a href="mailto:privacy@auramika.in" className="flex items-center gap-2 font-outfit text-sm text-brand-accent hover:text-brand-light transition-colors">
                                <Mail className="w-4 h-4" /> privacy@auramika.in
                            </a>
                            <a href="https://wa.me/918369296841" target="_blank" rel="noopener noreferrer" className="flex items-center gap-2 font-outfit text-sm text-brand-accent hover:text-brand-light transition-colors">
                                <MessageSquare className="w-4 h-4" /> WhatsApp Support
                            </a>
                        </div>
                    </div>
                </motion.div>
            </div>
            <Footer />
        </div>
    );
}
