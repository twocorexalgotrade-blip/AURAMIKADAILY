import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/product_model.dart';

/// Full-screen image gallery for PDP
///
/// Features:
///   • PageView of product images (full-bleed)
///   • Dot indicator
///   • Transparent overlay with back + share + wishlist
///   • "See it on you" AR/Magic Mirror button (animated gold glow)
///   • Material + discount badge overlays
class PdpImageGallery extends StatefulWidget {
  final ProductDetail product;
  final bool isWishlisted;
  final VoidCallback onWishlistTap;
  final VoidCallback onMirrorTap;
  final VoidCallback onBack;
  final VoidCallback onShareTap;

  const PdpImageGallery({
    super.key,
    required this.product,
    required this.isWishlisted,
    required this.onWishlistTap,
    required this.onMirrorTap,
    required this.onBack,
    required this.onShareTap,
  });

  @override
  State<PdpImageGallery> createState() => _PdpImageGalleryState();
}

class _PdpImageGalleryState extends State<PdpImageGallery> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  int get _imageCount =>
      widget.product.imageUrls.isEmpty ? 1 : widget.product.imageUrls.length;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final matColor = widget.product.materialColor;

    return SizedBox(
      height: screenHeight * 0.65,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Image PageView ──────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _imageCount,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) => _ImageSlide(
              product: widget.product,
              index: i,
            ),
          ),

          // ── Bottom gradient ─────────────────────────────────────────────
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 160,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xF0FAFAF5)],
                ),
              ),
            ),
          ),

          // ── Top overlay: back + actions ─────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: AppConstants.paddingS,
            right: AppConstants.paddingS,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back
                _GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: widget.onBack,
                ),
                // Share + Wishlist
                Row(
                  children: [
                    _GlassIconButton(
                      icon: Icons.share_outlined,
                      onTap: widget.onShareTap,
                    ),
                    const SizedBox(width: 8),
                    _GlassIconButton(
                      icon: widget.isWishlisted
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: widget.isWishlisted
                          ? AppColors.terraCotta
                          : AppColors.textPrimary,
                      onTap: widget.onWishlistTap,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Material badge (top-left below back) ────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 64,
            left: AppConstants.paddingM,
            child: _MaterialBadge(
              material: widget.product.material,
              color: matColor,
            ),
          ),

          // ── Discount badge ──────────────────────────────────────────────
          if (widget.product.hasDiscount)
            Positioned(
              top: MediaQuery.of(context).padding.top + 64,
              right: AppConstants.paddingM,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.terraCotta,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                ),
                child: Text(
                  '${widget.product.discountPercent}% OFF',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

          // ── Page dots ───────────────────────────────────────────────────
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _imageCount,
                (i) => AnimatedContainer(
                  duration: AppConstants.animFast,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _currentPage ? 18 : 6,
                  height: 3,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? matColor
                        : AppColors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          // ── "See it on you" AR Button ────────────────────────────────────
          Positioned(
            bottom: 24,
            left: AppConstants.paddingM,
            right: AppConstants.paddingM,
            child: _MagicMirrorButton(onTap: widget.onMirrorTap),
          ),
        ],
      ),
    );
  }
}

// ── Image Slide ───────────────────────────────────────────────────────────────
class _ImageSlide extends StatelessWidget {
  final ProductDetail product;
  final int index;

  const _ImageSlide({required this.product, required this.index});

