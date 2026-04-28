import { Router, Request, Response } from 'express';

const router = Router();

const html = (title: string, lastUpdated: string, sections: { heading: string; body: string }[]) => `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${title} — AURAMIKA</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      color: #1a1a1a;
      background: #fafaf8;
      max-width: 760px;
      margin: 0 auto;
      padding: 48px 24px 80px;
      line-height: 1.7;
    }
    header { margin-bottom: 40px; border-bottom: 1px solid #e5e0d8; padding-bottom: 24px; }
    header h1 { font-size: 2rem; font-weight: 700; letter-spacing: -0.02em; color: #111; }
    header p { margin-top: 6px; color: #888; font-size: 0.9rem; }
    section { margin-top: 32px; }
    section h2 { font-size: 1.05rem; font-weight: 600; color: #111; margin-bottom: 10px; }
    section p { color: #444; white-space: pre-line; }
    footer { margin-top: 64px; border-top: 1px solid #e5e0d8; padding-top: 20px; font-size: 0.85rem; color: #999; }
    a { color: #5a7a5a; }
  </style>
</head>
<body>
  <header>
    <h1>${title}</h1>
    <p>Last updated: ${lastUpdated} &nbsp;·&nbsp; AURAMIKA Pvt. Ltd.</p>
  </header>
  ${sections.map(s => `<section>\n    <h2>${s.heading}</h2>\n    <p>${s.body}</p>\n  </section>`).join('\n  ')}
  <footer>
    &copy; ${new Date().getFullYear()} AURAMIKA Pvt. Ltd. &nbsp;·&nbsp;
    <a href="/privacy">Privacy Policy</a> &nbsp;·&nbsp;
    <a href="/terms">Terms of Service</a>
  </footer>
</body>
</html>`;

const PRIVACY_SECTIONS = [
  {
    heading: '1. Introduction',
    body: 'AURAMIKA Pvt. Ltd. ("we", "our", "us") is committed to protecting your personal information. This Privacy Policy explains how we collect, use, store, and share your data when you use the AURAMIKA application. By using our service, you consent to the practices described in this policy.',
  },
  {
    heading: '2. Information We Collect',
    body: 'We collect the following types of information:\n\n• Identity & Contact: Name, email address, phone number, and profile details.\n• Transaction Data: Order history, payment method type (not full card numbers), and delivery addresses.\n• Usage Data: App interactions, browsing behaviour, search queries, and wishlist activity.\n• Device Information: Device type, OS version, unique device identifiers, and IP address.\n• Location Data: Approximate location for delivery estimates (only when permission is granted).',
  },
  {
    heading: '3. How We Use Your Information',
    body: 'Your data is used to:\n\n• Process and fulfil your orders.\n• Personalise your shopping experience and recommendations.\n• Send order updates, promotional offers, and service notifications.\n• Detect, prevent, and respond to fraud or security incidents.\n• Improve our platform through analytics and user research.\n• Comply with legal obligations under applicable Indian law.',
  },
  {
    heading: '4. Data Sharing',
    body: 'We do not sell your personal data. We may share information with:\n\n• Delivery Partners: To fulfil and track your orders.\n• Payment Processors: To securely process transactions (data is encrypted).\n• Analytics Providers: Anonymised or aggregated data to understand usage patterns.\n• Legal Authorities: When required by law, court order, or to protect rights and safety.',
  },
  {
    heading: '5. Cookies & Tracking',
    body: 'The AURAMIKA app uses analytics SDKs and local storage to enhance performance and remember your preferences. These tools help us understand how the app is used and improve the experience. You may limit tracking through your device settings.',
  },
  {
    heading: '6. Data Retention',
    body: 'We retain your personal data for as long as your account is active or as required to provide services. Transaction records may be retained for up to 7 years to comply with Indian financial regulations. You may request deletion of your account and associated data at any time.',
  },
  {
    heading: '7. Your Rights',
    body: 'Under applicable data protection laws, you have the right to:\n\n• Access the personal data we hold about you.\n• Correct inaccurate or incomplete data.\n• Request deletion of your account and data.\n• Withdraw consent for marketing communications.\n• Lodge a complaint with the relevant data protection authority.\n\nTo exercise any of these rights, contact us at privacy@auramika.in.',
  },
  {
    heading: '8. Data Security',
    body: 'We implement industry-standard security measures including encryption in transit (TLS), secure storage, access controls, and regular security audits. While we strive to protect your data, no method of transmission over the internet is 100% secure.',
  },
  {
    heading: "9. Children's Privacy",
    body: 'AURAMIKA is not intended for individuals under the age of 18. We do not knowingly collect personal data from minors. If we become aware that a minor has registered, we will promptly delete the account and associated data.',
  },
  {
    heading: '10. Third-Party Links',
    body: 'Our app may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to review their privacy policies before providing any personal information.',
  },
  {
    heading: '11. Changes to This Policy',
    body: 'We may update this Privacy Policy from time to time. We will notify you of significant changes via in-app notification or email. Your continued use of AURAMIKA after changes take effect constitutes your acceptance of the updated policy.',
  },
  {
    heading: '12. Contact Us',
    body: 'For privacy-related enquiries or to exercise your data rights, please contact:\n\nEmail: privacy@auramika.in\nPhone: +91 83692 96841\nAddress: AURAMIKA Pvt. Ltd., Navi Mumbai, Mumbai – 400001, Maharashtra, India.',
  },
];

