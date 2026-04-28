'use client';
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";

const sections = [
    {
        title: '1. Service Description',
        content: 'AURAMIKA is a curated jewellery marketplace that connects verified artisans and brands with customers across India. Our platform facilitates discovery, purchase, and delivery of jewellery products through our mobile application and website.',
    },
    {
        title: '2. Eligibility',
        content: 'You must be at least 18 years of age and capable of entering into a legally binding agreement to use AURAMIKA. By using our service, you represent and warrant that you meet these eligibility requirements.',
    },
    {
        title: '3. User Accounts',
        content: 'To access certain features, you must register for an account. You agree to provide accurate and complete information, keep your credentials secure, and notify us of any breach or unauthorised use. AURAMIKA reserves the right to suspend or terminate accounts that violate these terms.',
    },
    {
        title: '4. Vendor Conduct',
        content: 'Vendors listing products on AURAMIKA must ensure their listings are accurate, comply with applicable laws, and meet our quality and authenticity standards. Fraudulent listings, counterfeit goods, or misleading representations will result in immediate removal and legal action.',
    },
    {
        title: '5. Prohibited Activities',
        content: 'You agree not to: reverse-engineer or copy any part of the platform; use automated tools to scrape data; post false or misleading reviews; engage in any activity that interferes with or disrupts the service; or violate any applicable local, national, or international law.',
    },
    {
        title: '6. Content Standards',
        content: 'Any content you submit — including reviews, photos, or communications — must be lawful, respectful, and accurate. AURAMIKA reserves the right to remove any content that violates community standards or applicable laws without prior notice.',
    },
    {
        title: '7. Payments & Pricing',
        content: 'All prices are listed in Indian Rupees (INR) and are inclusive of applicable taxes. AURAMIKA reserves the right to update pricing at any time. Payments are processed securely through our payment partners. AURAMIKA is not liable for any payment gateway errors or bank processing delays.',
    },
    {
        title: '8. Service Availability',
        content: 'AURAMIKA strives for 99.9% uptime but does not guarantee uninterrupted access. Scheduled maintenance, technical issues, or force majeure events may temporarily affect availability. We will endeavour to notify users of planned downtime in advance.',
    },
    {
        title: '9. Third-Party Services',
        content: 'Our platform integrates with third-party services including payment gateways, delivery partners, and analytics providers. Use of these services is subject to their respective terms and privacy policies. AURAMIKA is not responsible for third-party service conduct.',
    },
    {
        title: '10. Termination',
        content: 'Either party may terminate the service relationship at any time. You may delete your account via the app or by visiting auramika.in/delete-account. AURAMIKA may terminate or suspend access without notice if you breach these Terms of Service.',
    },
    {
        title: '11. Limitation of Liability',
        content: 'To the maximum extent permitted by law, AURAMIKA shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the platform. Our total liability shall not exceed the amount paid by you for the specific transaction giving rise to the claim.',
    },
    {
        title: '12. Dispute Resolution',
        content: 'Any disputes arising from or related to these Terms of Service shall first be attempted to be resolved through good-faith negotiation. If unresolved within 30 days, disputes shall be referred to arbitration under the Arbitration and Conciliation Act, 1996 (India).',
    },
    {
        title: '13. Amendments',
        content: 'AURAMIKA may update these Terms of Service from time to time. Material changes will be communicated via in-app notification or email. Continued use of the service following notification constitutes your acceptance of the updated terms.',
    },
    {
        title: '14. Contact',
        content: 'For enquiries regarding these Terms of Service, reach us at:\n\nEmail: privacy@auramika.in\nPhone: +91 83692 96841\nAddress: AURAMIKA Pvt. Ltd., Navi Mumbai, Mumbai – 400001, Maharashtra, India.',
    },
];

export default function TermsPage() {
    return (
        <div className="min-h-screen bg-brand-light">
            <Navigation />
            <div className="max-w-[800px] mx-auto px-4 sm:px-6 pt-32 pb-20">
                <Link href="/" className="flex items-center gap-2 font-outfit text-sm text-brand-dark/50 hover:text-brand-dark mb-10 group transition-colors">
                    <ChevronLeft className="w-4 h-4 group-hover:-translate-x-1 transition-transform" /> Back
                </Link>
                <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.7 }}>
                    <h1 className="font-playfair text-5xl md:text-6xl text-brand-dark mb-4">Terms of Service</h1>
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
                        <p className="font-outfit text-sm">Have questions about our terms? <Link href="/contact" className="underline text-brand-accent hover:text-brand-light transition-colors">Contact our support team</Link> — we respond within 24 hours.</p>
                    </div>
                </motion.div>
            </div>
            <Footer />
        </div>
    );
}
