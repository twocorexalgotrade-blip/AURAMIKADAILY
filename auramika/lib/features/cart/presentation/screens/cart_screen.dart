import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';
import '../../../auth/domain/auth_controller.dart';
import '../../domain/cart_model.dart';
import '../controllers/cart_controller.dart';

/// AURAMIKA Cart Screen — Phase 6
///
/// Features:
///   • Express delivery banner (ALL items express → glowing "Get it in 2 Hours")
///   • Cart item list with large thumbnails, qty controls, remove
///   • Order summary (subtotal, delivery, total)
///   • Sticky "Proceed to Checkout" bar
///   • Empty state: "Your bag is empty. Start with the Magic Mirror."
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'My Bag',
        showSearch: false,
        showCart: false,
      ),
      body: cart.isEmpty
          ? _EmptyCartState()
          : Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ── Express delivery banner ─────────────────────────
                    SliverToBoxAdapter(
                      child: _DeliveryBanner(isAllExpress: cart.isAllExpress),
                    ),

                    // ── Item count header ───────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppConstants.paddingM,
                          AppConstants.paddingM,
                          AppConstants.paddingM,
                          AppConstants.paddingS,
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${cart.totalItems} ${cart.totalItems == 1 ? 'ITEM' : 'ITEMS'}',
                              style: AppTextStyles.categoryChip.copyWith(
                                fontSize: 10,
                                letterSpacing: 2.5,
                              ),
                            ),
                            const SizedBox(width: AppConstants.paddingS),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Cart items ──────────────────────────────────────
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _CartItemTile(
                          item: cart.items[i],
                          animIndex: i,
                          onRemove: () => ref.read(cartProvider.notifier).removeItem(cart.items[i].id),
                          onQtyChange: (delta) =>
                              ref.read(cartProvider.notifier).updateQty(cart.items[i].id, delta),
                        ),
                        childCount: cart.items.length,
                      ),
                    ),

                    // ── Divider ─────────────────────────────────────────
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingM,
                          vertical: AppConstants.paddingM,
                        ),
                        child: Divider(
                          color: AppColors.divider,
                          thickness: 0.5,
                        ),
                      ),
                    ),

                    // ── Order summary ───────────────────────────────────
                    SliverToBoxAdapter(
                      child: _OrderSummary(cart: cart),
                    ),

                    // ── Bottom padding for sticky bar ───────────────────
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),

                // ── Sticky checkout bar ─────────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _CheckoutBar(cart: cart),
                ),
              ],
            ),
    );
  }
}

// ── Express Delivery Banner ───────────────────────────────────────────────────
class _DeliveryBanner extends StatefulWidget {
  final bool isAllExpress;
  const _DeliveryBanner({required this.isAllExpress});

  @override
  State<_DeliveryBanner> createState() => _DeliveryBannerState();
}

class _DeliveryBannerState extends State<_DeliveryBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAllExpress) {
      return AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, child) {
          final glow = 4.0 + (_glowAnim.value * 10.0);
          final opacity = 0.2 + (_glowAnim.value * 0.2);
          return Container(
            margin: const EdgeInsets.fromLTRB(
              AppConstants.paddingM,
              AppConstants.paddingM,
              AppConstants.paddingM,
              0,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
              vertical: AppConstants.paddingM,
            ),
            decoration: BoxDecoration(
              color: AppColors.forestGreen,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              boxShadow: [
                BoxShadow(
                  color: AppColors.forestGreen.withValues(alpha: opacity),
                  blurRadius: glow,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusXS),
              ),
              child: const Icon(Icons.bolt, color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get it in 2 Hours',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'All items eligible for express delivery',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(AppConstants.radiusXS),
              ),
              child: Text(
                'FREE',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 9,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: AppConstants.animNormal)
          .slideY(begin: -0.05, end: 0);
    }

    // Standard shipping banner
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.paddingM,
        AppConstants.paddingM,
        AppConstants.paddingM,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            size: 20,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Standard Shipping (2-3 Days)',
                  style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
                ),
                Text(
                  'Some items are not express eligible',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹49',
            style: AppTextStyles.headlineSmall.copyWith(
              fontSize: 14,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cart Item Tile ────────────────────────────────────────────────────────────
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final int animIndex;
  final VoidCallback onRemove;
  final ValueChanged<int> onQtyChange;

  const _CartItemTile({
    required this.item,
    required this.animIndex,
    required this.onRemove,
    required this.onQtyChange,
  });

  @override
  Widget build(BuildContext context) {
    final matColor = item.materialColor;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.paddingL),
        color: AppColors.terraCotta.withValues(alpha: 0.1),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.terraCotta,
          size: 24,
        ),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS,
        ),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tappable: thumbnail + info → PDP ────────────────────────
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push(AppRoutes.product(item.productId)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    Container(
                      width: 80,
                      height: 96,
                      decoration: BoxDecoration(
                        color: matColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (item.imageUrl != null && item.imageUrl!.startsWith('http'))
                            CachedNetworkImage(
                              imageUrl: item.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Center(
                                child: Icon(Icons.diamond_outlined, color: matColor, size: 32),
                              ),
                              errorWidget: (_, __, ___) => Center(
                                child: Icon(Icons.diamond_outlined, color: matColor, size: 32),
                              ),
                            )
                          else if (item.imageUrl != null && item.imageUrl!.startsWith('assets'))
                            Image.asset(
                              item.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(Icons.diamond_outlined, color: matColor, size: 32),
                              ),
                            )
                          else
                            Center(
                              child: Icon(Icons.diamond_outlined, color: matColor, size: 32),
                            ),
                          if (item.isExpressAvailable)
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.forestGreen,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                                ),
                                child: const Icon(Icons.bolt, size: 9, color: AppColors.gold),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppConstants.paddingM),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.brandName,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 9,
                              letterSpacing: 1.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.productName,
                            style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: matColor.withValues(alpha: 0.4), width: 0.8),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                                ),
                                child: Text(
                                  item.material.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: matColor,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                              if (item.size != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.divider,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                                  ),
                                  child: Text(
                                    item.size!,
                                    style: AppTextStyles.labelSmall.copyWith(fontSize: 8, letterSpacing: 0.5),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppConstants.paddingS),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${item.subtotal.toInt()}',
                                style: AppTextStyles.priceTag.copyWith(fontSize: 17),
                              ),
                              _QtyControl(
                                qty: item.quantity,
                                onDecrement: () => onQtyChange(-1),
                                onIncrement: () => onQtyChange(1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Remove button (not part of PDP tap area) ─────────────────
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.only(left: AppConstants.paddingS),
                child: Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: animIndex * 60))
        .fadeIn(duration: AppConstants.animNormal)
        .slideX(begin: 0.04, end: 0);
  }
}

