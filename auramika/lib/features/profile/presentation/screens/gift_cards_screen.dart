import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';

class _GiftCard {
  final String code;
  final double balance;
  final double originalValue;
  final String expiry;
  final bool isActive;

  const _GiftCard({
    required this.code,
    required this.balance,
    required this.originalValue,
    required this.expiry,
    required this.isActive,
  });
}

const _giftCards = [
  _GiftCard(
    code: 'AURA-GIFT-2025-X4K9',
    balance: 750,
    originalValue: 1000,
    expiry: '31 Dec 2025',
    isActive: true,
  ),
  _GiftCard(
    code: 'AURA-GIFT-2024-Z2P1',
    balance: 0,
    originalValue: 500,
    expiry: '31 Dec 2024',
    isActive: false,
  ),
];

class GiftCardsScreen extends StatelessWidget {
  const GiftCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'Gift Cards',
        showSearch: false,
        showCart: false,
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          // ── Redeem banner ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard_outlined,
                    size: 18, color: AppColors.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Gift cards can be redeemed at checkout. Balance never expires on active cards.',
                    style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: AppConstants.animNormal),

          // ── Redeem input ───────────────────────────────────────────
          _RedeemInput(),
          const SizedBox(height: AppConstants.paddingL),

          if (_giftCards.isNotEmpty) ...[
            Text(
              'YOUR CARDS',
              style: AppTextStyles.categoryChip.copyWith(
                fontSize: 10,
                letterSpacing: 3.0,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppConstants.paddingS),
            ...List.generate(
              _giftCards.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
                child: _GiftCardTile(card: _giftCards[i], index: i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RedeemInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Redeem a Gift Card',
              style: AppTextStyles.titleSmall.copyWith(fontSize: 13)),
          const SizedBox(height: AppConstants.paddingS),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                    border: Border.all(
                        color: AppColors.divider.withValues(alpha: 0.8),
                        width: 0.5),
                  ),
                  child: TextField(
                    style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12, letterSpacing: 1.2),
                    decoration: InputDecoration(
                      hintText: 'Enter gift card code',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingS),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingS),
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusXS),
                  ),
                  child: Center(
                    child: Text(
                      'APPLY',
                      style: AppTextStyles.categoryChip.copyWith(
                        fontSize: 11,
                        color: AppColors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppConstants.animNormal);
  }
}

class _GiftCardTile extends StatelessWidget {
  final _GiftCard card;
  final int index;
  const _GiftCardTile({required this.card, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: card.isActive
            ? AppColors.forestGreen
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(
            color: card.isActive
                ? Colors.transparent
                : AppColors.divider,
            width: 0.5),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.code,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  color: card.isActive
                      ? AppColors.white.withValues(alpha: 0.7)
                      : AppColors.textMuted,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: card.isActive
                      ? AppColors.gold.withValues(alpha: 0.2)
                      : AppColors.divider.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  card.isActive ? 'ACTIVE' : 'USED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: card.isActive ? AppColors.gold : AppColors.textMuted,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            '₹${card.balance.toStringAsFixed(0)}',
            style: AppTextStyles.priceTag.copyWith(
              fontSize: 26,
              color: card.isActive ? AppColors.gold : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'of ₹${card.originalValue.toStringAsFixed(0)} original value',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: card.isActive
                  ? AppColors.white.withValues(alpha: 0.55)
                  : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            'Expires ${card.expiry}',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              color: card.isActive
                  ? AppColors.white.withValues(alpha: 0.45)
                  : AppColors.textMuted.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: AppConstants.animNormal)
        .slideY(begin: 0.04, end: 0);
  }
}
