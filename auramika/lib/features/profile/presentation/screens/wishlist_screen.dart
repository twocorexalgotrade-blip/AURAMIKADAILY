import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../domain/wishlist_controller.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'Wishlist',
        showSearch: false,
        showCart: true,
        showBack: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
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
                  const Icon(Icons.favorite_rounded,
                      size: 14, color: AppColors.terraCotta),
                  const SizedBox(width: 6),
                  Text(
                    '${wishlist.items.length} saved piece${wishlist.items.length == 1 ? '' : 's'}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),

          if (wishlist.items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 56,
                      color: AppColors.textMuted.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    Text(
                      'Your wishlist is empty',
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: AppConstants.paddingS),
                    Text(
                      'Tap the heart on any piece to save it here',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.paddingXL),
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: Text(
                          'EXPLORE JEWELLERY',
                          style: AppTextStyles.categoryChip.copyWith(
                              color: AppColors.gold,
                              fontSize: 11,
                              letterSpacing: 2.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingM),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppConstants.masonryMainAxisSpacing,
                  crossAxisSpacing: AppConstants.masonryCrossAxisSpacing,
                  childAspectRatio: 0.58,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final item = wishlist.items[i];
                    return ProductCard(
                      id: item.id,
                      brandName: item.brandName,
                      productName: item.productName,
                      price: item.price,
                      material: item.material,
                      imageUrl: item.imageUrl,
                      isExpressAvailable: item.isExpressAvailable,
                      animationIndex: i,
                      onTap: () => context.push('/product/${item.id}'),
                    );
                  },
                  childCount: wishlist.items.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