// ── Qty Control ───────────────────────────────────────────────────────────────
class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QtyControl({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider, width: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(icon: Icons.remove_rounded, onTap: onDecrement),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$qty',
              style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
            ),
          ),
          _QtyBtn(icon: Icons.add_rounded, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 14, color: AppColors.textPrimary),
      ),
    );
  }
}

// ── Order Summary ─────────────────────────────────────────────────────────────
class _OrderSummary extends StatelessWidget {
  final CartState cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER SUMMARY',
            style: AppTextStyles.categoryChip.copyWith(
              fontSize: 10,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          _SummaryRow(label: 'Subtotal', value: '₹${cart.subtotal.toInt()}'),
          const SizedBox(height: AppConstants.paddingS),
          _SummaryRow(
            label: cart.isAllExpress
                ? 'Express Delivery'
                : 'Standard Delivery',
            value: cart.deliveryFee == 0 ? 'FREE' : '₹${cart.deliveryFee.toInt()}',
            valueColor: cart.deliveryFee == 0
                ? AppColors.forestGreen
                : AppColors.emeraldGreen,
          ),
          const SizedBox(height: AppConstants.paddingM),
          Container(height: 0.5, color: AppColors.divider),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: AppTextStyles.categoryChip.copyWith(
                  fontSize: 11,
                  letterSpacing: 2.0,
                ),
              ),
              Text(
                '₹${cart.total.toInt()}',
                style: AppTextStyles.priceTag.copyWith(fontSize: 22),
              ),
            ],
          ),
          if (cart.isAllExpress) ...[
            const SizedBox(height: AppConstants.paddingS),
            Row(
              children: [
                const Icon(Icons.bolt, size: 12, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  'Estimated delivery: within 2 hours',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.forestGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
        ),
        Text(
          value,
          style: AppTextStyles.priceTag.copyWith(
            fontSize: 13,
            color: valueColor ?? AppColors.emeraldGreen,
          ),
        ),
      ],
    );
  }
}

// ── Sticky Checkout Bar ───────────────────────────────────────────────────────
class _CheckoutBar extends ConsumerWidget {
  final CartState cart;
  const _CheckoutBar({required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isLoggedIn = ref.watch(authProvider).isLoggedIn;

    void onCheckout() {
      if (isLoggedIn) {
        context.push(AppRoutes.checkout);
      } else {
        context.push(
          AppRoutes.login,
          extra: {'redirect': AppRoutes.checkout},
        );
      }
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingM,
        AppConstants.paddingM,
        AppConstants.paddingM,
        AppConstants.paddingM + bottomPad,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: const Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onCheckout,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.forestGreen,
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (cart.isAllExpress) ...[
                const Icon(Icons.bolt, size: 16, color: AppColors.gold),
                const SizedBox(width: 6),
              ],
              Text(
                cart.isAllExpress
                    ? 'CHECKOUT · GET IN 2 HRS'
                    : 'PROCEED TO CHECKOUT',
                style: AppTextStyles.categoryChip.copyWith(
                  color: AppColors.white,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: AppConstants.paddingS),
              Text(
                '₹${cart.total.toInt()}',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.gold,
                  fontSize: 14,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty Cart State ──────────────────────────────────────────────────────────
class _EmptyCartState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bag icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.forestGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: AppColors.forestGreen.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 36,
                color: AppColors.forestGreen,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: AppConstants.animNormal,
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: AppConstants.paddingL),

            Text(
              'Your bag is empty.',
              style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 150)),

            const SizedBox(height: AppConstants.paddingS),

            Text(
              'Start with the Magic Mirror',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 250)),

            const SizedBox(height: AppConstants.paddingXL),

            // CTA
            GestureDetector(
              onTap: () => StatefulNavigationShell.of(context).goBranch(2),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingXL,
                  vertical: AppConstants.paddingM,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: AppConstants.paddingS),
                    Text(
                      'OPEN MAGIC MIRROR',
                      style: AppTextStyles.categoryChip.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 350))
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
