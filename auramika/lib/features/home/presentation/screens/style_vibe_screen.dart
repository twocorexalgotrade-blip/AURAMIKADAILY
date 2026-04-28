import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../domain/home_models.dart';

class StyleVibeScreen extends StatelessWidget {
  final String vibeId;

  const StyleVibeScreen({super.key, required this.vibeId});

  @override
  Widget build(BuildContext context) {
    // 1. Find the category definition
    final category = HomeData.vibeCategories.firstWhere(
      (c) => c.id == vibeId,
      orElse: () => HomeData.vibeCategories.first, // Fallback
    );

    // 2. Filter products for this vibe
    final products = HomeData.allProducts.where((p) {
      // Flexible matching: check if product.vibe contains the category ID or title
      // We normalize to lowercase for safer comparison
      final pVibe = p.vibe.toLowerCase();
      final cId = category.id.toLowerCase();
      final cTitle = category.title.toLowerCase();
      return pVibe.contains(cId) || pVibe.contains(cTitle) || pVibe.contains('all');
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: category.primaryColor,
            expandedHeight: 140,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                category.title.toUpperCase(),
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.white,
                  letterSpacing: 1.5,
                  fontSize: 16,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: category.primaryColor),
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      category.icon,
                      size: 180,
                      color: AppColors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 20,
                    child: Text(
                      category.descriptor,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Product Grid ───────────────────────────────────────────────────
          if (products.isEmpty)
             SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'No items found in this collection yet.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppConstants.masonryMainAxisSpacing,
                  crossAxisSpacing: AppConstants.masonryCrossAxisSpacing,
                  childAspectRatio: 0.58,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final p = products[index];
                    return ProductCard(
                      id: p.id,
                      brandName: p.brandName,
                      productName: p.productName,
                      price: p.price,
                      material: p.material,
                      imageUrl: p.imageUrl,
                      isExpressAvailable: p.isExpressAvailable,
                      animationIndex: index,
                      onTap: () => context.push('/product/${p.id}'),
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
            
          // ── Bottom Spacing ────────────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
