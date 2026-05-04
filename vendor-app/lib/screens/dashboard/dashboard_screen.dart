import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/products_provider.dart';
import '../../widgets/stat_card.dart';

// Luxury palette: olive green · sapphire green · golden · black · white
const _black     = Color(0xFF0A0A0A);
const _darkCard  = Color(0xFF141414);
const _gold      = Color(0xFFC9A84C);
const _goldLight = Color(0xFFE8C97A);
const _olive     = Color(0xFF6B7C3F);
const _sapphire  = Color(0xFF2D6B4A);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor        = ref.watch(authProvider).valueOrNull;
    final productsAsync = ref.watch(productsProvider);
    final ordersAsync   = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        color: _gold,
        backgroundColor: _darkCard,
        onRefresh: () async {
          await Future.wait([
            ref.read(productsProvider.notifier).refresh(),
            ref.read(ordersProvider.notifier).refresh(),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Luxury Header ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _LuxuryHeader(
                vendorName: vendor?.name ?? '',
                onLogout: () => ref.read(authProvider.notifier).logout(),
              ),
            ),

            // ── Stats ─────────────────────────────────────────────────────────
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

            // ── Session error banner ──────────────────────────────────────────
            if (ordersAsync.hasError || productsAsync.hasError)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _SessionErrorBanner(ref: ref),
                ),
              ),

            // ── Recent Orders header ───────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Expanded(
                        child: Text(
                          'Recent Orders',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _black,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/orders'),
                        child: const Text('See all',
                            style: TextStyle(
                                color: _olive, fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Container(
                      height: 1.5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_gold, _goldLight, Colors.transparent],
                          stops: [0.0, 0.35, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Order list ────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              sliver: SliverToBoxAdapter(
                child: ordersAsync.when(
                  data: (orders) {
                    if (orders.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _gold.withAlpha(80)),
                          boxShadow: [
                            BoxShadow(
                                color: _gold.withAlpha(18),
                                blurRadius: 16,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: const Column(children: [
                          Icon(Icons.receipt_long_outlined, size: 36, color: _olive),
                          SizedBox(height: 10),
                          Text('No orders yet',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
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
                      child: CircularProgressIndicator(color: _gold, strokeWidth: 2),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),

            // ── Add Product CTA ───────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              sliver: SliverToBoxAdapter(
                child: _LuxuryCTA(onTap: () => context.go('/products/new')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Luxury Header ──────────────────────────────────────────────────────────────

class _LuxuryHeader extends StatelessWidget {
  final String vendorName;
  final VoidCallback onLogout;
  const _LuxuryHeader({required this.vendorName, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF080808), Color(0xFF111A0E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(children: [
          // Gold radial shimmer — top right
          Positioned(
            top: -40,
            right: -20,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_gold.withAlpha(38), Colors.transparent],
                ),
              ),
            ),
          ),
          // Sapphire radial shimmer — bottom left
          Positioned(
            bottom: -20,
            left: -10,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_sapphire.withAlpha(50), Colors.transparent],
                ),
              ),
            ),
          ),
          // Thin gold line at bottom edge
          Positioned(
            bottom: 0,
            left: 24,
            right: 24,
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, _gold, Colors.transparent],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 32,
              left: 22,
              right: 16,
            ),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Brand eyebrow
                  Row(children: [
                    Container(
                      width: 3,
                      height: 15,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'AURAMIKA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _gold,
                        letterSpacing: 3.5,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Text(
                    'Hello, $vendorName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Vendor Dashboard',
                    style: TextStyle(
                      fontSize: 13,
                      color: _goldLight,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ]),
              ),
              // Logout button
              GestureDetector(
                onTap: onLogout,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _gold.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _gold.withAlpha(90), width: 1),
                  ),
                  child: const Icon(Icons.logout_outlined, color: _goldLight, size: 20),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Luxury CTA button ──────────────────────────────────────────────────────────

class _LuxuryCTA extends StatelessWidget {
  final VoidCallback onTap;
  const _LuxuryCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A0A0A), Color(0xFF1C1C1C)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(color: _gold.withAlpha(110), width: 1),
        boxShadow: [
          BoxShadow(color: _gold.withAlpha(25), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: _gold.withAlpha(30),
          highlightColor: _gold.withAlpha(15),
          child: const Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add_rounded, color: _gold, size: 22),
              SizedBox(width: 10),
              Text(
                'Add New Product',
                style: TextStyle(
                  color: _gold,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ]),
          ),
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
    final activeOrders = orders
        .where((o) => ['paid', 'processing', 'shipped'].contains(o.status))
        .length;
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
        StatCard(
            label: 'Products',
            value: products.toString(),
            icon: Icons.inventory_2_outlined,
            color: _olive,
            dark: true),
        StatCard(
            label: 'Active Orders',
            value: activeOrders.toString(),
            icon: Icons.local_shipping_outlined,
            color: _gold,
            dark: true),
        StatCard(
            label: 'Total Orders',
            value: orders.length.toString(),
            icon: Icons.receipt_long_outlined,
            color: _sapphire,
            dark: true),
        StatCard(
            label: 'Revenue',
            value: '₹${totalRevenue.toStringAsFixed(0)}',
            icon: Icons.trending_up_rounded,
            color: _goldLight,
            dark: true),
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
      children: List.generate(
          4,
          (_) => Container(
                decoration: BoxDecoration(
                  color: _darkCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _gold.withAlpha(50)),
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withAlpha(65)),
        boxShadow: [
          BoxShadow(color: _gold.withAlpha(16), blurRadius: 12, offset: const Offset(0, 3)),
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _sapphire.withAlpha(18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _sapphire.withAlpha(45)),
          ),
          child: const Icon(Icons.receipt_outlined, size: 18, color: _sapphire),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            '#${order.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: _olive,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${order.items.length} item${order.items.length != 1 ? 's' : ''} · ₹${order.total.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _black),
          ),
        ])),
        _StatusBadge(status: order.status),
      ]),
    );
  }
}

// ── Status badge ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (textColor, bg, borderColor) = switch (status) {
      'paid' => (_sapphire, _sapphire.withAlpha(22), _sapphire.withAlpha(75)),
      'processing' => (_olive, _olive.withAlpha(22), _olive.withAlpha(75)),
      'shipped' => (_gold, _gold.withAlpha(28), _gold.withAlpha(75)),
      'delivered' => (Colors.white, _black, _black),
      'cancelled' || 'refunded' => (
        AppTheme.error,
        AppTheme.error.withAlpha(20),
        AppTheme.error.withAlpha(65)
      ),
      _ => (AppTheme.textSecondary, AppTheme.surfaceVariant, AppTheme.border),
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
        style:
            TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
      ),
    );
  }
}

// ── Session error banner ───────────────────────────────────────────────────────

class _SessionErrorBanner extends StatelessWidget {
  final WidgetRef ref;
  const _SessionErrorBanner({required this.ref});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.warning.withAlpha(18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.warning.withAlpha(60)),
        ),
        child: Row(children: [
          Icon(Icons.lock_outline_rounded, color: AppTheme.warning, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Session expired. Please sign in again.',
              style: TextStyle(fontSize: 13, color: _black, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.warning,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            child: const Text('Sign In'),
          ),
        ]),
      );
}
