const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Serve all static assets (HTML, CSS, JS, images) from the repo root
app.use(express.static(path.join(__dirname)));

// ── Dynamic legal routes (used by App Store / Play Store URLs) ──────────────

const legalHtml = (title, lastUpdated, sections) => `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${title} — AURAMIKA</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      color: #1a1a1a; background: #fafaf8;
      max-width: 760px; margin: 0 auto;
      padding: 48px 24px 80px; line-height: 1.7;
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
  { heading: '1. Introduction', body: 'AURAMIKA Pvt. Ltd. ("we", "our", "us") is committed to protecting your personal information. This Privacy Policy explains how we collect, use, store, and share your data when you use the AURAMIKA application.' },
  { heading: '2. Information We Collect', body: 'We collect: Identity & Contact (name, email, phone), Transaction Data (order history, payment type, delivery addresses), Usage Data (app interactions, search queries), Device Information, and Location Data (approximate, only when permission granted).' },
  { heading: '3. How We Use Your Information', body: 'Your data is used to process orders, personalise your experience, send order updates and promotions, detect fraud, improve our platform, and comply with applicable Indian law.' },
  { heading: '4. Data Sharing', body: 'We do not sell your data. We may share with Delivery Partners (to fulfil orders), Payment Processors (encrypted), Analytics Providers (anonymised), and Legal Authorities (when required by law).' },
  { heading: '5. Cookies & Tracking', body: 'The AURAMIKA app uses analytics SDKs and local storage to enhance performance and remember preferences. You may limit tracking through your device settings.' },
  { heading: '6. Data Retention', body: 'We retain personal data as long as your account is active or as required by law. Transaction records may be retained for up to 7 years per Indian financial regulations. You may request deletion at any time.' },
  { heading: '7. Your Rights', body: 'You have the right to access, correct, or delete your data, withdraw marketing consent, and lodge complaints with relevant authorities. Contact: privacy@auramika.in.' },
  { heading: '8. Data Security', body: 'We implement TLS encryption, secure storage, access controls, and regular audits. No internet transmission is 100% secure.' },
  { heading: "9. Children's Privacy", body: 'AURAMIKA is not intended for users under 18. We do not knowingly collect data from minors.' },
  { heading: '10. Third-Party Links', body: 'Our app may link to third-party services. We are not responsible for their privacy practices.' },
  { heading: '11. Changes to This Policy', body: 'We may update this policy and will notify you of significant changes via in-app notification or email.' },
  { heading: '12. Contact Us', body: 'Email: privacy@auramika.in\nPhone: +91 83692 96841\nAddress: AURAMIKA Pvt. Ltd., Navi Mumbai, Maharashtra – 400001, India.' },
];

const TERMS_SECTIONS = [
  { heading: '1. Service Description', body: 'AURAMIKA is a curated jewellery marketplace connecting verified artisans and brands with customers across India.' },
  { heading: '2. Eligibility', body: 'You must be at least 18 years old and capable of entering a legally binding agreement to use AURAMIKA.' },
  { heading: '3. User Accounts', body: 'You agree to provide accurate information, keep credentials secure, and notify us of any breach. AURAMIKA may suspend accounts that violate these terms.' },
  { heading: '4. Vendor Conduct', body: 'Vendors must ensure accurate listings that comply with applicable laws. Fraudulent or counterfeit listings will result in removal and legal action.' },
  { heading: '5. Prohibited Activities', body: 'You agree not to reverse-engineer the platform, scrape data, post false reviews, or engage in activities that disrupt the service or violate applicable law.' },
  { heading: '6. Content Standards', body: 'All submitted content must be lawful, respectful, and accurate. AURAMIKA may remove content violating community standards without notice.' },
  { heading: '7. Service Availability', body: 'AURAMIKA strives for 99.9% uptime but does not guarantee uninterrupted access. We will endeavour to notify users of planned downtime.' },
  { heading: '8. Third-Party Services', body: 'We integrate with payment gateways, delivery partners, and analytics providers. Use is subject to their respective terms.' },
  { heading: '9. Termination', body: 'Either party may terminate at any time. You may delete your account via Profile → Delete Account.' },
  { heading: '10. Dispute Resolution', body: 'Disputes shall first be resolved through good-faith negotiation, then arbitration under the Arbitration and Conciliation Act, 1996 (India).' },
  { heading: '11. Amendments', body: 'AURAMIKA may update these terms. Continued use after notification constitutes acceptance.' },
  { heading: '12. Contact', body: 'Email: privacy@auramika.in\nPhone: +91 83692 96841\nAddress: AURAMIKA Pvt. Ltd., Navi Mumbai, Maharashtra – 400001, India.' },
];

app.get('/privacy', (_req, res) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.send(legalHtml('Privacy Policy', 'January 2025', PRIVACY_SECTIONS));
});

app.get('/terms', (_req, res) => {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.send(legalHtml('Terms of Service', 'January 2025', TERMS_SECTIONS));
});

// Fallback: serve index.html for any unmatched route
app.get('*', (_req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`AURAMIKA server running on port ${PORT}`);
});
