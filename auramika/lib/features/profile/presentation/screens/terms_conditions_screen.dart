import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'Terms & Conditions',
        showSearch: false,
        showCart: false,
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          LegalHeader(
            icon: Icons.gavel_rounded,
            title: 'Terms & Conditions',
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
    title: '1. Acceptance of Terms',
    body:
        'By accessing or using the AURAMIKA application, you agree to be bound by these Terms & Conditions. If you do not agree to all the terms, you may not use our services. These terms apply to all visitors, users, and others who access or use the service.',
  ),
  LegalSectionData(
    title: '2. Use of the Platform',
    body:
        'AURAMIKA grants you a limited, non-exclusive, non-transferable licence to access and use the platform for personal, non-commercial purposes. You agree not to misuse our services, attempt to gain unauthorised access, or disrupt the functionality of the platform in any way.',
  ),
  LegalSectionData(
    title: '3. Account Responsibility',
    body:
        'You are responsible for maintaining the confidentiality of your account credentials. Any activity conducted through your account is your responsibility. Notify us immediately at support@auramika.in if you suspect any unauthorised use of your account.',
  ),
  LegalSectionData(
    title: '4. Product Listings & Pricing',
    body:
        'All products listed on AURAMIKA are subject to availability. Prices are displayed in Indian Rupees (INR) and include applicable taxes unless stated otherwise. We reserve the right to modify prices at any time without prior notice.',
  ),
  LegalSectionData(
    title: '5. Orders & Payments',
    body:
        'By placing an order, you confirm that the information provided is accurate and complete. AURAMIKA reserves the right to cancel or refuse any order at its sole discretion. Payment must be completed in full before dispatch of goods.',
  ),
  LegalSectionData(
    title: '6. Shipping & Delivery',
    body:
        'Estimated delivery timelines are indicative and not guaranteed. AURAMIKA is not liable for delays caused by shipping partners, customs, or circumstances beyond our control. Risk of loss passes to you upon delivery.',
  ),
  LegalSectionData(
    title: '7. Returns & Refunds',
    body:
        'Returns are accepted within 7 days of delivery for eligible items in original, unworn condition with tags intact. Custom-made, engraved, or personalised jewellery is non-returnable. Refunds are processed within 7–10 business days to the original payment method.',
  ),
  LegalSectionData(
    title: '8. Intellectual Property',
    body:
        'All content on AURAMIKA, including text, images, logos, and designs, is the property of AURAMIKA or its content suppliers and is protected by applicable intellectual property laws. Reproduction or redistribution without prior written consent is prohibited.',
  ),
  LegalSectionData(
    title: '9. Limitation of Liability',
    body:
        'AURAMIKA shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the platform or the inability to access it. Our total liability shall not exceed the amount paid by you for the specific transaction giving rise to the claim.',
  ),
  LegalSectionData(
    title: '10. Governing Law',
    body:
        'These Terms & Conditions are governed by and construed in accordance with the laws of India. Any disputes arising shall be subject to the exclusive jurisdiction of the courts in Bengaluru, Karnataka.',
  ),
  LegalSectionData(
    title: '11. Changes to Terms',
    body:
        'AURAMIKA reserves the right to modify these Terms & Conditions at any time. Continued use of the platform after changes constitutes acceptance of the revised terms. We encourage you to review these terms periodically.',
  ),
  LegalSectionData(
    title: '12. Contact Us',
    body:
        'If you have any questions about these Terms & Conditions, please contact us at:\n\nEmail: contact@swarnastra.com\nPhone: +91 83692 96841\nAddress: AURAMIKA Pvt. Ltd., Navi Mumbai, Mumbai – 400001, Maharashtra, India.',
  ),
];

class LegalSectionData {
  final String title;
  final String body;
  const LegalSectionData({required this.title, required this.body});
}

class LegalHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const LegalHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.forestGreen,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: AppColors.gold, size: 24),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.55),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LegalSection extends StatelessWidget {
  final LegalSectionData section;
  const LegalSection({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.forestGreen,
              ),
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              section.body,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