  /// Try to resolve an asset path for this product/index
  String? get _assetPath {
    // If product has explicit imageUrls, use those
    if (product.imageUrls.isNotEmpty && index < product.imageUrls.length) {
      return product.imageUrls[index];
    }
    // For the first slide, try to find a matching asset from the product id
    if (index == 0) {
      // Convention: assets/images/products/<id>_<suffix>.png
      // We'll try common suffixes based on product id prefix
      final id = product.id;
      final Map<String, String> assetMap = {
        'e1': 'assets/images/products/e1_gold_hoops.png',
        'e2': 'assets/images/products/e2_crystal_drop.png',
        'e3': 'assets/images/products/e3_pearl_studs.png',
        'e4': 'assets/images/products/e4_coin_dangle.png',
        'e5': 'assets/images/products/e5_emerald_studs.png',
        'e6': 'assets/images/products/e6_rose_huggies.png',
        'e7': 'assets/images/products/e7_geo_hoops.png',
        'e8': 'assets/images/products/e8_kundan_chandbali.png',
        'e9': 'assets/images/products/e9_chain_drop.png',
        'e10': 'assets/images/products/e10_heart_studs.png',
        'e11': 'assets/images/products/e11_matte_statement.png',
        'e12': 'assets/images/products/e12_silver_threaders.png',
        'e13': 'assets/images/products/e13_baroque_pearl.png',
        'e14': 'assets/images/products/e14_rainbow_hoops.png',
        'e15': 'assets/images/products/e15_black_enamel.png',
        'n1': 'assets/images/products/n1_herringbone.png',
        'n2': 'assets/images/products/n2_tennis_neck.png',
        'n3': 'assets/images/products/n3_layered_coin.png',
        'n4': 'assets/images/products/n4_pearl_choker.png',
        'n5': 'assets/images/products/n5_initial_pendant.png',
        'n6': 'assets/images/products/n6_evil_eye.png',
        'n7': 'assets/images/products/n7_y_necklace.png',
        'n8': 'assets/images/products/n8_curb_chain.png',
        'n9': 'assets/images/products/n9_snake_chain.png',
        'n10': 'assets/images/products/n10_emerald_pendant.png',
        'n11': 'assets/images/products/n11_butterfly.png',
        'n12': 'assets/images/products/n12_temple_neck.png',
        'n13': 'assets/images/products/n13_paperclip.png',
        'n14': 'assets/images/products/n14_mangalsutra.png',
        'n15': 'assets/images/products/n15_zircon_choker.png',
        'r1': 'assets/images/products/r1_signet.png',
        'r2': 'assets/images/products/r2_solitaire.png',
        'r3': 'assets/images/products/r3_stack_set.png',
        'r4': 'assets/images/products/r4_abstract_ring.png',
        'r5': 'assets/images/products/r5_cocktail_ring.png',
        'r6': 'assets/images/products/r6_pearl_ring.png',
        'r7': 'assets/images/products/r7_serpent_ring.png',
        'r8': 'assets/images/products/r8_eternity_band.png',
        'r9': 'assets/images/products/r9_heart_signet.png',
        'r10': 'assets/images/products/r10_adjust_eye.png',
        'b1': 'assets/images/products/b1_tennis_bracelet.png',
        'b2': 'assets/images/products/b2_gold_link.png',
        'b3': 'assets/images/products/b3_charm_bracelet.png',
        'b4': 'assets/images/products/b4_cuff_bangle.png',
        'b5': 'assets/images/products/b5_leather_band.png',
        'b6': 'assets/images/products/b6_evil_eye_brace.png',
        'b7': 'assets/images/products/b7_pearl_bracelet.png',
        'b8': 'assets/images/products/b8_zircon_bangles.png',
        'b9': 'assets/images/products/b9_min_chain.png',
        'b10': 'assets/images/products/b10_curb_brace.png',
      };
      return assetMap[id];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final matColor = product.materialColor;
    final asset = _assetPath;

    if (asset != null && asset.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: asset,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        placeholder: (_, __) => _buildPlaceholder(matColor),
        errorWidget: (_, __, ___) => _buildPlaceholder(matColor),
      );
    }

    if (asset != null && asset.startsWith('assets')) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(matColor),
      );
    }

    return _buildPlaceholder(matColor);
  }

  Widget _buildPlaceholder(Color matColor) {
    final shade = [0.10, 0.14, 0.08][index % 3];
    return Container(
      color: matColor.withValues(alpha: shade),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.diamond_outlined, color: matColor, size: 72),
            const SizedBox(height: 12),
            Text(
              product.material.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: matColor,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View ${index + 1}',
              style: TextStyle(
                fontSize: 9,
                color: matColor.withValues(alpha: 0.5),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Glass Icon Button ─────────────────────────────────────────────────────────
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: iconColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── Material Badge ────────────────────────────────────────────────────────────
class _MaterialBadge extends StatelessWidget {
  final String material;
  final Color color;

  const _MaterialBadge({required this.material, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            material.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Magic Mirror "See it on you" Button ───────────────────────────────────────
class _MagicMirrorButton extends StatefulWidget {
  final VoidCallback onTap;
  const _MagicMirrorButton({required this.onTap});

  @override
  State<_MagicMirrorButton> createState() => _MagicMirrorButtonState();
}

class _MagicMirrorButtonState extends State<_MagicMirrorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, child) {
          final glowRadius = 8.0 + (_glowAnim.value * 14.0);
          final glowOpacity = 0.25 + (_glowAnim.value * 0.2);

          return Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: glowOpacity),
                  blurRadius: glowRadius,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rotating sparkle icon
            _RotatingSparkle(),
            const SizedBox(width: AppConstants.paddingS),
            Text(
              'SEE IT ON YOU',
              style: AppTextStyles.categoryChip.copyWith(
                color: AppColors.textPrimary,
                fontSize: 12,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppConstants.paddingS),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 300))
        .slideY(begin: 0.1, end: 0);
  }
}

// ── Rotating Sparkle ──────────────────────────────────────────────────────────
class _RotatingSparkle extends StatefulWidget {
  @override
  State<_RotatingSparkle> createState() => _RotatingSparkleState();
}

class _RotatingSparkleState extends State<_RotatingSparkle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.rotate(
        angle: _ctrl.value * 2 * math.pi,
        child: child,
      ),
      child: const Icon(
        Icons.auto_awesome,
        size: 18,
        color: AppColors.textPrimary,
      ),
    );
  }
}
