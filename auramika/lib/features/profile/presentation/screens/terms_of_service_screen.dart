import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';
import 'terms_conditions_screen.dart' show LegalHeader, LegalSection, LegalSectionData;

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'Terms of Service',
        showSearch: false,
        showCart: false,
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          LegalHeader(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Last updated: January 2025',
          ).animate().fadeIn(duration: AppConstants.animNormal).slideY(begin: -0.04, end: 0),
          const SizedBox(height: AppConstants.paddingM),
          ..._sections.map(
            (s) => LegalSection(section: s)
                .animate()
                .fadeIn(duration: AppConstants.animNormal),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

const _sections = [
  LegalSectionData(
    title: '1. Service Description',
    body:
        'AURAMIKA is a curated jewellery marketplace that connects verified artisans and brands with customers across India. Our platform facilitates discovery, purchase, and delivery of jewellery products through our mobile application.',
  ),
  LegalSectionData(
    title: '2. Eligibility',
    body:
        'You must be at least 18 years of age and capable of entering into a legally binding agreement to use AURAMIKA. By using our service, you represent and warrant that you meet these eligibility requirements.',
  ),
  LegalSectionData(
    title: '3. User Accounts',
    body:
        'To access certain features, you must register for an account. You agree to provide accurate and complete information, keep your credentials secure, and notify us of any breach or unauthorised use. AURAMIKA reserves the right to suspend or terminate accounts that violate these terms.',
  ),
  LegalSectionData(
    title: '4. Vendor Conduct',
    body:
        'Vendors listing products on AURAMIKA must ensure their listings are accurate, comply with applicable laws, and meet our quality and authenticity standards. Fraudulent listings, counterfeit goods, or misleading representations will result in immediate removal and legal action.',
  ),
  LegalSectionData(
    title: '5. Prohibited Activities',
    body:
        'You agree not to: reverse-engineer or copy any part of the platform; use automated tools to scrape data; post false or misleading reviews; engage in any activity that interferes with or disrupts the service; or violate any applicable local, national, or international law.',
  ),
  LegalSectionData(
    title: '6. Content Standards',
    body:
        'Any content you submit — including reviews, photos, or communications — must be lawful, respectful, and accurate. AURAMIKA reserves the right to remove any content that violates community standards or applicable laws without prior notice.',
  ),
  LegalSectionData(
    title: '7. Service Availability',
    body:
        'AURAMIKA strives for 99.9% uptime but does not guarantee uninterrupted access. Scheduled maintenance, technical issues, or force majeure events may temporarily affect availability. We will endeavour to notify users of planned downtime in advance.',
  ),
  LegalSectionData(
    title: '8. Third-Party Services',
    body:
        'Our platform integrates with third-party services including payment gateways, delivery partners, and analytics providers. Use of these services is subject to their respective terms and privacy policies. AURAMIKA is not responsible for third-party service conduct.',
  ),
  LegalSectionData(
    title: '9. Termination',
    body:
        'Either party may terminate the service relationship at any time. You may delete your account via Profile → Delete Account. AURAMIKA may terminate or suspend access without notice if you breach these Terms of Service.',
  ),
  LegalSectionData(
    title: '10. Dispute Resolution',
    body:
        'Any disputes arising from or related to these Terms of Service shall first be attempted to be resolved through good-faith negotiation. If unresolved within 30 days, disputes shall be referred to arbitration under the Arbitration and Conciliation Act, 1996 (India).',
  ),
  LegalSectionData(
    title: '11. Amendments',
    body:
        'AURAMIKA may update these Terms of Service from time to time. Material changes will be communicated via in-app notification or email. Continued use of the service following notification constitutes your acceptance of the updated terms.',
  ),
  LegalSectionData(
    title: '12. Contact',
    body:
        'For enquiries regarding these Terms of Service, reach us at:\n\nEmail: contact@swarnastra.com\nPhone: +91 83692 96841\nAddress: AURAMIKA Pvt. Ltd., Navi Mumbai, Mumbai – 400001, Maharashtra, India.',
  ),
];
