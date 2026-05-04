import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';

const _filters = ['All', 'Pending', 'In Process', 'Completed', 'Cancelled'];

List<VendorOrder> _applyFilter(List<VendorOrder> orders, String filter) {
  return switch (filter) {
    'Pending'    => orders.where((o) => ['paid', 'processing'].contains(o.status)).toList(),
    'In Process' => orders.where((o) => o.status == 'shipped').toList(),
    'Completed'  => orders.where((o) => o.status == 'delivered').toList(),
    'Cancelled'  => orders.where((o) => ['cancelled', 'refunded'].contains(o.status)).toList(),
    _            => orders,
  };
}

class OrdersScreen extends HookConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final activeFilter = useState('All');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.read(ordersProvider.notifier).refresh(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final selected = activeFilter.value == f;
                return GestureDetector(
                  onTap: () => activeFilter.value = f,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppTheme.primary : AppTheme.border,
                      ),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.error))),
        data: (allOrders) {
          final orders = _applyFilter(allOrders, activeFilter.value);
          if (orders.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_outlined, size: 44, color: AppTheme.primary),
              ),
              const SizedBox(height: 20),
              Text(
                activeFilter.value == 'All' ? 'No orders yet' : 'No ${activeFilter.value.toLowerCase()} orders',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                activeFilter.value == 'All'
                    ? 'Orders from customers will appear here'
                    : 'Try a different filter above',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ]));
          }
          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _OrderCard(order: orders[i]),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final VendorOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14), topRight: Radius.circular(14),
            ),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(22),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt_outlined, size: 16, color: AppTheme.primary),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '#${order.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12,
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
              ),
              Text(
                DateFormat('d MMM y · h:mm a').format(order.createdAt.toLocal()),
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ])),
            _StatusChip(status: order.status),
          ]),
        ),

        // Items
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Column(
            children: order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.imageUrl != null
                      ? Image.network(item.imageUrl!, width: 44, height: 44, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imgPlaceholder())
                      : _imgPlaceholder(),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.productName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('Qty: ${item.quantity}  ·  ₹${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ])),
              ]),
            )).toList(),
          ),
        ),

        // Footer
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              Text('₹${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppTheme.textPrimary)),
            ]),
            if (order.isExpress) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withAlpha(18),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text('⚡ Express',
                    style: TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.w700)),
              ),
            ],
            const Spacer(),
            if (_canUpdate(order.status)) _UpdateButton(order: order),
          ]),
        ),
      ]),
    );
  }

  bool _canUpdate(String status) =>
      !['delivered', 'cancelled', 'refunded', 'payment_pending'].contains(status);

  Widget _imgPlaceholder() => Container(
    width: 44, height: 44,
    decoration: BoxDecoration(
      color: AppTheme.surfaceVariant,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.image_outlined, size: 20, color: AppTheme.primary),
  );
}

class _UpdateButton extends ConsumerWidget {
  final VendorOrder order;
  const _UpdateButton({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _showStatusDialog(context, ref),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      child: const Text('Update Status'),
    );
  }

  void _showStatusDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.border, borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text('Update Status', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Order #${order.id.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          ...VendorOrder.allowedStatuses.map((s) => ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(s[0].toUpperCase() + s.substring(1),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            leading: Radio<String>(
              value: s,
              groupValue: order.status,
              activeColor: AppTheme.primary,
              onChanged: (val) async {
                Navigator.pop(context);
                if (val != null && val != order.status) {
                  await ref.read(ordersProvider.notifier).updateStatus(order.id, val);
                }
              },
            ),
          )),
        ]),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      'paid' || 'processing' => (AppTheme.success, AppTheme.success.withAlpha(25)),
      'shipped'   => (const Color(0xFF2563EB), const Color(0xFF2563EB).withAlpha(22)),
      'delivered' => (AppTheme.secondary, AppTheme.secondary.withAlpha(25)),
      'cancelled' || 'refunded' => (AppTheme.error, AppTheme.error.withAlpha(20)),
      _ => (AppTheme.textSecondary, AppTheme.surfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
    );
  }
}
