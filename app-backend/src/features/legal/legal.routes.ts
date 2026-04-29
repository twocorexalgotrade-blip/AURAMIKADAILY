import { Router, Request, Response } from 'express';

const router = Router();

// GET /legal/privacy — Privacy Policy
router.get('/privacy', (_req: Request, res: Response) => {
  res.json({
    title: 'Privacy Policy',
    lastUpdated: 'January 2025',
    company: 'AURAMIKA Pvt. Ltd.',
    contact: 'privacy@auramika.in',
    sections: [
      { heading: 'Information We Collect', body: 'Identity, contact, transaction, usage, device, and approximate location data.' },
      { heading: 'How We Use Your Data', body: 'To process orders, personalise experience, send updates, detect fraud, and comply with Indian law.' },
      { heading: 'Data Sharing', body: 'We do not sell your data. Shared only with delivery partners, payment processors, and as required by law.' },
      { heading: 'Your Rights', body: 'Access, correct, or delete your data. Contact: privacy@auramika.in.' },
      { heading: 'Retention', body: 'Data retained while account is active or as required by law (up to 7 years for transactions).' },
    ],
  });
});

// GET /legal/terms — Terms of Service
router.get('/terms', (_req: Request, res: Response) => {
  res.json({
    title: 'Terms of Service',
    lastUpdated: 'January 2025',
    company: 'AURAMIKA Pvt. Ltd.',
    contact: 'privacy@auramika.in',
    sections: [
      { heading: 'Eligibility', body: 'Must be 18+ and capable of a legally binding agreement.' },
      { heading: 'User Accounts', body: 'Provide accurate information and keep credentials secure.' },
      { heading: 'Prohibited Activities', body: 'No reverse-engineering, scraping, false reviews, or disruptive activity.' },
      { heading: 'Dispute Resolution', body: 'Good-faith negotiation, then arbitration under Indian Arbitration Act 1996.' },
    ],
  });
});

export default router;
