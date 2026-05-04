import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/products_provider.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(authProvider).value;
    final productsAsync = ref.watch(productsProvider);
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async {
          await Future.wait([
            ref.read(productsProvider.notifier).refresh(),
            ref.read(ordersProvider.notifier).refresh(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 28,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFC9A84C), Color(0xFFE8C97A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        'Hello, ${vendor?.name ?? ''}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF3D4F1C)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vendor Dashboard',
                        style: TextStyle(fontSize: 13, color: const Color(0xFF3D4F1C).withAlpha(180)),
                      ),
                    ]),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout_outlined, color: Colors.white, size: 20),
                    ),
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                  ),
                ]),
              ),
            ),

            // ── Stats ────────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: productsAsync.when(
                  data: (products) => ordersAsync.when(
                    data: (orders) => _StatsGrid(products: products.length, orders: orders),
                    loading: () => const _StatsGridSkeleton(),
                    error: (_, __) => const _StatsGridSkeleton(),
                  ),
                  loading: () => const _StatsGridSkeleton(),
                  error: (_, __) => const _StatsGridSkeleton(),
                ),
              ),
            ),

            // ── Recent Orders ─────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Row(children: [
                  const Expanded(
                    child: Text('Recent Orders',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  ),
                  TextButton(
                    onPressed: () => context.go('/orders'),
                    child: const Text('See all', style: TextStyle(color: AppTheme.secondary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              sliver: SliverToBoxAdapter(
                child: ordersAsync.when(
                  data: (orders) {
                    if (orders.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: const Column(children: [
                          Icon(Icons.receipt_long_outlined, size: 36, color: AppTheme.textSecondary),
                          SizedBox(height: 8),
                          Text('No orders yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                        ]),
                      );
                    }
                    return Column(
                      children: orders.take(5).map((o) => _OrderTile(order: o)).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
                    ),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: $e', style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                  ),
                ),
              ),
            ),

            // ── Add Product CTA ──────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              sliver: SliverToBoxAdapter(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/products/new'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add New Product'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats grid ─────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final int products;
  final List<VendorOrder> orders;
  const _StatsGrid({required this.products, required this.orders});

  @override
  Widget build(BuildContext context) {
    final activeOrders = orders.where((o) => ['paid', 'processing', 'shipped'].contains(o.status)).length;
    final totalRevenue = orders
        .where((o) => ['paid', 'processing', 'shipped', 'delivered'].contains(o.status))
        .fold(0.0, (s, o) => s + o.total);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        StatCard(label: 'Products', value: products.toString(),
            icon: Icons.inventory_2_outlined, color: AppTheme.secondary),
        StatCard(label: 'Active Orders', value: activeOrders.toString(),
            icon: Icons.local_shipping_outlined, color: AppTheme.primary),
        StatCard(label: 'Total Orders', value: orders.length.toString(),
            icon: Icons.receipt_long_outlined, color: const Color(0xFF7B68EE)),
        StatCard(label: 'Revenue', value: '₹${totalRevenue.toStringAsFixed(0)}',
            icon: Icons.trending_up_rounded, color: AppTheme.success),
      ],
    );
  }
}

class _StatsGridSkeleton extends StatelessWidget {
  const _StatsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: List.generate(4, (_) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.cardShadow,
        ),
      )),
    );
  }
}

// ── Order tile ─────────────────────────────────────────────────────────────────

class _OrderTile extends StatelessWidget {
  final VendorOrder order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.receipt_outlined, size: 18, color: AppTheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '#${order.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12,
                color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            '${order.items.length} item${order.items.length != 1 ? 's' : ''} · ₹${order.total.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
        ])),
        _StatusBadge(status: order.status),
      ]),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      'paid' || 'processing' => (AppTheme.success, AppTheme.success.withAlpha(25)),
      'shipped'   => (const Color(0xFF2563EB), const Color(0xFF2563EB).withAlpha(20)),
      'delivered' => (AppTheme.primary, AppTheme.primary.withAlpha(25)),
      'cancelled' || 'refunded' => (AppTheme.error, AppTheme.error.withAlpha(20)),
      _ => (AppTheme.textSecondary, AppTheme.surfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
    );
  }
}
