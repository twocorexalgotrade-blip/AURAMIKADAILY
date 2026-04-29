'use client';
import Navigation from "@/components/Navigation";
import Footer from "@/components/Footer";
import { motion } from "framer-motion";
import Link from "next/link";
import { ChevronLeft } from "lucide-react";

const sections = [
    {
        title: '1. Acceptance of Terms',
        content: 'By downloading, installing, or using the Auramika Daily app or website, you agree to be bound by these Terms of Service. If you do not agree, please do not use our platform.',
    },
    {
        title: '2. Eligibility',
        content: 'You must be at least 18 years old and capable of entering a legally binding agreement under Indian law to use Auramika Daily. By using our platform, you represent that you meet these requirements.',
    },
    {
        title: '3. User Accounts',
        content: 'You agree to provide accurate and complete information when creating your account. You are responsible for maintaining the confidentiality of your login credentials and for all activity that occurs under your account. Please notify us immediately at support@auramikadaily.com if you suspect unauthorised access.',
    },
    {
        title: '4. Orders & Payments',
        content: 'All orders are subject to availability and acceptance. Prices are listed in Indian Rupees (INR) and include applicable taxes. Payments are processed securely by Cashfree Payments. We reserve the right to cancel any order for reasons including but not limited to product unavailability, pricing errors, or suspected fraud.',
    },
    {
        title: '5. Shipping & Delivery',
        content: 'We ship across India. Estimated delivery timelines are provided at checkout and are indicative only. Auramika Daily is not liable for delays caused by courier partners, natural events, or circumstances beyond our control. Risk of loss transfers to you upon delivery.',
    },
    {
        title: '6. Returns & Refunds',
        content: 'Our returns and refund policy is detailed at auramikadaily.com/returns. In summary: items may be returned within 7 days of delivery in original, unworn condition. Refunds are processed within 5–7 business days after we receive and inspect the returned item.',
    },
    {
        title: '7. Intellectual Property',
        content: 'All content on the platform — including text, images, logos, product photography, and software — is the exclusive property of Auramika Daily or its licensors and is protected by Indian and international intellectual property laws. You may not reproduce, distribute, or create derivative works without our prior written consent.',
    },
    {
        title: '8. Prohibited Conduct',
        content: 'You agree not to: (a) use the platform for any unlawful purpose; (b) submit false or misleading reviews or information; (c) attempt to reverse-engineer, scrape, or interfere with the platform; (d) impersonate any person or entity; or (e) engage in any conduct that could damage or disrupt the platform or other users.',
    },
    {
        title: '9. Limitation of Liability',
        content: 'To the maximum extent permitted by applicable law, Auramika Daily shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the platform. Our total liability for any claim shall not exceed the amount paid by you for the order giving rise to the claim.',
    },
    {
        title: '10. Governing Law & Disputes',
        content: 'These Terms are governed by the laws of India. Any disputes arising from or related to these Terms shall first be attempted to be resolved through good-faith negotiation. Unresolved disputes shall be subject to arbitration under the Arbitration and Conciliation Act, 1996, with proceedings held in Navi Mumbai, Maharashtra.',
    },
    {
        title: '11. Changes to These Terms',
        content: 'We may revise these Terms from time to time. We will notify you of material changes via in-app notification or email at least 14 days before they take effect. Continued use of the platform constitutes your acceptance of the revised Terms.',
    },
    {
        title: '12. Contact',
        content: 'For any questions regarding these Terms:\nEmail: support@auramikadaily.com\nAddress: Auramika Daily, Navi Mumbai, Maharashtra – 400001, India',
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
                    <p className="font-outfit text-xs tracking-widest uppercase text-brand-dark/40 mb-4">Last updated: April 2025</p>
                    <h1 className="font-playfair text-5xl md:text-6xl text-brand-dark mb-4">Terms of Service</h1>
                    <p className="font-outfit text-brand-dark/50 mb-12">Please read these terms carefully before using the Auramika Daily app or website. They govern your relationship with us.</p>
                    <div className="space-y-8 font-outfit text-brand-dark/70 leading-relaxed">
                        {sections.map((section, i) => (
                            <div key={i} className="border-b border-brand-dark/8 pb-8 last:border-0">
                                <h2 className="font-playfair text-xl text-brand-dark mb-3">{section.title}</h2>
                                <p className="text-sm whitespace-pre-line">{section.content}</p>
                            </div>
                        ))}
                    </div>
                    <div className="mt-12 p-6 bg-brand-dark text-brand-light">
                        <p className="font-outfit text-sm">Questions about these terms? <Link href="/contact" className="underline text-brand-accent hover:text-brand-light transition-colors">Contact us</Link> — we're happy to help.</p>
                    </div>
                </motion.div>
            </div>
            <Footer />
        </div>
    );
}
