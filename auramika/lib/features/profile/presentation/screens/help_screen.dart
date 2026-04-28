import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

const _faqs = [
  _FaqItem(
    question: 'How do I track my order?',
    answer:
        'Go to Profile → Orders to see real-time tracking for all your purchases. You will also receive SMS and email updates at every stage.',
  ),
  _FaqItem(
    question: 'What is your return policy?',
    answer:
        'We offer a 7-day easy return policy for most items. Custom-made and personalised pieces are non-returnable. Initiate a return from Profile → Orders.',
  ),
  _FaqItem(
    question: 'How long does delivery take?',
    answer:
        'Standard delivery takes 5–7 business days. Express delivery (1–2 days) is available in select cities at checkout.',
  ),
  _FaqItem(
    question: 'Are the products authentic?',
    answer:
        'Every vendor on AURAMIKA is verified and their products undergo quality checks. Hallmarked gold and certified silver items include authenticity certificates.',
  ),
  _FaqItem(
    question: 'How do I use a gift card?',
    answer:
        'Enter your gift card code at checkout in the "Gift Card / Promo Code" field. The balance will be applied automatically.',
  ),
  _FaqItem(
    question: 'Can I cancel an order?',
    answer:
        'Orders can be cancelled within 2 hours of placement if they haven\'t been dispatched yet. Go to Profile → Orders and tap Cancel.',
  ),
];

Future<void> _launchUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open. Please try again.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
          ),
          backgroundColor: AppColors.terraCotta,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'Help',
        showSearch: false,
        showCart: false,
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          // ── Contact options ────────────────────────────────────────
          _ContactCard(),
          const SizedBox(height: AppConstants.paddingL),

          Text(
            'FREQUENTLY ASKED',
            style: AppTextStyles.categoryChip.copyWith(
              fontSize: 10,
              letterSpacing: 3.0,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),

          // ── FAQ accordion ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              border: Border.all(color: AppColors.divider, width: 0.5),
            ),
            child: Column(
              children: List.generate(_faqs.length, (i) {
                return Column(
                  children: [
                    _FaqTile(faq: _faqs[i], index: i),
                    if (i < _faqs.length - 1)
                      Divider(
                        height: 1,
                        color: AppColors.divider,
                        thickness: 0.5,
                      ),
                  ],
                );
              }),
            ),
          ).animate().fadeIn(duration: AppConstants.animNormal),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.forestGreen,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need more help?',
            style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Our support team is here Mon–Sat, 10 AM–7 PM IST.',
            style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.65),
                fontSize: 12),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            children: [
              Expanded(
                child: _ContactButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Live Chat',
                  onTap: () => _launchUrl(
                    context,
                    'https://wa.me/918369296841?text=Hi%2C%20I%20need%20help%20with%20my%20AURAMIKA%20order.',
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingS),
              Expanded(
                child: _ContactButton(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email Us',
                  onTap: () => _launchUrl(
                    context,
                    'mailto:contact@swarnastra.com?subject=Support%20Request&body=Hi%20AURAMIKA%20team%2C',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppConstants.animNormal).slideY(begin: -0.04, end: 0);
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppConstants.radiusXS),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.gold),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final _FaqItem faq;
  final int index;
  const _FaqTile({required this.faq, required this.index});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.faq.question,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: AppConstants.paddingS),
              Text(
                widget.faq.answer,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
