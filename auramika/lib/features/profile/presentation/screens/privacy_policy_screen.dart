import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';
import 'terms_conditions_screen.dart' show LegalHeader, LegalSection, LegalSectionData;

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'Privacy Policy',
        showSearch: false,
        showCart: false,
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          LegalHeader(
            icon: Icons.shield_outlined,
            title: 'Privacy Policy',
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
    title: '1. Introduction',
    body:
        'AURAMIKA Pvt. Ltd. ("we", "our", "us") is committed to protecting your personal information. This Privacy Policy explains how we collect, use, store, and share your data when you use the AURAMIKA application. By using our service, you consent to the practices described in this policy.',
  ),
  LegalSectionData(
    title: '2. Information We Collect',
    body:
        'We collect the following types of information:\n\n• Identity & Contact: Name, email address, phone number, and profile details.\n• Transaction Data: Order history, payment method type (not full card numbers), and delivery addresses.\n• Usage Data: App interactions, browsing behaviour, search queries, and wishlist activity.\n• Device Information: Device type, OS version, unique device identifiers, and IP address.\n• Location Data: Approximate location for delivery estimates (only when permission is granted).',
  ),
  LegalSectionData(
    title: '3. How We Use Your Information',
    body:
        'Your data is used to:\n\n• Process and fulfil your orders.\n• Personalise your shopping experience and recommendations.\n• Send order updates, promotional offers, and service notifications.\n• Detect, prevent, and respond to fraud or security incidents.\n• Improve our platform through analytics and user research.\n• Comply with legal obligations under applicable Indian law.',
  ),
  LegalSectionData(
    title: '4. Data Sharing',
    body:
        'We do not sell your personal data. We may share information with:\n\n• Delivery Partners: To fulfil and track your orders.\n• Payment Processors: To securely process transactions (data is encrypted).\n• Analytics Providers: Anonymised or aggregated data to understand usage patterns.\n• Legal Authorities: When required by law, court order, or to protect rights and safety.',
  ),
  LegalSectionData(
    title: '5. Cookies & Tracking',
    body:
        'The AURAMIKA app uses analytics SDKs and local storage to enhance performance and remember your preferences. These tools help us understand how the app is used and improve the experience. You may limit tracking through your device settings.',
  ),
  LegalSectionData(
    title: '6. Data Retention',
    body:
        'We retain your personal data for as long as your account is active or as required to provide services. Transaction records may be retained for up to 7 years to comply with Indian financial regulations. You may request deletion of your account and associated data at any time.',
  ),
  LegalSectionData(
    title: '7. Your Rights',
    body:
        'Under applicable data protection laws, you have the right to:\n\n• Access the personal data we hold about you.\n• Correct inaccurate or incomplete data.\n• Request deletion of your account and data.\n• Withdraw consent for marketing communications.\n• Lodge a complaint with the relevant data protection authority.\n\nTo exercise any of these rights, contact us at privacy@auramika.in.',
  ),
  LegalSectionData(
    title: '8. Data Security',
    body:
        'We implement industry-standard security measures including encryption in transit (TLS), secure storage, access controls, and regular security audits. While we strive to protect your data, no method of transmission over the internet is 100% secure.',
  ),
  LegalSectionData(
    title: '9. Children\'s Privacy',
    body:
        'AURAMIKA is not intended for individuals under the age of 18. We do not knowingly collect personal data from minors. If we become aware that a minor has registered, we will promptly delete the account and associated data.',
  ),
  LegalSectionData(
    title: '10. Third-Party Links',
    body:
        'Our app may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to review their privacy policies before providing any personal information.',
  ),
  LegalSectionData(
    title: '11. Changes to This Policy',
    body:
        'We may update this Privacy Policy from time to time. We will notify you of significant changes via in-app notification or email. Your continued use of AURAMIKA after changes take effect constitutes your acceptance of the updated policy.',
  ),
  LegalSectionData(
    title: '12. Contact Us',
    body:
        'For privacy-related enquiries or to exercise your data rights, please contact:\n\nEmail: privacy@auramika.in\nPhone: +91 83692 96841\nAddress: AURAMIKA Pvt. Ltd., Navi Mumbai, Mumbai – 400001, Maharashtra, India.',
  ),
];
