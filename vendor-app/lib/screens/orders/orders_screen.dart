import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/orders_provider.dart';

const _filters = ['All', 'Pending', 'In Process', 'Completed', 'Cancelled'];

// Luxury palette — matches dashboard
const _black     = Color(0xFF0A0A0A);
const _darkCard  = Color(0xFF141414);
const _gold      = Color(0xFFC9A84C);
const _goldLight = Color(0xFFE8C97A);
const _olive     = Color(0xFF6B7C3F);
const _sapphire  = Color(0xFF2D6B4A);

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
    final ordersAsync   = ref.watch(ordersProvider);
    final activeFilter  = useState('All');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: _black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Orders',
          style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.2),
        ),
        iconTheme: const IconThemeData(color: _goldLight),
        actionsIconTheme: const IconThemeData(color: _goldLight),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.read(ordersProvider.notifier).refresh(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(53),
          child: Column(children: [
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f        = _filters[i];
                  final selected = activeFilter.value == f;
                  return GestureDetector(
                    onTap: () => activeFilter.value = f,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? _gold.withAlpha(22) : Colors.white.withAlpha(10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? _gold : _goldLight.withAlpha(60),
                          width: selected ? 1.2 : 0.8,
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected ? _goldLight : Colors.white.withAlpha(160),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, _gold, Colors.transparent],
                ),
              ),
            ),
          ]),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: _gold, strokeWidth: 2)),
        error: (e, _) =>
            Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.error))),
        data: (allOrders) {
          final orders = _applyFilter(allOrders, activeFilter.value);
          if (orders.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: _gold.withAlpha(18),
                    shape: BoxShape.circle,
                    border: Border.all(color: _gold.withAlpha(60), width: 1.5),
                  ),
                  child: const Icon(Icons.receipt_long_outlined, size: 44, color: _gold),
                ),
                const SizedBox(height: 20),
                Text(
                  activeFilter.value == 'All'
                      ? 'No orders yet'
                      : 'No ${activeFilter.value.toLowerCase()} orders',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: _black),
                ),
                const SizedBox(height: 6),
                Text(
                  activeFilter.value == 'All'
                      ? 'Orders from customers will appear here'
                      : 'Try a different filter above',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ]),
            );
          }
          return RefreshIndicator(
            color: _gold,
            backgroundColor: Colors.white,
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

// ── Order card ─────────────────────────────────────────────────────────────────

class _OrderCard extends ConsumerWidget {
  final VendorOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _gold.withAlpha(65)),
        boxShadow: [
          BoxShadow(color: _gold.withAlpha(16), blurRadius: 12, offset: const Offset(0, 3)),
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Dark header
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: const BoxDecoration(
            color: _darkCard,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16),
            ),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: _gold.withAlpha(22),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _gold.withAlpha(55), width: 0.8),
              ),
              child: const Icon(Icons.receipt_outlined, size: 16, color: _gold),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  '#${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    fontFamily: 'monospace', fontSize: 12,
                    color: _olive, fontWeight: FontWeight.w700, letterSpacing: 0.5,
                  ),
                ),
                Text(
                  DateFormat('d MMM y · h:mm a').format(order.createdAt.toLocal()),
                  style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(140)),
                ),
              ]),
            ),
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
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.productName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700, color: _black),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('Qty: ${item.quantity}  ·  ₹${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12, color: _olive)),
                  ]),
                ),
              ]),
            )).toList(),
          ),
        ),

        // Footer
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              Text('₹${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 17, color: _gold)),
            ]),
            if (order.isExpress) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _sapphire.withAlpha(18),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _sapphire.withAlpha(50), width: 0.8),
                ),
                child: const Text('⚡ Express',
                    style: TextStyle(
                        fontSize: 10, color: _sapphire, fontWeight: FontWeight.w700)),
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
      color: _sapphire.withAlpha(15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.image_outlined, size: 20, color: _sapphire),
  );
}

// ── Update status button ───────────────────────────────────────────────────────

class _UpdateButton extends ConsumerWidget {
  final VendorOrder order;
  const _UpdateButton({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: _black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _gold.withAlpha(100)),
        boxShadow: [BoxShadow(color: _gold.withAlpha(20), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showStatusDialog(context, ref),
          borderRadius: BorderRadius.circular(8),
          splashColor: _gold.withAlpha(25),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              'Update Status',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: _gold, letterSpacing: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Gold drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_gold, _goldLight]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text('Update Status',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _black)),
          const SizedBox(height: 4),
          Text(
            'Order #${order.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(fontSize: 12, color: _olive, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ...VendorOrder.allowedStatuses.map((s) => ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(s[0].toUpperCase() + s.substring(1),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _black)),
            leading: Radio<String>(
              value: s,
              groupValue: order.status,
              activeColor: _gold,
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

// ── Status chip ────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (textColor, bg, borderColor) = switch (status) {
      'paid'                    => (_sapphire,             _sapphire.withAlpha(22),        _sapphire.withAlpha(75)),
      'processing'              => (_olive,                 _olive.withAlpha(22),            _olive.withAlpha(75)),
      'shipped'                 => (_gold,                  _gold.withAlpha(28),             _gold.withAlpha(75)),
      'delivered'               => (Colors.white,           _black,                          _black),
      'cancelled' || 'refunded' => (AppTheme.error,         AppTheme.error.withAlpha(20),    AppTheme.error.withAlpha(65)),
      _                         => (AppTheme.textSecondary, AppTheme.surfaceVariant,         AppTheme.border),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: textColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
      ),
    );
  }
}
