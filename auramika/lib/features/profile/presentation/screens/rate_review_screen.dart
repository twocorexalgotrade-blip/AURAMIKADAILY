import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';

class _ReviewItem {
  final String productName;
  final String vendorName;
  final String orderId;
  final String date;
  final int? rating;
  final String? review;

  const _ReviewItem({
    required this.productName,
    required this.vendorName,
    required this.orderId,
    required this.date,
    this.rating,
    this.review,
  });
}

const _pendingReviews = [
  _ReviewItem(
    productName: 'Oxidised Silver Jhumkas',
    vendorName: 'Silver Artisan Co.',
    orderId: 'ORD-2025-004',
    date: '18 Mar 2025',
  ),
];

const _submittedReviews = [
  _ReviewItem(
    productName: 'Temple Necklace Set',
    vendorName: 'Kanchipuram Crafts',
    orderId: 'ORD-2025-002',
    date: '2 Jan 2025',
    rating: 5,
    review: 'Absolutely stunning craftsmanship. The gold finish is flawless and the weight feels premium.',
  ),
];

class RateReviewScreen extends StatelessWidget {
  const RateReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'Rate & Review',
        showSearch: false,
        showCart: false,
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          if (_pendingReviews.isNotEmpty) ...[
            Text(
              'PENDING REVIEWS',
              style: AppTextStyles.categoryChip.copyWith(
                fontSize: 10,
                letterSpacing: 3.0,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppConstants.paddingS),
            ...List.generate(
              _pendingReviews.length,
              (i) => Padding(
                padding:
                    const EdgeInsets.only(bottom: AppConstants.paddingM),
                child: _PendingReviewCard(
                    item: _pendingReviews[i], index: i),
              ),
            ),
            const SizedBox(height: AppConstants.paddingM),
          ],
          if (_submittedReviews.isNotEmpty) ...[
            Text(
              'YOUR REVIEWS',
              style: AppTextStyles.categoryChip.copyWith(
                fontSize: 10,
                letterSpacing: 3.0,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: AppConstants.paddingS),
            ...List.generate(
              _submittedReviews.length,
              (i) => Padding(
                padding:
                    const EdgeInsets.only(bottom: AppConstants.paddingM),
                child: _SubmittedReviewCard(
                    item: _submittedReviews[i],
                    index: i + _pendingReviews.length),
              ),
            ),
          ],
          if (_pendingReviews.isEmpty && _submittedReviews.isEmpty)
            _EmptyState(),
        ],
      ),
    );
  }
}

class _PendingReviewCard extends StatelessWidget {
  final _ReviewItem item;
  final int index;
  const _PendingReviewCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.3), width: 0.5),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'AWAITING REVIEW',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(item.productName,
              style: AppTextStyles.titleSmall.copyWith(fontSize: 13)),
          const SizedBox(height: 3),
          Text(item.vendorName,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            '${item.orderId}  ·  ${item.date}',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textMuted, fontSize: 10),
          ),
          const SizedBox(height: AppConstants.paddingM),
          GestureDetector(
            onTap: () => _showReviewSheet(context, item),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.forestGreen,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusXS),
              ),
              child: Center(
                child: Text(
                  'WRITE A REVIEW',
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
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: AppConstants.animNormal)
        .slideY(begin: 0.04, end: 0);
  }

  void _showReviewSheet(BuildContext context, _ReviewItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppConstants.radiusM)),
      ),
      builder: (_) => _ReviewSheet(item: item),
    );
  }
}

class _ReviewSheet extends StatefulWidget {
  final _ReviewItem item;
  const _ReviewSheet({required this.item});

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppConstants.paddingM,
          AppConstants.paddingM,
          AppConstants.paddingM,
          MediaQuery.of(context).viewInsets.bottom +
              AppConstants.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.item.productName,
              style: AppTextStyles.titleSmall.copyWith(fontSize: 14)),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 36,
                    color: AppColors.gold,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppConstants.radiusXS),
              border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.8), width: 0.5),
            ),
            child: TextField(
              maxLines: 4,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Share your experience with this product...',
                hintStyle: AppTextStyles.bodySmall
                    .copyWith(fontSize: 12, color: AppColors.textMuted),
                contentPadding: const EdgeInsets.all(AppConstants.paddingS),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _rating > 0
                    ? AppColors.forestGreen
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(AppConstants.radiusXS),
              ),
              child: Center(
                child: Text(
                  'SUBMIT REVIEW',
                  style: AppTextStyles.categoryChip.copyWith(
                    fontSize: 12,
                    color: _rating > 0
                        ? AppColors.white
                        : AppColors.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmittedReviewCard extends StatelessWidget {
  final _ReviewItem item;
  final int index;
  const _SubmittedReviewCard({required this.item, required this.index});

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
          Text(item.productName,
              style: AppTextStyles.titleSmall.copyWith(fontSize: 13)),
          const SizedBox(height: 3),
          Text(item.vendorName,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: AppConstants.paddingS),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < (item.rating ?? 0)
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                size: 16,
                color: AppColors.gold,
              ),
            ),
          ),
          if (item.review != null) ...[
            const SizedBox(height: AppConstants.paddingS),
            Text(
              item.review!,
              style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppConstants.paddingS),
          Text(
            item.date,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: AppConstants.animNormal)
        .slideY(begin: 0.04, end: 0);
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Icon(Icons.star_border_rounded,
                size: 52,
                color: AppColors.textMuted.withValues(alpha: 0.35)),
            const SizedBox(height: AppConstants.paddingM),
            Text('No reviews yet',
                style: AppTextStyles.titleSmall
                    .copyWith(color: AppColors.textMuted)),
            const SizedBox(height: AppConstants.paddingS),
            Text('Purchase something to leave a review',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
