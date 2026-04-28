import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';
import '../../domain/orders_controller.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'My Orders',
        showSearch: false,
        showCart: false,
        showBack: true,
      ),
      body: orders.isEmpty
          ? Center(
              child: Text(
                'No orders yet',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              itemCount: orders.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppConstants.paddingM),
              itemBuilder: (context, i) =>
                  _OrderCard(order: orders[i], index: i),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final int index;
  const _OrderCard({required this.order, required this.index});

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = switch (order.status) {
      OrderStatus.delivered  => ('Delivered', const Color(0xFF2E7D32)),
      OrderStatus.inTransit  => ('In Transit', AppColors.brass),
      OrderStatus.processing => ('Processing', AppColors.forestGreen),
      OrderStatus.cancelled  => ('Cancelled', AppColors.terraCotta),
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          // ── Header row ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingM, AppConstants.paddingM,
                AppConstants.paddingM, AppConstants.paddingS),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.id,
                    style: AppTextStyles.categoryChip
                        .copyWith(fontSize: 11, letterSpacing: 1.5)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusXS),
                  ),
                  child: Text(statusLabel,
                      style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider, thickness: 0.5),

          // ── Product row ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusXS),
                  child: order.imageAsset != null
                      ? Image.asset(
                          order.imageAsset!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.productName,
                          style: AppTextStyles.titleSmall
                              .copyWith(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(
                        '${order.itemCount} item${order.itemCount > 1 ? 's' : ''}  ·  ${order.date}',
                        style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${order.total.toStringAsFixed(0)}',
                  style: AppTextStyles.priceTag.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),

          // ── Action row ──────────────────────────────────────────────
          const Divider(height: 1, color: AppColors.divider, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingM, vertical: 10),
            child: Row(
              children: [
                if (order.status == OrderStatus.delivered) ...[
                  _ActionChip(label: 'Rate & Review', icon: Icons.star_border_rounded),
                  const SizedBox(width: 8),
                  _ActionChip(label: 'Reorder', icon: Icons.replay_rounded),
                ] else if (order.status == OrderStatus.inTransit) ...[
                  _ActionChip(label: 'Track Order', icon: Icons.local_shipping_outlined),
                ] else ...[
                  _ActionChip(label: 'View Details', icon: Icons.info_outline_rounded),
                ],
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: AppConstants.animNormal)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _placeholder() => Container(
        width: 60,
        height: 60,
        color: AppColors.goldLight,
        child: const Icon(Icons.diamond_outlined,
            color: AppColors.gold, size: 24),
      );
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _ActionChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider, width: 0.5),
          borderRadius: BorderRadius.circular(AppConstants.radiusXS),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.forestGreen),
            const SizedBox(width: 4),
            Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
