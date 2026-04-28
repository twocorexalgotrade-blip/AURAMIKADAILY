import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../features/profile/domain/wishlist_controller.dart';

/// AURAMIKA Product Card
///
/// Design Language:
///   • 4:5 full-bleed image (editorial fashion ratio)
///   • Sharp 4px corners — "High End" minimalism
///   • Brand name in small caps (Outfit, spaced)
///   • Price in Playfair Display serif
///   • Material badge (Brass / Copper) — thin border tag
///   • Express delivery badge overlay
///   • Wishlist heart icon (top-right overlay)
///   • Subtle press scale animation
class ProductCard extends ConsumerStatefulWidget {
  final String id;
  final String brandName;
  final String productName;
  final double price;
  final String? imageUrl;
  final String material; // 'Brass' | 'Copper'
  final bool isExpressAvailable;
  final bool isWishlisted; // kept for API compat; provider is source of truth
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final int animationIndex;

  const ProductCard({
    super.key,
    required this.id,
    required this.brandName,
    required this.productName,
    required this.price,
    this.imageUrl,
    this.material = 'Brass',
    this.isExpressAvailable = true,
    this.isWishlisted = false,
    this.onTap,
    this.onWishlistTap,
    this.animationIndex = 0,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isWishlisted = ref.watch(wishlistProvider).contains(widget.id);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppConstants.animFast,
        curve: Curves.easeOut,
        child: _buildCard(isWishlisted),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.animationIndex * 70))
        .fadeIn(duration: AppConstants.animNormal, curve: Curves.easeOut)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: AppConstants.animNormal,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildCard(bool isWishlisted) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image (fills remaining height after info section) ─────────
          Expanded(
            child: _ProductImage(
              imageUrl: widget.imageUrl,
              material: widget.material,
              isExpressAvailable: widget.isExpressAvailable,
              isWishlisted: isWishlisted,
              onWishlistTap: () {
                ref.read(wishlistProvider.notifier).toggle(WishlistItem(
                      id: widget.id,
                      brandName: widget.brandName,
                      productName: widget.productName,
                      price: widget.price,
                      material: widget.material,
                      imageUrl: widget.imageUrl,
                      isExpressAvailable: widget.isExpressAvailable,
                    ));
                widget.onWishlistTap?.call();
              },
            ),
          ),

          // ── Info ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingS + 2,
              AppConstants.paddingS,
              AppConstants.paddingS + 2,
              AppConstants.paddingXS,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand name — small caps
                Text(
                  widget.brandName.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    letterSpacing: 1.8,
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                // Product name — fixed height keeps price row aligned across cards
                SizedBox(
                  height: 34,
                  child: Text(
                    widget.productName,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),

                // Price row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price in Playfair serif
                    Text(
                      '₹${_formatPrice(widget.price)}',
                      style: AppTextStyles.priceTag.copyWith(fontSize: 17),
                    ),
                    // Material tag
                    _MaterialTag(material: widget.material),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final n = price.toInt();
    if (n >= 1000) {
      final s = n.toString();
      // 4 digits → 1,499 ; 5 digits → 12,499
      return s.length == 4
          ? '${s[0]},${s.substring(1)}'
          : s.length == 5
              ? '${s.substring(0, 2)},${s.substring(2)}'
              : s;
    }
    return n.toString();
  }
}

// ── Product Image with Overlays ───────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String material;
  final bool isExpressAvailable;
  final bool isWishlisted;
  final VoidCallback onWishlistTap;

