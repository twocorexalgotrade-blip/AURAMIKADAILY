'use client';
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";

const sections = [
    {
        title: '1. Information We Collect',
        content: 'We collect information you provide directly: name, email address, phone number, delivery addresses, and payment details (processed securely via Cashfree — we never store card numbers). We also collect usage data such as pages visited, products viewed, and search queries to improve your experience.',
    },
    {
        title: '2. How We Use Your Information',
        content: 'Your data is used to process and fulfil orders, send order confirmations and shipping updates, personalise product recommendations, respond to customer support queries, prevent fraud and ensure platform security, and comply with applicable Indian law including the IT Act 2000 and GST regulations.',
    },
    {
        title: '3. Data Sharing',
        content: 'We do not sell your personal data. We share it only with: (a) delivery partners to fulfil your orders, (b) payment processors (Cashfree Payments) under strict data-processing agreements, (c) analytics providers using anonymised data, and (d) law-enforcement authorities when legally required.',
    },
    {
        title: '4. Data Retention',
        content: 'We retain your account data for as long as your account is active. Transaction records are retained for up to 7 years as required by Indian financial regulations. You may request deletion of your account and personal data at any time — see Section 8.',
    },
    {
        title: '5. Cookies & Analytics',
        content: 'Our website and mobile app use cookies and similar technologies to remember your preferences, maintain your session, and collect anonymised usage statistics. You can control cookies through your browser or device settings; disabling them may affect some features.',
    },
    {
        title: '6. Security',
        content: 'We implement TLS encryption for all data in transit, secure encrypted storage for data at rest, role-based access controls, and regular security audits. No method of transmission over the internet is 100% secure; we encourage you to use a strong password and protect your account credentials.',
    },
    {
        title: "7. Children's Privacy",
        content: 'Auramika Daily is not directed at children under 18. We do not knowingly collect personal data from minors. If you believe a minor has provided us with personal data, please contact us and we will delete it promptly.',
    },
    {
        title: '8. Your Rights & Account Deletion',
        content: 'You have the right to access, correct, or delete your personal data at any time. To delete your account and all associated data, visit Settings → Delete Account in the app, or email privacy@auramikadaily.com with the subject "Account Deletion Request". We will process your request within 30 days.',
    },
    {
        title: '9. Third-Party Links',
        content: 'Our platform may link to third-party websites or services (e.g., payment gateways, social media). We are not responsible for the privacy practices of those third parties and encourage you to review their policies.',
    },
    {
        title: '10. Changes to This Policy',
        content: 'We may update this Privacy Policy from time to time. We will notify you of significant changes via in-app notification or email at least 14 days before the change takes effect. Continued use of the app after that date constitutes acceptance.',
    },
    {
        title: '11. Contact Us',
        content: 'For any privacy-related queries or requests:\nEmail: privacy@auramikadaily.com\nAddress: Auramika Daily, Navi Mumbai, Maharashtra – 400001, India\nWe aim to respond within 72 hours.',
    },
];

export default function PrivacyPolicyPage() {
    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[800px] mx-auto px-4 sm:px-6 pt-32 pb-20">
                <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-10 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back
                </Link>
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7 }}>
                    <p className="font-outfit text-xs tracking-widest uppercase text-brand-dark/40 mb-4">Last updated: April 2025</p>
                    <h1 className="font-playfair text-5xl md:text-6xl text-brand-dark mb-4">Privacy Policy</h1>
                    <p className="font-outfit text-brand-dark/50 mb-12">Auramika Daily ("we", "our", "us") is committed to protecting your personal information. This policy explains how we collect, use, and safeguard your data when you use our app or website.</p>
                    <div className="space-y-8 font-outfit text-brand-dark/70 leading-relaxed">
                        {sections.map((section, i) => (
                            <div key={i} className="border-b border-brand-dark/8 pb-8 last:border-0">
                                <h2 className="font-playfair text-xl text-brand-dark mb-3">{section.title}</h2>
                                <p className="text-sm whitespace-pre-line">{section.content}</p>
                            </div>
                        ))}
                    </div>
                    <div className="mt-12 p-6 bg-brand-dark text-brand-light">
                        <p className="font-outfit text-sm">Questions about your privacy? <Link href="/contact" className="underline text-brand-accent hover:text-brand-light transition-colors">Contact us</Link> or email privacy@auramikadaily.com</p>
                    </div>
                </motion.div>
            </div>
            <Footer />
        </div>
    );
}