const TERMS_SECTIONS = [
  {
    heading: '1. Service Description',
    body: 'AURAMIKA is a curated jewellery marketplace that connects verified artisans and brands with customers across India. Our platform facilitates discovery, purchase, and delivery of jewellery products through our mobile application.',
  },
  {
    heading: '2. Eligibility',
    body: 'You must be at least 18 years of age and capable of entering into a legally binding agreement to use AURAMIKA. By using our service, you represent and warrant that you meet these eligibility requirements.',
  },
  {
    heading: '3. User Accounts',
    body: 'To access certain features, you must register for an account. You agree to provide accurate and complete information, keep your credentials secure, and notify us of any breach or unauthorised use. AURAMIKA reserves the right to suspend or terminate accounts that violate these terms.',
  },
  {
    heading: '4. Vendor Conduct',
    body: 'Vendors listing products on AURAMIKA must ensure their listings are accurate, comply with applicable laws, and meet our quality and authenticity standards. Fraudulent listings, counterfeit goods, or misleading representations will result in immediate removal and legal action.',
  },
  {
    heading: '5. Prohibited Activities',
    body: 'You agree not to: reverse-engineer or copy any part of the platform; use automated tools to scrape data; post false or misleading reviews; engage in any activity that interferes with or disrupts the service; or violate any applicable local, national, or international law.',
  },
  {
    heading: '6. Content Standards',
    body: 'Any content you submit — including reviews, photos, or communications — must be lawful, respectful, and accurate. AURAMIKA reserves the right to remove any content that violates community standards or applicable laws without prior notice.',
  },
  {
    heading: '7. Service Availability',
    body: 'AURAMIKA strives for 99.9% uptime but does not guarantee uninterrupted access. Scheduled maintenance, technical issues, or force majeure events may temporarily affect availability. We will endeavour to notify users of planned downtime in advance.',
  },
  {
    heading: '8. Third-Party Services',
    body: 'Our platform integrates with third-party services including payment gateways, delivery partners, and analytics providers. Use of these services is subject to their respective terms and privacy policies. AURAMIKA is not responsible for third-party service conduct.',
  },
  {
    heading: '9. Termination',
    body: 'Either party may terminate the service relationship at any time. You may delete your account via Profile → Delete Account. AURAMIKA may terminate or suspend access without notice if you breach these Terms of Service.',
  },
  {
    heading: '10. Dispute Resolution',
    body: 'Any disputes arising from or related to these Terms of Service shall first be attempted to be resolved through good-faith negotiation. If unresolved within 30 days, disputes shall be referred to arbitration under the Arbitration and Conciliation Act, 1996 (India).',
  },
  {
    heading: '11. Amendments',
    body: 'AURAMIKA may update these Terms of Service from time to time. Material changes will be communicated via in-app notification or email. Continued use of the service following notification constitutes your acceptance of the updated terms.',
  },
  {
    heading: '12. Contact',
    body: 'For enquiries regarding these Terms of Service, reach us at:\n\nEmail: privacy@auramika.in\nPhone: +91 83692 96841\nAddress: AURAMIKA Pvt. Ltd., Navi Mumbai, Mumbai – 400001, Maharashtra, India.',
  },
];

router.get('/privacy', (_req: Request, res: Response) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.send(html('Privacy Policy', 'January 2025', PRIVACY_SECTIONS));
});

router.get('/terms', (_req: Request, res: Response) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.send(html('Terms of Service', 'January 2025', TERMS_SECTIONS));
});

export default router;
