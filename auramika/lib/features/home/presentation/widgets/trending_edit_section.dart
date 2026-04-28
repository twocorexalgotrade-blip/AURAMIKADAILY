import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/home_models.dart';

/// "The Weekend Edit" — Horizontal Trending Scroll
///
/// Design:
///   • Horizontal ListView of curated product cards
///   • Each card: 3:4 image ratio, sharp corners
///   • Material color-coded (Brass gold / Copper orange tint)
///   • Express badge overlay
///   • Price in Playfair serif
///   • Staggered slide-in animation
class TrendingEditSection extends StatelessWidget {
  const TrendingEditSection({super.key});

  @override
  Widget build(BuildContext context) {
    final products = HomeData.weekendEdit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingM,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THE WEEKEND EDIT',
                    style: AppTextStyles.categoryChip.copyWith(
                      fontSize: 11,
                      letterSpacing: 3.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Curated for you',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/vendor'),
                child: Text(
                  'See All',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: AppConstants.animNormal)
            .slideX(begin: -0.03, end: 0),

        const SizedBox(height: AppConstants.paddingM),

        // ── Horizontal scroll ───────────────────────────────────────────
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
            ),
            itemCount: products.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppConstants.paddingS + 4),
            itemBuilder: (context, i) {
              return _TrendingCard(
                product: products[i],
                animIndex: i,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Trending Card ─────────────────────────────────────────────────────────────
class _TrendingCard extends StatefulWidget {
  final HomeProduct product;
  final int animIndex;

  const _TrendingCard({required this.product, required this.animIndex});

  @override
  State<_TrendingCard> createState() => _TrendingCardState();
}

class _TrendingCardState extends State<_TrendingCard> {
  bool _pressed = false;

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

  static String _formatPrice(double price) {
    final n = price.toInt();
    if (n >= 1000) {
      final s = n.toString();
      return s.length == 4
          ? '${s[0]},${s.substring(1)}'
          : s.length == 5
              ? '${s.substring(0, 2)},${s.substring(2)}'
              : s;
    }
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final matColor = _materialColor(p.material);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        context.push('/product/${p.id}');
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: AppConstants.animFast,
        child: SizedBox(
          width: 155,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              border: Border.all(color: AppColors.divider, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image area (3:4) ──────────────────────────────────
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Product image
                      if (p.imageUrl != null && p.imageUrl!.startsWith('http'))
                        CachedNetworkImage(
                          imageUrl: p.imageUrl!,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          placeholder: (_, __) => Container(
                            color: matColor.withValues(alpha: 0.12),
                            child: Center(
                              child: Icon(Icons.diamond_outlined, color: matColor, size: 28),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: matColor.withValues(alpha: 0.12),
                            child: Center(
                              child: Icon(Icons.diamond_outlined, color: matColor, size: 28),
                            ),
                          ),
                        )
                      else if (p.imageUrl != null && p.imageUrl!.startsWith('assets'))
                        Image.asset(
                          p.imageUrl!,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (_, __, ___) => Container(
                            color: matColor.withValues(alpha: 0.12),
                            child: Center(
                              child: Icon(Icons.diamond_outlined, color: matColor, size: 28),
                            ),
                          ),
                        )
                      else
                        Container(
                          color: matColor.withValues(alpha: 0.12),
                          child: Center(
                            child: Icon(Icons.diamond_outlined, color: matColor, size: 28),
                          ),
                        ),

                      // Express badge
                      if (p.isExpressAvailable)
                        Positioned(
                          top: AppConstants.paddingS,
                          left: AppConstants.paddingS,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.forestGreen,
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusXS,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.bolt,
                                  size: 8,
                                  color: AppColors.gold,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '2 HRS',
                                  style: AppTextStyles.expressBadge.copyWith(
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Vibe tag (top-right)
                      Positioned(
                        top: AppConstants.paddingS,
                        right: AppConstants.paddingS,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusXS,
                            ),
                          ),
                          child: Text(
                            p.vibe.split(' ').first.toUpperCase(),
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Info ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingS),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.brandName,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 8,
                          letterSpacing: 1.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.productName,
                        style: AppTextStyles.titleSmall.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${_formatPrice(p.price)}',
                            style: AppTextStyles.priceTag.copyWith(fontSize: 15),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: matColor.withValues(alpha: 0.5),
                                width: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusXS,
                              ),
                            ),
                            child: Text(
                              p.material.toUpperCase(),
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w700,
                                color: matColor,
                                letterSpacing: 1.0,
                              ),
                            ),
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
      ),
    )
        .animate(delay: Duration(milliseconds: widget.animIndex * 60))
        .fadeIn(duration: AppConstants.animNormal)
        .slideX(
          begin: 0.1,
          end: 0,
          duration: AppConstants.animNormal,
          curve: Curves.easeOutCubic,
        );
  }
}
