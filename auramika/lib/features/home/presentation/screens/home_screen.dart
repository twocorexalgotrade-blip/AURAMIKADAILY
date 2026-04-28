import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../domain/home_models.dart';
import '../widgets/home_hero_section.dart';
import '../widgets/trending_edit_section.dart';
import '../widgets/vibe_grid_section.dart';
import '../../../custom_order/presentation/screens/custom_order_screen.dart';

/// AURAMIKA Home Screen — Phase 3
///
/// Sections (top → bottom):
///   1. AuramikaAppBar (transparent over hero)
///   2. HomeHeroSection — full-screen editorial slideshow
///   3. "Shop the Vibe" — VibeGridSection staggered masonry
///   4. TrendingEditSection — "The Weekend Edit" horizontal scroll
///   5. Mixed Brass+Copper product grid (all vibes)
///   6. Bottom padding (behind floating nav)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _appBarSolid = false;
  Color _heroBgColor = AppColors.forestGreen; // initial slide is dark

  static const Color _oliveGreen = Color(0xFF556B2F);

  Color get _logoColor {
    if (_appBarSolid) return _oliveGreen;
    // On bright slides (e.g. "Simply You" brass), use forest green to match mirror button
    return _heroBgColor.computeLuminance() > 0.1
        ? AppColors.forestGreen
        : AppColors.gold;
  }

  // Null = let the app bar resolve from its own backgroundColor (solid mode).
  // On transparent/bright slides (e.g. "Simply You" brass), use forest green
  // to match the mirror button's inactive container color.
  Color? get _iconColor {
    if (_appBarSolid) return null;
    return _heroBgColor.computeLuminance() > 0.1
        ? AppColors.forestGreen
        : AppColors.gold;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final solid = _scrollController.offset > 60;
    if (solid != _appBarSolid) setState(() => _appBarSolid = solid);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = HomeData.allProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AuramikaAppBar(
        showLogo: true,
        showSearch: true,
        showCart: true,
        transparent: !_appBarSolid,
        backgroundColor: _appBarSolid ? AppColors.background : Colors.transparent,
        logoColor: _logoColor,
        iconColor: _iconColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CustomOrderScreen()),
        ),
        backgroundColor: AppColors.forestGreen,
        elevation: 4,
        icon: const Icon(Icons.edit_outlined, color: AppColors.gold, size: 18),
        label: Text(
          'BESPOKE',
          style: AppTextStyles.categoryChip.copyWith(
            color: AppColors.white,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── 1. Hero Section ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: HomeHeroSection(
              onBgColorChanged: (color) {
                setState(() => _heroBgColor = color);
              },
            ),
          ),

          // ── 2. "Shop the Vibe" header ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingM,
                AppConstants.paddingXL,
                AppConstants.paddingM,
                AppConstants.paddingM,
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
                        'SHOP THE VIBE',
                        style: AppTextStyles.categoryChip.copyWith(
                          fontSize: 11,
                          letterSpacing: 3.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Find your aesthetic',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  // Material legend
                  Row(
                    children: [
                      _MaterialDot(color: AppColors.brass, label: 'Brass'),
                      const SizedBox(width: AppConstants.paddingS),
                      _MaterialDot(color: AppColors.copper, label: 'Copper'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── 3. Vibe Staggered Grid ───────────────────────────────────────
          SliverToBoxAdapter(
            child: VibeGridSection(
              onVibeTap: (vibeId) => context.pushNamed(
                'styleVibe',
                pathParameters: {'vibe': vibeId},
              ),
            ),
          ),

          // ── 4. Trending Edit ─────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: AppConstants.paddingXL),
              child: TrendingEditSection(),
            ),
          ),

          // ── 5. Browse by Category banner ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingM,
                AppConstants.paddingXL,
                AppConstants.paddingM,
                0,
              ),
              child: GestureDetector(
                onTap: () => context.push('/categories'),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingM,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                        ),
                        child: const Icon(Icons.grid_view_rounded,
                            color: AppColors.gold, size: 20),
                      ),
                      const SizedBox(width: AppConstants.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'JEWELLERY CATEGORIES',
                              style: AppTextStyles.categoryChip.copyWith(
                                color: AppColors.white,
                                fontSize: 11,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Traditional · Bridal · Kolhapuri & more',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white.withValues(alpha: 0.65),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: AppColors.gold, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── 6. Mixed Products header ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingM,
                AppConstants.paddingXL,
                AppConstants.paddingM,
                AppConstants.paddingM,
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
                        'NEW ARRIVALS',
                        style: AppTextStyles.categoryChip.copyWith(
                          fontSize: 11,
                          letterSpacing: 3.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Brass & Copper · Mixed',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${products.length} items',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── 6. Mixed Brass+Copper Product Grid ───────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppConstants.masonryMainAxisSpacing,
                crossAxisSpacing: AppConstants.masonryCrossAxisSpacing,
                childAspectRatio: 0.58,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final p = products[i];
                  return ProductCard(
                    id: p.id,
                    brandName: p.brandName,
                    productName: p.productName,
                    price: p.price,
                    material: p.material,
                    imageUrl: p.imageUrl,
                    isExpressAvailable: p.isExpressAvailable,
                    animationIndex: i,
                    onTap: () {
                      // Navigate to PDP — uses nested route under home branch
                      context.push('/product/${p.id}');
                    },
                  );
                },
                childCount: products.length,
              ),
            ),
          ),

          // ── 7. "Mixed Materials" editorial strip ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingM,
                AppConstants.paddingXL,
                AppConstants.paddingM,
                AppConstants.paddingM,
              ),
              child: _MixedMaterialsBanner(),
            ),
          ),

          // ── Bottom padding (behind floating nav) ─────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Material Dot Legend ───────────────────────────────────────────────────────
class _MaterialDot extends StatelessWidget {
  final Color color;
  final String label;
  const _MaterialDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(fontSize: 9),
        ),
      ],
    );
  }
}

// ── Mixed Materials Banner ────────────────────────────────────────────────────
class _MixedMaterialsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Gold half
          Expanded(
            child: Container(
              color: AppColors.gold.withValues(alpha: 0.12),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'GOLD',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.gold,
                        letterSpacing: 3.0,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Timeless Luxury',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gold.withValues(alpha: 0.7),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Divider
          Container(width: 0.5, color: AppColors.divider),
          // Silver half
          Expanded(
            child: Container(
              color: const Color(0xFFC0C0C0).withValues(alpha: 0.12),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SILVER',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: const Color(0xFFC0C0C0),
                        letterSpacing: 3.0,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Modern Elegance',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFFC0C0C0).withValues(alpha: 0.7),
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AppConstants.animNormal)
        .slideY(begin: 0.05, end: 0);
  }
}
