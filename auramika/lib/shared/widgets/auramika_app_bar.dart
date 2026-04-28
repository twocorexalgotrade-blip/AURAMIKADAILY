import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../features/cart/presentation/controllers/cart_controller.dart';
import '../../features/home/domain/home_models.dart';

// Top-level alias so _ProductSearchDelegate can call showSearch without
// shadowing conflict from AuramikaAppBar's `showSearch` bool field.
Future<T?> _invokeSearch<T>({
  required BuildContext context,
  required SearchDelegate<T> delegate,
}) =>
    showSearch<T>(context: context, delegate: delegate);

/// AURAMIKA Custom App Bar
///
/// Design:
///   • Centered "AURAMIKA" wordmark in Cinzel serif
///   • Transparent / cream background, zero elevation
///   • Thin stroke search + cart icons (right actions)
///   • Optional back button (left) for nested routes
///   • Subtle bottom border divider
///   • Cart badge counter support
class AuramikaAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final bool showSearch;
  final bool showCart;
  final bool showBack;
  final List<Widget>? extraActions;
  final Color backgroundColor;
  final bool transparent;
  final Color? logoColor;
  final Color? iconColor;

  const AuramikaAppBar({
    super.key,
    this.title,
    this.showLogo = true,
    this.showSearch = true,
    this.showCart = true,
    this.showBack = false,
    this.extraActions,
    this.backgroundColor = AppColors.background,
    this.transparent = false,
    this.logoColor,
    this.iconColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppConstants.appBarHeight);

  // Returns gold for most backgrounds; falls back to textPrimary on yellow/gold
  // backgrounds where gold icons would camouflage. Caller may override via iconColor.
  Color _resolveIconColor() {
    if (iconColor != null) return iconColor!;
    if (transparent) return AppColors.gold;
    final hsl = HSLColor.fromColor(backgroundColor);
    // Yellow hue range ≈ 45–75°, guard against low-saturation near-white/cream
    if (hsl.hue >= 45 && hsl.hue <= 75 && hsl.saturation > 0.25) {
      return AppColors.textPrimary;
    }
    return AppColors.gold;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconColor = _resolveIconColor();
    final cartCount = showCart
        ? ref.watch(cartProvider).totalItems
        : 0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Container(
        height: preferredSize.height + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          color: transparent ? Colors.transparent : backgroundColor,
          border: transparent
              ? null
              : const Border(
                  bottom: BorderSide(color: AppColors.divider, width: 0.5),
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Left: Back button or profile avatar ──────────────────
              SizedBox(
                width: 80,
                child: showBack
                    ? _AppBarIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => context.canPop()
                            ? context.pop()
                            : context.go('/'),
                      )
                    : _ProfileAvatarButton(iconColor: iconColor),
              ),

              // ── Center: Logo or title ───────────────────────────────────
              Expanded(
                child: Center(
                  child: showLogo
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            AppConstants.appName,
                            style: AppTextStyles.brandLogo.copyWith(
                              fontSize: 64,
                              color: logoColor ?? AppColors.gold,
                              letterSpacing: 5.0,
                            ),
                            maxLines: 1,
                            softWrap: false,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: AppConstants.animNormal)
                      : Text(
                          (title ?? '').toUpperCase(),
                          style: AppTextStyles.titleMedium.copyWith(
                            letterSpacing: 3.0,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),

              // ── Right: Actions ──────────────────────────────────────────
              SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (extraActions != null) ...extraActions!,
                    if (showSearch)
                      _AppBarIconButton(
                        icon: Icons.search_rounded,
                        color: iconColor,
                        onTap: () => _invokeSearch(
                          context: context,
                          delegate: _ProductSearchDelegate(),
                        ),
                      ),
                    if (showCart)
                      _CartIconButton(count: cartCount, iconColor: iconColor),
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

// ── App Bar Icon Button ───────────────────────────────────────────────────────
class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _AppBarIconButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingS),
        child: Icon(
          icon,
          size: 20,
          color: color,
        ),
      ),
    );
  }
}

// ── Profile Avatar Button ─────────────────────────────────────────────────────
class _ProfileAvatarButton extends StatelessWidget {
  final Color iconColor;
  const _ProfileAvatarButton({this.iconColor = AppColors.gold});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.profile),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingS),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: iconColor.withValues(alpha: 0.5), width: 1.2),
            color: iconColor.withValues(alpha: 0.08),
          ),
          child: Center(
            child: Icon(Icons.person_outline_rounded, size: 16, color: iconColor),
          ),
        ),
      ),
    );
  }
}

// ── Product Search Delegate ───────────────────────────────────────────────────
class _ProductSearchDelegate extends SearchDelegate<HomeProduct?> {
  @override
  String get searchFieldLabel => 'Search jewelry…';

  List<HomeProduct> get _all => HomeData.allProducts;

  List<HomeProduct> _filter(String q) {
    final query = q.toLowerCase().trim();
    if (query.isEmpty) return _all.take(12).toList();
    return _all.where((p) {
      return p.productName.toLowerCase().contains(query) ||
          p.brandName.toLowerCase().contains(query) ||
          p.material.toLowerCase().contains(query) ||
          p.vibe.toLowerCase().contains(query);
    }).toList();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.gold),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.textSecondary),
        border: InputBorder.none,
      ),
      textTheme: Theme.of(context).textTheme.copyWith(
            titleLarge: AppTextStyles.titleMedium,
          ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: AppColors.gold),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context, _filter(query));

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context, _filter(query));

  Widget _buildList(BuildContext context, List<HomeProduct> results) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No results for "$query"',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, i) {
        final p = results[i];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: _productThumb(p.imageUrl),
          ),
          title: Text(p.productName, style: AppTextStyles.titleMedium.copyWith(fontSize: 13)),
          subtitle: Text(
            '${p.material} · ₹${p.price.toStringAsFixed(0)}',
            style: AppTextStyles.priceTag.copyWith(fontSize: 12),
          ),
          onTap: () {
            close(context, p);
            context.push('/product/${p.id}');
          },
        );
      },
    );
  }

  Widget _productThumb(String? url) {
    if (url == null) return _placeholder();
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    if (url.startsWith('assets')) {
      return Image.asset(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        width: 48,
        height: 48,
        color: AppColors.surface,
        child: const Icon(Icons.diamond_outlined, size: 20, color: AppColors.gold),
      );
}

// ── Cart Icon with Badge ──────────────────────────────────────────────────────
class _CartIconButton extends StatelessWidget {
  final int count;
  final Color iconColor;
  const _CartIconButton({required this.count, this.iconColor = AppColors.gold});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.cart),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingS),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 20,
              color: iconColor,
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: AppConstants.animFast,
                      curve: Curves.elasticOut,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
