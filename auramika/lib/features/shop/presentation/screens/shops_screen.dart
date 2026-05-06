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
import '../../domain/shop_models.dart';
import '../../domain/shop_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SHOPS SCREEN — Multi-Shop Browser
// ─────────────────────────────────────────────────────────────────────────────
class ShopsScreen extends ConsumerWidget {
  const ShopsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopsAsync = ref.watch(shopsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        title: 'SHOPS',
        showLogo: false,
        showSearch: true,
        showCart: true,
        showBack: false,
      ),
      body: shopsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (_, __) => _ShopsList(shops: ShopData.allShops),
        data: (shops) => _ShopsList(shops: shops),
      ),
    );
  }
}

class _ShopsList extends StatelessWidget {
  final List<ShopModel> shops;
  const _ShopsList({required this.shops});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingM,
        AppConstants.paddingM,
        AppConstants.paddingM,
        100,
      ),
      itemCount: shops.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppConstants.paddingM),
      itemBuilder: (context, i) {
        final shop = shops[i];
        return _ShopCard(
          shop: shop,
          onTap: () => context.push(AppRoutes.shopVendor(shop.id)),
        )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: i * 70),
              duration: AppConstants.animNormal,
            )
            .slideY(begin: 0.06, end: 0, curve: Curves.easeOut);
      },
    );
  }
}

// ── Shop Card ─────────────────────────────────────────────────────────────────
class _ShopCard extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback onTap;

  const _ShopCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeroBanner(shop: shop),
            _InfoBox(shop: shop),
          ],
        ),
      ),
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final ShopModel shop;
  const _HeroBanner({required this.shop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 178,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Banner photo
          CachedNetworkImage(
            imageUrl: shop.bannerImageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: shop.brandColor,
              child: Center(
                child: Text(
                  shop.name[0],
                  style: AppTextStyles.displaySmall.copyWith(
                    color: AppColors.gold,
                    fontSize: 52,
                  ),
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(color: shop.brandColor),
          ),

          // Bottom darkening — blends image into info box
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    shop.gradientColors[0].withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),

          // Left side fading gradient
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: 88,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    shop.brandColor.withValues(alpha: 0.65),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Right side fading gradient
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: 88,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    shop.brandColor.withValues(alpha: 0.65),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Gold accent line at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 1.5,
            child: Container(
              color: AppColors.gold.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Box ──────────────────────────────────────────────────────────────────
class _InfoBox extends StatelessWidget {
  final ShopModel shop;
  const _InfoBox({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingM,
        AppConstants.paddingS + 2,
        AppConstants.paddingM,
        AppConstants.paddingM - 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: shop.gradientColors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name + rating row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  shop.name.toUpperCase(),
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.white,
                    letterSpacing: 2.0,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppConstants.paddingS),
              Icon(Icons.star_rounded, size: 12, color: AppColors.gold),
              const SizedBox(width: 3),
              Text(
                '${shop.rating}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${shop.totalProducts} items',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white.withValues(alpha: 0.55),
                  fontSize: 10,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          // Description
          Text(
            shop.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withValues(alpha: 0.70),
              fontSize: 10.5,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 7),

          // Location + tags + arrow
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 10,
                color: AppColors.gold.withValues(alpha: 0.75),
              ),
              const SizedBox(width: 2),
              Text(
                shop.location,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white.withValues(alpha: 0.5),
                  fontSize: 9.5,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              ...shop.tags.take(2).map((tag) => Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.16),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusXS),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                          width: 0.6,
                        ),
                      ),
                      child: Text(
                        tag.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.gold,
                          fontSize: 8,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )),
              const SizedBox(width: AppConstants.paddingS),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: AppColors.gold.withValues(alpha: 0.7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Mini Shop Card — used in home screen horizontal strip ─────────────────────
class MiniShopCard extends StatelessWidget {
  final ShopModel shop;
  final VoidCallback onTap;

  const MiniShopCard({super.key, required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: SizedBox(
          width: 142,
          height: 108,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Banner image
              CachedNetworkImage(
                imageUrl: shop.bannerImageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: shop.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: shop.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Dark overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      shop.gradientColors[0].withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),

              // Left side fade
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: 36,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        shop.brandColor.withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Right side fade
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                width: 36,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        shop.brandColor.withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Gold top accent
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 1.5,
                child: Container(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),

              // Name + rating
              Positioned(
                bottom: 9,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      shop.name.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        fontSize: 9.5,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 9, color: AppColors.gold),
                        const SizedBox(width: 2),
                        Text(
                          '${shop.rating}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.gold,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${shop.totalProducts} items',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.white.withValues(alpha: 0.55),
                            fontSize: 8.5,
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
    );
  }
}
