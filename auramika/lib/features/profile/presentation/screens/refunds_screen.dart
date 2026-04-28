import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';

enum _RefundStatus { processed, pending, rejected }

class _Refund {
  final String refId;
  final String orderId;
  final String itemName;
  final double amount;
  final String date;
  final _RefundStatus status;
  final String reason;

  const _Refund({
    required this.refId,
    required this.orderId,
    required this.itemName,
    required this.amount,
    required this.date,
    required this.status,
    required this.reason,
  });
}

const _refunds = [
  _Refund(
    refId: 'REF-2025-001',
    orderId: 'ORD-2025-003',
    itemName: 'Kundan Chandbali',
    amount: 1299,
    date: '8 Feb 2025',
    status: _RefundStatus.pending,
    reason: 'Item received damaged',
  ),
];

class RefundsScreen extends StatelessWidget {
  const RefundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'Refunds',
        showSearch: false,
        showCart: false,
        showBack: true,
      ),
      body: _refunds.isEmpty
          ? _EmptyState()
          : ListView(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              children: [
                // ── Summary banner ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    border: Border.all(
                        color: AppColors.forestGreen.withValues(alpha: 0.2),
                        width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 18, color: AppColors.forestGreen),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Refunds are credited back to the original payment method within 5–7 business days.',
                          style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                ...List.generate(
                  _refunds.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.paddingM),
                    child: _RefundCard(refund: _refunds[i], index: i),
                  ),
                ),
              ],
            ),
    );
  }
}

class _RefundCard extends StatelessWidget {
  final _Refund refund;
  final int index;
  const _RefundCard({required this.refund, required this.index});

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor, statusIcon) = switch (refund.status) {
      _RefundStatus.processed =>
        ('Refund Processed', const Color(0xFF2E7D32), Icons.check_circle_outline_rounded),
      _RefundStatus.pending =>
        ('Refund Pending', AppColors.brass, Icons.hourglass_top_rounded),
      _RefundStatus.rejected =>
        ('Rejected', AppColors.terraCotta, Icons.cancel_outlined),
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status bar ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingM, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.radiusS)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(statusLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ],
            ),
          ),

          // ── Details ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(refund.itemName,
                    style:
                        AppTextStyles.titleSmall.copyWith(fontSize: 13)),
                const SizedBox(height: 6),
                _DetailRow('Order', refund.orderId),
                _DetailRow('Refund ID', refund.refId),
                _DetailRow('Reason', refund.reason),
                _DetailRow('Date', refund.date),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Refund Amount',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted, fontSize: 12)),
                    Text(
                      '₹${refund.amount.toStringAsFixed(0)}',
                      style: AppTextStyles.priceTag.copyWith(
                          fontSize: 15,
                          color: refund.status == _RefundStatus.processed
                              ? const Color(0xFF2E7D32)
                              : AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted, fontSize: 11)),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.replay_rounded,
              size: 52,
              color: AppColors.textMuted.withValues(alpha: 0.35)),
          const SizedBox(height: AppConstants.paddingM),
          Text('No refund requests',
              style: AppTextStyles.titleSmall
                  .copyWith(color: AppColors.textMuted)),
          const SizedBox(height: AppConstants.paddingS),
          Text('Your refund history will appear here',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
