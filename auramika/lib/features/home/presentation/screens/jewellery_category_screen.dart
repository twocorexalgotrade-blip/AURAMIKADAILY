import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';

class _JewelleryCategory {
  final String name;
  final String? subtitle;
  final String imageAsset;
  const _JewelleryCategory({
    required this.name,
    this.subtitle,
    required this.imageAsset,
  });
}

const _categories = [
  _JewelleryCategory(
    name: 'Premium Bridal Chinchpeti',
    subtitle: 'For Perfect Bridal Looks & Royal Functions',
    imageAsset: 'assets/images/categories/bridal_chinchpeti.jpg',
  ),
  _JewelleryCategory(
    name: 'Traditionals',
    subtitle: 'Timeless, Authentic Maharashtrian Ornaments',
    imageAsset: 'assets/images/categories/traditionals.jpg',
  ),
  _JewelleryCategory(
    name: 'Minimal Chinchpeti',
    subtitle: 'Light Festive Wear with Maharashtrian Look',
    imageAsset: 'assets/images/categories/minimal_chinchpeti.jpg',
  ),
  _JewelleryCategory(
    name: 'Royal Thushi',
    subtitle: 'Brides, Heavy & Statement Pieces',
    imageAsset: 'assets/images/categories/royal_thushi.jpg',
  ),
  _JewelleryCategory(
    name: 'Fancy Minimal Thushi',
    subtitle: 'Lightweight, Stylish & Fancy Looks',
    imageAsset: 'assets/images/categories/fancy_minimal_thushi.jpg',
  ),
  _JewelleryCategory(
    name: 'Kolhapuri Thushi',
    subtitle: 'Traditional, Cultural & Iconic Kolhapuri Styles',
    imageAsset: 'assets/images/categories/kolhapuri_thushi.jpg',
  ),
  _JewelleryCategory(
    name: 'American Diamond Necklace',
    imageAsset: 'assets/images/categories/american_diamond.jpg',
  ),
  _JewelleryCategory(
    name: 'Short Moti Tanmani',
    imageAsset: 'assets/images/categories/short_moti_tanmani.jpg',
  ),
  _JewelleryCategory(
    name: 'Short Golden Tanmani',
    imageAsset: 'assets/images/categories/short_golden_tanmani.jpg',
  ),
  _JewelleryCategory(
    name: 'Long Moti Tanmani',
    subtitle: 'Graceful Touch to Bridal & Festive Wear',
    imageAsset: 'assets/images/categories/long_moti_tanmani.jpg',
  ),
  _JewelleryCategory(
    name: 'Kolhapuri Saaj',
    subtitle: 'Brides, Family Gatherings & Traditional Functions',
    imageAsset: 'assets/images/categories/kolhapuri_saaj.jpg',
  ),
  _JewelleryCategory(
    name: 'Mundavalya',
    imageAsset: 'assets/images/categories/mundavalya.jpg',
  ),
  _JewelleryCategory(
    name: 'Jhumka',
    imageAsset: 'assets/images/categories/jhumka.jpg',
  ),
  _JewelleryCategory(
    name: 'Earrings / Tops',
    subtitle: 'Festive Vibes and Office-Ready Elegance',
    imageAsset: 'assets/images/categories/earrings_tops.jpg',
  ),
  _JewelleryCategory(
    name: 'Nath',
    subtitle: 'Completing the Saree Look with Maharashtrian Touch',
    imageAsset: 'assets/images/categories/nath.jpg',
  ),
  _JewelleryCategory(
    name: 'Bugdi',
    imageAsset: 'assets/images/categories/bugdi.jpg',
  ),
  _JewelleryCategory(
    name: 'Earcuffs',
    subtitle: 'Every Occasion – Bridal, Festive, or Modern Chic',
    imageAsset: 'assets/images/categories/earcuffs.jpg',
  ),
  _JewelleryCategory(
    name: 'Earchains',
    imageAsset: 'assets/images/categories/earchains.jpg',
  ),
  _JewelleryCategory(
    name: 'Khopa (Ambada Pin)',
    imageAsset: 'assets/images/categories/khopa_pin.jpg',
  ),
  _JewelleryCategory(
    name: 'Bajuband',
    imageAsset: 'assets/images/categories/bajuband.jpg',
  ),
  _JewelleryCategory(
    name: 'Finger Ring',
    imageAsset: 'assets/images/categories/finger_ring.jpg',
  ),
  _JewelleryCategory(
    name: 'Kamarpatta',
    imageAsset: 'assets/images/categories/kamarpatta.jpg',
  ),
  _JewelleryCategory(
    name: 'Fancy Necklace',
    imageAsset: 'assets/images/categories/fancy_necklace.jpg',
  ),
];

class JewelleryCategoryScreen extends StatelessWidget {
  const JewelleryCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'Jewellery Categories',
        showSearch: true,
        showCart: true,
        showBack: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingM,
                AppConstants.paddingM,
                AppConstants.paddingM,
                AppConstants.paddingS,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BROWSE COLLECTIONS',
                    style: AppTextStyles.categoryChip.copyWith(
                      fontSize: 11,
                      letterSpacing: 3.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Authentic Maharashtrian & Traditional Jewellery',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: AppConstants.animNormal),
          ),

          // ── 2-column grid ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
              vertical: AppConstants.paddingS,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _CategoryCard(
                  category: _categories[i],
                  animIndex: i,
                ),
                childCount: _categories.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ── Category Card ─────────────────────────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  final _JewelleryCategory category;
  final int animIndex;

  const _CategoryCard({required this.category, required this.animIndex});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppConstants.animFast,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Product image
              Image.asset(
                cat.imageAsset,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.forestGreen.withValues(alpha: 0.08),
                  child: const Center(
                    child: Icon(
                      Icons.diamond_outlined,
                      color: AppColors.gold,
                      size: 40,
                    ),
                  ),
                ),
              ),

              // Gradient overlay — stronger at bottom for legibility
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.35, 1.0],
                    colors: [Colors.transparent, Color(0xE8101A14)],
                  ),
                ),
              ),

              // Text overlay
              Positioned(
                left: AppConstants.paddingS + 2,
                right: AppConstants.paddingS + 2,
                bottom: AppConstants.paddingS + 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cat.name,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.white,
                        fontSize: 12,
                        height: 1.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (cat.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        cat.subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                          fontSize: 9,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.animIndex * 40))
        .fadeIn(duration: AppConstants.animNormal)
        .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic);
  }
}
