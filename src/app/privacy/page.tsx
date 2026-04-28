'use client';
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";

const sections = [
    {
        title: '1. Introduction',
        content: 'AURAMIKA Pvt. Ltd. ("we", "our", "us") is committed to protecting your personal information. This Privacy Policy explains how we collect, use, store, and share your data when you use the AURAMIKA application or website. By using our service, you consent to the practices described in this policy.',
    },
    {
        title: '2. Information We Collect',
        content: 'We collect the following types of information:\n\n• Identity & Contact: Name, email address, phone number, and profile details.\n• Transaction Data: Order history, payment method type (not full card numbers), and delivery addresses.\n• Usage Data: App interactions, browsing behaviour, search queries, and wishlist activity.\n• Device Information: Device type, OS version, unique device identifiers, and IP address.\n• Location Data: Approximate location for delivery estimates (only when permission is granted).',
    },
    {
        title: '3. How We Use Your Information',
        content: 'Your data is used to:\n\n• Process and fulfil your orders.\n• Personalise your shopping experience and recommendations.\n• Send order updates, promotional offers, and service notifications.\n• Detect, prevent, and respond to fraud or security incidents.\n• Improve our platform through analytics and user research.\n• Comply with legal obligations under applicable Indian law.',
    },
    {
        title: '4. Data Sharing',
        content: 'We do not sell your personal data. We may share information with:\n\n• Delivery Partners: To fulfil and track your orders.\n• Payment Processors: To securely process transactions (data is encrypted).\n• Analytics Providers: Anonymised or aggregated data to understand usage patterns.\n• Legal Authorities: When required by law, court order, or to protect rights and safety.',
    },
    {
        title: '5. Cookies & Tracking',
        content: 'The AURAMIKA app and website use analytics SDKs and local storage to enhance performance and remember your preferences. These tools help us understand how the platform is used and improve the experience. You may limit tracking through your device or browser settings.',
    },
    {
        title: '6. Data Retention',
        content: 'We retain your personal data for as long as your account is active or as required to provide services. Transaction records may be retained for up to 7 years to comply with Indian financial regulations. You may request deletion of your account and associated data at any time.',
    },
    {
        title: '7. Your Rights',
        content: 'Under applicable data protection laws, you have the right to:\n\n• Access the personal data we hold about you.\n• Correct inaccurate or incomplete data.\n• Request deletion of your account and data.\n• Withdraw consent for marketing communications.\n• Lodge a complaint with the relevant data protection authority.\n\nTo exercise any of these rights, contact us at privacy@auramika.in.',
    },
    {
        title: '8. Data Security',
        content: 'We implement industry-standard security measures including encryption in transit (TLS), secure storage, access controls, and regular security audits. While we strive to protect your data, no method of transmission over the internet is 100% secure.',
    },
    {
        title: "9. Children's Privacy",
        content: 'AURAMIKA is not intended for individuals under the age of 18. We do not knowingly collect personal data from minors. If we become aware that a minor has registered, we will promptly delete the account and associated data.',
    },
    {
        title: '10. Third-Party Links',
        content: 'Our platform may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to review their privacy policies before providing any personal information.',
    },
    {
        title: '11. Changes to This Policy',
        content: 'We may update this Privacy Policy from time to time. We will notify you of significant changes via in-app notification or email. Your continued use of AURAMIKA after changes take effect constitutes your acceptance of the updated policy.',
    },
    {
        title: '12. Contact Us',
        content: 'For privacy-related enquiries or to exercise your data rights, please contact:\n\nEmail: privacy@auramika.in\nPhone: +91 83692 96841\nAddress: AURAMIKA Pvt. Ltd., Navi Mumbai, Mumbai – 400001, Maharashtra, India.',
    },
];

export default function PrivacyPage() {
    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[800px] mx-auto px-4 sm:px-6 pt-32 pb-20">
                <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-10 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back
                </Link>
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7 }}>
                    <h1 className="font-playfair text-5xl md:text-6xl text-brand-dark mb-4">Privacy Policy</h1>
                    <p className="font-outfit text-brand-dark/40 text-sm mb-12">Last updated: January 2025 &nbsp;·&nbsp; AURAMIKA Pvt. Ltd.</p>
                    <div className="space-y-8 font-outfit text-brand-dark/70 leading-relaxed">
                        {sections.map((section, i) => (
                            <div key={i} className="border-b border-brand-dark/8 pb-8 last:border-0">
                                <h2 className="font-playfair text-xl text-brand-dark mb-3">{section.title}</h2>
                                <p className="text-sm whitespace-pre-line">{section.content}</p>
                            </div>
                        ))}
                    </div>
                    <div className="mt-12 p-6 bg-brand-dark text-brand-light">
                        <p className="font-outfit text-sm">Questions about your data? <Link href="/contact" className="underline text-brand-accent hover:text-brand-light transition-colors">Contact our support team</Link> or email privacy@auramika.in.</p>
                    </div>
                </motion.div>
            </div>
            <Footer />
        </div>
    );
}