  const _ProductImage({
    required this.imageUrl,
    required this.material,
    required this.isExpressAvailable,
    required this.isWishlisted,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
          // ── Image ──────────────────────────────────────────────────────
          imageUrl != null
              ? (imageUrl!.startsWith('assets')
                  ? Image.asset(
                      imageUrl!,
                      fit: BoxFit.cover,
                      cacheWidth: 600,
                      errorBuilder: (ctx, error, stackTrace) =>
                          _ImagePlaceholder(material: material),
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          _ImagePlaceholder(material: material),
                      errorWidget: (_, __, ___) =>
                          _ImagePlaceholder(material: material),
                    ))
              : _ImagePlaceholder(material: material),

          // ── Bottom gradient overlay ────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
          ),

          // ── Express badge (top-left) ───────────────────────────────────
          if (isExpressAvailable)
            Positioned(
              top: AppConstants.paddingS,
              left: AppConstants.paddingS,
              child: _ExpressBadge(),
            ),

          // ── Wishlist button (top-right) ────────────────────────────────
          Positioned(
            top: AppConstants.paddingXS,
            right: AppConstants.paddingXS,
            child: _WishlistButton(
              isWishlisted: isWishlisted,
              onTap: onWishlistTap,
            ),
          ),
        ],
    );
  }
}

// ── Image Placeholder — animated shimmer ──────────────────────────────────────
class _ImagePlaceholder extends StatefulWidget {
  final String material;
  const _ImagePlaceholder({required this.material});

  static Color _materialColor(String mat) {
    final m = mat.toLowerCase();
    if (m.contains('gold')) return AppColors.gold;
    if (m.contains('silver')) return const Color(0xFFC0C0C0);
    if (m.contains('rose')) return const Color(0xFFB76E79);
    if (m.contains('pearl')) return const Color(0xFFEAE0D5);
    if (m.contains('copper')) return AppColors.copper;
    if (m.contains('brass')) return AppColors.brass;
    return AppColors.gold;
  }

  @override
  State<_ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<_ImagePlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = CurvedAnimation(parent: _shimmer, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _ImagePlaceholder._materialColor(widget.material);
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final t = _anim.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-1.5, -0.5),
              end: const Alignment(1.5, 0.5),
              stops: [
                (t - 0.3).clamp(0.0, 1.0),
                t.clamp(0.0, 1.0),
                (t + 0.3).clamp(0.0, 1.0),
              ],
              colors: [
                color.withValues(alpha: 0.08),
                color.withValues(alpha: 0.22),
                color.withValues(alpha: 0.08),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.diamond_outlined, color: color.withValues(alpha: 0.5), size: 32),
                const SizedBox(height: 6),
                Text(
                  widget.material.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.5),
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Express Badge ─────────────────────────────────────────────────────────────
class _ExpressBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.forestGreen,
        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 9, color: AppColors.gold),
          const SizedBox(width: 2),
          Text(
            '2 HRS',
            style: AppTextStyles.expressBadge.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }
}

// ── Wishlist Button ───────────────────────────────────────────────────────────
class _WishlistButton extends StatelessWidget {
  final bool isWishlisted;
  final VoidCallback onTap;

  const _WishlistButton({required this.isWishlisted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppConstants.radiusXS),
        ),
        child: Icon(
          isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 16,
          color: isWishlisted ? AppColors.terraCotta : AppColors.textMuted,
        ),
      )
          .animate(target: isWishlisted ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.2, 1.2),
            duration: AppConstants.animFast,
            curve: Curves.elasticOut,
          ),
    );
  }
}

// ── Material Tag ──────────────────────────────────────────────────────────────
class _MaterialTag extends StatelessWidget {
  final String material;
  const _MaterialTag({required this.material});

  static Color _materialColor(String mat) {
    final m = mat.toLowerCase();
    if (m.contains('gold')) return AppColors.gold;
    if (m.contains('silver')) return const Color(0xFFC0C0C0);
    if (m.contains('rose')) return const Color(0xFFB76E79);
    if (m.contains('pearl')) return const Color(0xFFEAE0D5);
    if (m.contains('copper')) return AppColors.copper;
    if (m.contains('brass')) return AppColors.brass;
    return AppColors.gold;
  }

  @override
  Widget build(BuildContext context) {
    final color = _materialColor(material);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.6), width: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
      ),
      child: Text(
        material.toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
