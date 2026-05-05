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

class _OrderCard extends ConsumerWidget {
  final OrderModel order;
  final int index;
  const _OrderCard({required this.order, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      ? (order.imageAsset!.startsWith('http')
                          ? Image.network(
                              order.imageAsset!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : Image.asset(
                              order.imageAsset!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            ))
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
                  const SizedBox(width: 8),
                  _ActionChip(
                    label: 'Request Refund',
                    icon: Icons.replay_circle_filled_outlined,
                    onTap: () => _showRefundSheet(context, order),
                  ),
                ] else if (order.status == OrderStatus.inTransit) ...[
                  _ActionChip(label: 'Track Order', icon: Icons.local_shipping_outlined),
                  const SizedBox(width: 8),
                  _ActionChip(
                    label: 'View Details',
                    icon: Icons.info_outline_rounded,
                    onTap: () => _showDetailsSheet(context, order),
                  ),
                ] else if (order.status == OrderStatus.processing) ...[
                  _ActionChip(
                    label: 'View Details',
                    icon: Icons.info_outline_rounded,
                    onTap: () => _showDetailsSheet(context, order),
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    label: 'Cancel Order',
                    icon: Icons.cancel_outlined,
                    isDestructive: true,
                    onTap: () => _showCancelConfirm(context, ref, order),
                  ),
                ] else ...[
                  _ActionChip(
                    label: 'View Details',
                    icon: Icons.info_outline_rounded,
                    onTap: () => _showDetailsSheet(context, order),
                  ),
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

  static void _showDetailsSheet(BuildContext context, OrderModel order) {
    final (statusLabel, statusColor) = switch (order.status) {
      OrderStatus.delivered  => ('Delivered', const Color(0xFF2E7D32)),
      OrderStatus.inTransit  => ('In Transit', AppColors.brass),
      OrderStatus.processing => ('Processing', AppColors.forestGreen),
      OrderStatus.cancelled  => ('Cancelled', AppColors.terraCotta),
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingM, 0,
            AppConstants.paddingM, AppConstants.paddingM,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ORDER DETAILS',
                      style: AppTextStyles.categoryChip
                          .copyWith(fontSize: 10, letterSpacing: 2.5)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
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
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.divider, thickness: 0.5),
              const SizedBox(height: 14),
              _DetailRow(label: 'Order ID', value: order.id),
              const SizedBox(height: 10),
              _DetailRow(label: 'Product', value: order.productName),
              const SizedBox(height: 10),
              _DetailRow(label: 'Date', value: order.date),
              const SizedBox(height: 10),
              _DetailRow(
                  label: 'Items',
                  value:
                      '${order.itemCount} item${order.itemCount > 1 ? 's' : ''}'),
              const SizedBox(height: 10),
              _DetailRow(
                  label: 'Total',
                  value: '₹${order.total.toStringAsFixed(0)}',
                  bold: true),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static void _showCancelConfirm(
      BuildContext context, WidgetRef ref, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM)),
        title: Text('Cancel Order?',
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 17)),
        content: Text(
          'Are you sure you want to cancel ${order.productName}? This cannot be undone.',
          style: AppTextStyles.bodyMedium
              .copyWith(fontSize: 13, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep Order',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.forestGreen, fontSize: 13)),
          ),
          TextButton(
            onPressed: () {
              ref.read(ordersProvider.notifier).cancelOrder(order.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order ${order.id} has been cancelled.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.white)),
                  backgroundColor: AppColors.terraCotta,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusXS)),
                ),
              );
            },
            child: Text('Cancel Order',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.terraCotta,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  static void _showRefundSheet(BuildContext context, OrderModel order) {
    String? selectedReason;
    const reasons = [
      'Item received damaged',
      'Wrong item delivered',
      'Item not as described',
      'Item missing from order',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusM)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            AppConstants.paddingL,
            AppConstants.paddingM,
            AppConstants.paddingL,
            MediaQuery.of(ctx).viewInsets.bottom + AppConstants.paddingL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Request Refund',
                  style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
              const SizedBox(height: 4),
              Text(order.productName,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: AppConstants.paddingM),
              Text('Select a reason',
                  style: AppTextStyles.categoryChip
                      .copyWith(fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: AppConstants.paddingS),
              ...reasons.map((r) => GestureDetector(
                    onTap: () => setState(() => selectedReason = r),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingM, vertical: 11),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: selectedReason == r
                            ? AppColors.forestGreen.withValues(alpha: 0.07)
                            : AppColors.surface,
                        border: Border.all(
                          color: selectedReason == r
                              ? AppColors.forestGreen
                              : AppColors.divider,
                          width: selectedReason == r ? 1.2 : 0.5,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusXS),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedReason == r
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 16,
                            color: selectedReason == r
                                ? AppColors.forestGreen
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Text(r,
                              style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: AppConstants.paddingM),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: selectedReason == null
                      ? null
                      : () {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Refund request submitted for ${order.productName}.',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.white),
                              ),
                              backgroundColor: AppColors.forestGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusS),
                              ),
                            ),
                          );
                        },
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: selectedReason == null
                          ? AppColors.forestGreen.withValues(alpha: 0.35)
                          : AppColors.forestGreen,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusS),
                    ),
                    child: Center(
                      child: Text(
                        'SUBMIT REQUEST',
                        style: AppTextStyles.categoryChip.copyWith(
                          color: AppColors.white,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _ActionChip({
    required this.label,
    required this.icon,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.terraCotta : AppColors.forestGreen;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.terraCotta.withValues(alpha: 0.06)
              : Colors.transparent,
          border: Border.all(
              color: isDestructive ? AppColors.terraCotta : AppColors.divider,
              width: 0.8),
          borderRadius: BorderRadius.circular(AppConstants.radiusXS),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: isDestructive
                        ? AppColors.terraCotta
                        : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _DetailRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(fontSize: 12, color: AppColors.textMuted)),
        Text(value,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textPrimary,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            )),
      ],
    );
  }
}
