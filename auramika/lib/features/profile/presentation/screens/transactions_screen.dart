import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';

enum _TxnType { debit, credit }

class _Txn {
  final String id;
  final String description;
  final String method;
  final double amount;
  final String date;
  final _TxnType type;

  const _Txn({
    required this.id,
    required this.description,
    required this.method,
    required this.amount,
    required this.date,
    required this.type,
  });
}

const _txns = [
  _Txn(
    id: 'TXN-5820',
    description: 'Payment — Gold Link Bracelet',
    method: 'UPI · GPay',
    amount: 699,
    date: '20 Feb 2025',
    type: _TxnType.debit,
  ),
  _Txn(
    id: 'TXN-5741',
    description: 'Payment — Kundan Chandbali',
    method: 'Credit Card · HDFC',
    amount: 1299,
    date: '5 Feb 2025',
    type: _TxnType.debit,
  ),
  _Txn(
    id: 'TXN-5601',
    description: 'Payment — Heavy Temple Necklace',
    method: 'Credit Card · HDFC',
    amount: 2499,
    date: '28 Dec 2024',
    type: _TxnType.debit,
  ),
  _Txn(
    id: 'TXN-5512',
    description: 'Payment — Pearl Choker',
    method: 'UPI · PhonePe',
    amount: 599,
    date: '15 Jan 2025',
    type: _TxnType.debit,
  ),
];

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'Transactions',
        showSearch: false,
        showCart: false,
        showBack: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── History header ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingM, 0,
                  AppConstants.paddingM, AppConstants.paddingS),
              child: Text('HISTORY',
                  style: AppTextStyles.categoryChip
                      .copyWith(fontSize: 10, letterSpacing: 3.0,
                          color: AppColors.textMuted)),
            ),
          ),

          // ── Transaction list ──────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingM),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _TxnTile(txn: _txns[i], index: i),
                childCount: _txns.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  final _Txn txn;
  final int index;
  const _TxnTile({required this.txn, required this.index});

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.type == _TxnType.credit;
    final amountColor =
        isCredit ? const Color(0xFF2E7D32) : AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingM, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: amountColor.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCredit
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            size: 18,
            color: amountColor,
          ),
        ),
        title: Text(txn.description,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text('${txn.method}  ·  ${txn.date}',
              style: AppTextStyles.bodySmall
                  .copyWith(fontSize: 10, color: AppColors.textMuted)),
        ),
        trailing: Text(
          '${isCredit ? '+' : '-'}₹${txn.amount.toStringAsFixed(0)}',
          style: AppTextStyles.priceTag
              .copyWith(fontSize: 14, color: amountColor),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: AppConstants.animNormal)
        .slideX(begin: 0.03, end: 0);
  }
}
