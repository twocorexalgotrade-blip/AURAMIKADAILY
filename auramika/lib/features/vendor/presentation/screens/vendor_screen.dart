import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../shop/domain/shop_models.dart';
import '../../../shop/domain/shop_provider.dart';

enum _SortOrder { featured, priceLow, priceHigh, nameAZ }

// ── Vendor Product Model ──────────────────────────────────────────────────────
class VendorProduct {
  final String id;
  final String name;
  final double price;
  final String material; // 'Gold' | 'Silver'
  final String imageUrl;
  final bool isExpress;
  final bool isWishlisted;

  const VendorProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.material,
    required this.imageUrl,
    this.isExpress = true,
    this.isWishlisted = false,
  });
}

// ── Vendor Model ──────────────────────────────────────────────────────────────
class VendorInfo {
  final String id;
  final String name;
  final String tagline;
  final String location;
  final int totalProducts;
  final double rating;
  final int reviewCount;
  final Color brandColor;
  final List<VendorProduct> products;

  const VendorInfo({
    required this.id,
    required this.name,
    required this.tagline,
    required this.location,
    required this.totalProducts,
    required this.rating,
    required this.reviewCount,
    required this.brandColor,
    required this.products,
  });
}

// ── Mock Vendor Data ──────────────────────────────────────────────────────────
final _mockVendor = VendorInfo(
  id: 'v1',
  name: 'Auramika Studio',
  tagline: 'Premium Imitation Jewelry · Gold · Silver · Diamond',
  location: 'Jaipur, Rajasthan',
  totalProducts: 16,
  rating: 4.8,
  reviewCount: 342,
  brandColor: const Color(0xFF0C2B1E),
  products: const [
    VendorProduct(id: 'e1', name: 'Chunky Gold Hoops', price: 499, material: 'Gold', imageUrl: 'assets/images/products/e1_gold_hoops.jpg', isExpress: true),
    VendorProduct(id: 'e3', name: 'Pearl Studs', price: 299, material: 'Gold', imageUrl: 'assets/images/products/e3_pearl_studs.jpg', isExpress: true),
    VendorProduct(id: 'e2', name: 'Crystal Drop Earrings', price: 899, material: 'Silver', imageUrl: 'assets/images/products/e2_crystal_drop.jpg', isExpress: true),
    VendorProduct(id: 'n1', name: 'Herringbone Chain', price: 699, material: 'Gold', imageUrl: 'assets/images/products/n1_herringbone.jpg', isExpress: true),
    VendorProduct(id: 'n2', name: 'Diamond Tennis Necklace', price: 1499, material: 'Silver', imageUrl: 'assets/images/products/n2_tennis_neck.jpg', isExpress: false),
    VendorProduct(id: 'e8', name: 'Kundan Chandbali', price: 1299, material: 'Gold', imageUrl: 'assets/images/products/e8_kundan_chandbali.jpg', isExpress: true),
    VendorProduct(id: 'r1', name: 'Signet Ring', price: 499, material: 'Gold', imageUrl: 'assets/images/products/r1_signet.jpg', isExpress: true),
    VendorProduct(id: 'r2', name: 'Solitaire Ring', price: 599, material: 'Silver', imageUrl: 'assets/images/products/r2_solitaire.jpg', isExpress: true),
    VendorProduct(id: 'b1', name: 'Tennis Bracelet', price: 999, material: 'Silver', imageUrl: 'assets/images/products/b1_tennis_bracelet.jpg', isExpress: true),
    VendorProduct(id: 'b2', name: 'Gold Link Bracelet', price: 699, material: 'Gold', imageUrl: 'assets/images/products/b2_gold_link.jpg', isExpress: true),
    VendorProduct(id: 'n8', name: 'Chunky Curb Chain', price: 999, material: 'Gold', imageUrl: 'assets/images/products/n8_curb_chain.jpg', isExpress: true),
    VendorProduct(id: 'e6', name: 'Rose Gold Huggies', price: 399, material: 'Gold', imageUrl: 'assets/images/products/e6_rose_huggies.jpg', isExpress: true),
    VendorProduct(id: 'n15', name: 'Zircon Statement Choker', price: 1999, material: 'Silver', imageUrl: 'assets/images/products/n15_zircon_choker.jpg', isExpress: true),
    VendorProduct(id: 'r5', name: 'Cocktail Stone Ring', price: 899, material: 'Gold', imageUrl: 'assets/images/products/r5_cocktail_ring.jpg', isExpress: false),
    VendorProduct(id: 'b8', name: 'Zircon Bangles Set', price: 1499, material: 'Gold', imageUrl: 'assets/images/products/b8_zircon_bangles.jpg', isExpress: true),
    VendorProduct(id: 'e13', name: 'Baroque Pearl Drop', price: 999, material: 'Gold', imageUrl: 'assets/images/products/e13_baroque_pearl.jpg', isExpress: true),
  ],
);

// ── Live vendor provider ──────────────────────────────────────────────────────
final vendorInfoProvider =
    FutureProvider.family<VendorInfo, String>((ref, vendorId) async {
  final dio = ref.watch(apiServiceProvider);
  try {
    final results = await Future.wait([
      dio.get<dynamic>('/vendors/$vendorId'),
      dio.get<dynamic>('/vendors/$vendorId/products',
          queryParameters: {'limit': '50'}),
    ]);

    final v = results[0].data as Map<String, dynamic>;
    final rows =
        (results[1].data['products'] as List).cast<Map<String, dynamic>>();

    return VendorInfo(
      id: v['id'] as String,
      name: v['name'] as String,
      tagline: (v['description'] as String?) ?? 'Premium Jewelry Collection',
      location: 'India',
      totalProducts: rows.length,
      rating: (v['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: 0,
      brandColor: AppColors.forestGreen,
      products: rows.map((p) {
        final imgs = p['image_urls'];
        final url = (imgs is List && imgs.isNotEmpty) ? imgs.first as String : '';
        return VendorProduct(
          id: p['id'] as String,
          name: (p['product_name'] as String?) ?? '',
          price: (p['price'] as num).toDouble(),
          material: (p['material'] as String?) ?? 'Gold',
          imageUrl: url,
          isExpress: (p['is_express'] as bool?) ?? false,
        );
      }).toList(),
    );
  } catch (_) {
    // Only v1 (Auramika Studio) keeps its curated mock products
    if (vendorId == 'v1') return _mockVendor;
    // All other shops: show their real name/info but empty products
    ShopModel? staticShop;
    try {
      staticShop = ShopData.allShops.firstWhere((s) => s.id == vendorId);
    } catch (_) {}
    return VendorInfo(
      id: vendorId,
      name: staticShop?.name ?? 'Store',
      tagline: staticShop?.description ?? 'Premium Jewelry Collection',
      location: staticShop?.location ?? 'India',
      totalProducts: 0,
      rating: staticShop?.rating ?? 4.5,
      reviewCount: 0,
      brandColor: AppColors.forestGreen,
      products: const [],
    );
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// VENDOR SCREEN
// ─────────────────────────────────────────────────────────────────────────────

/// AURAMIKA Vendor Shop Screen — Phase 4
///
/// Layout:
///   • Collapsing editorial banner header (SliverAppBar)
///   • Centered vendor avatar + name + stats
///   • Sticky material tabs: [All] [Gold] [Silver]
///   • Filtered 2-column product grid
///   • "Gold" tab STRICTLY shows only Gold items
class VendorScreen extends ConsumerStatefulWidget {
  final String? vendorId;
  const VendorScreen({super.key, this.vendorId});

  @override
  ConsumerState<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends ConsumerState<VendorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  _SortOrder _sortOrder = _SortOrder.featured;

  // ── Material filter tabs ──────────────────────────────────────────────────
  static const List<String> _tabs = ['All', 'Gold', 'Silver', 'Coming Soon'];

  List<VendorProduct> _filteredProducts(VendorInfo vendor) {
    final tab = _tabs[_tabController.index];
    var list = tab == 'All'
        ? vendor.products.toList()
        : tab == 'Coming Soon'
            ? <VendorProduct>[]
            : vendor.products.where((p) => p.material == tab).toList();
    switch (_sortOrder) {
      case _SortOrder.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case _SortOrder.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
      case _SortOrder.nameAZ:
        list.sort((a, b) => a.name.compareTo(b.name));
      case _SortOrder.featured:
        break;
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showShareSheet(VendorInfo vendor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _VendorShareSheet(vendor: vendor),
    );
  }

  void _showSearchSheet(VendorInfo vendor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _VendorSearchSheet(
        products: vendor.products,
        onProductTap: (id) {
          Navigator.pop(context);
          context.push(AppRoutes.product(id));
        },
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        current: _sortOrder,
        onSelect: (order) {
          setState(() => _sortOrder = order);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveId = widget.vendorId?.isNotEmpty == true ? widget.vendorId! : 'v1';
    final vendorAsync = ref.watch(vendorInfoProvider(effectiveId));
    final shopsAsync = ref.watch(shopsProvider);

    // Build instant fallback from the already-cached shop grid data so the
    // correct shop name shows immediately instead of flashing "Auramika Studio"
    ShopModel? shopModel;
    final shopList = shopsAsync.valueOrNull ?? [];
    for (final s in shopList) {
      if (s.id == effectiveId) { shopModel = s; break; }
    }
    final fallback = shopModel != null
        ? VendorInfo(
            id: shopModel.id,
            name: shopModel.name,
            tagline: shopModel.description,
            location: shopModel.location,
            totalProducts: shopModel.totalProducts,
            rating: shopModel.rating,
            reviewCount: 0,
            brandColor: shopModel.brandColor,
            products: const [],
          )
        : _mockVendor;

    final rawVendor = vendorAsync.valueOrNull ?? fallback;
    // Always use the colour from the shop grid so card and screen match exactly
    final vendor = shopModel != null
        ? VendorInfo(
            id: rawVendor.id,
            name: rawVendor.name,
            tagline: rawVendor.tagline,
            location: rawVendor.location,
            totalProducts: rawVendor.totalProducts,
            rating: rawVendor.rating,
            reviewCount: rawVendor.reviewCount,
            brandColor: shopModel.brandColor,
            products: rawVendor.products,
          )
        : rawVendor;
    final filtered = _filteredProducts(vendor);
    final currentTab = _tabs[_tabController.index];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Collapsing Banner ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              color: AppColors.white,
              onPressed: () => context.canPop() ? context.pop() : context.go('/shop'),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20, color: AppColors.white),
                onPressed: () => _showShareSheet(vendor),
              ),
              IconButton(
                icon: const Icon(Icons.search_rounded, size: 20, color: AppColors.white),
                onPressed: () => _showSearchSheet(vendor),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _VendorBannerHeader(vendor: vendor),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(height: 0.5, color: AppColors.divider),
            ),
          ),

          // ── Vendor Info Card ────────────────────────────────────────────
          SliverToBoxAdapter(child: _VendorInfoCard(vendor: vendor)),

          // ── Sticky Material Tabs ────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabBarDelegate(
              tabController: _tabController,
              tabs: _tabs,
            ),
          ),

          // ── Filter summary bar ──────────────────────────────────────────
          if (filtered.isNotEmpty)
            SliverToBoxAdapter(
              child: _FilterSummaryBar(
                count: filtered.length,
                material: currentTab,
                sortOrder: _sortOrder,
                onSort: _showSortSheet,
              ),
            ),

          // ── Product grid or empty state ─────────────────────────────────
          if (vendorAsync.isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Loading products...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyMaterialState(material: currentTab),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingM,
                AppConstants.paddingS,
                AppConstants.paddingM,
                100,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.58,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final p = filtered[i];
                    return ProductCard(
                      id: p.id,
                      brandName: 'AURAMIKA',
                      productName: p.name,
                      price: p.price,
                      material: p.material,
                      imageUrl: p.imageUrl,
                      isExpressAvailable: p.isExpress,
                      isWishlisted: p.isWishlisted,
                      animationIndex: i,
                      onTap: () => context.push(AppRoutes.product(p.id)),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Vendor Banner Header ──────────────────────────────────────────────────────
class _VendorBannerHeader extends StatelessWidget {
  final VendorInfo vendor;
  const _VendorBannerHeader({required this.vendor});

  static const String _bannerImage =
      'https://images.unsplash.com/photo-1617038260897-41a1f14a8ca0?auto=format&fit=crop&w=800&q=80';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Editorial photo background ────────────────────────────────────
        CachedNetworkImage(
          imageUrl: _bannerImage,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: vendor.brandColor,
            child: CustomPaint(painter: _BannerPatternPainter()),
          ),
          errorWidget: (_, __, ___) => Container(
            color: vendor.brandColor,
            child: CustomPaint(painter: _BannerPatternPainter()),
          ),
        ),

        // ── Dark overlay for contrast ─────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                vendor.brandColor.withValues(alpha: 0.55),
                vendor.brandColor.withValues(alpha: 0.90),
              ],
            ),
          ),
        ),

        // ── Pattern overlay ───────────────────────────────────────────────
        CustomPaint(painter: _BannerPatternPainter()),

        // ── Gold accent line (top) ────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 2,
          child: Container(color: AppColors.gold),
        ),

        // ── Centered avatar + name ────────────────────────────────────────
        Positioned(
          bottom: AppConstants.paddingL,
          left: 0,
          right: 0,
          child: Column(
            children: [
              // Gold ring avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.forestGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    vendor.name.substring(0, 1),
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.gold,
                      fontSize: 28,
                    ),
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: AppConstants.animNormal,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: AppConstants.paddingS),

              // Vendor name
              Text(
                vendor.name.toUpperCase(),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.white,
                  letterSpacing: 4.0,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 4),

              // Gold divider line
              Container(
                width: 32,
                height: 1,
                color: AppColors.gold.withValues(alpha: 0.6),
              ),

              const SizedBox(height: 4),

              // Location
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 11,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    vendor.location,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.75),
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Vendor Info Card ──────────────────────────────────────────────────────────
class _VendorInfoCard extends StatelessWidget {
  final VendorInfo vendor;
  const _VendorInfoCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingL,
        vertical: AppConstants.paddingM,
      ),
      child: Column(
        children: [
          // Tagline
          Text(
            vendor.tagline,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.paddingM),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                value: '${vendor.totalProducts}',
                label: 'Products',
              ),
              _StatDivider(),
              _StatItem(
                value: '${vendor.rating}',
                label: 'Rating',
                valueColor: AppColors.gold,
              ),
              _StatDivider(),
              _StatItem(
                value: '${vendor.reviewCount}',
                label: 'Reviews',
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingM),

          // Express delivery badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
              vertical: AppConstants.paddingS - 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              border: Border.all(
                color: AppColors.forestGreen.withValues(alpha: 0.2),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 13, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  AppConstants.expressDeliveryLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.forestGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _StatItem({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            fontSize: 18,
            color: valueColor ?? AppColors.textPrimary,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 9,
            letterSpacing: 1.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 32,
      color: AppColors.divider,
    );
  }
}

// ── Sticky Tab Bar Delegate ───────────────────────────────────────────────────
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<String> tabs;

  const _StickyTabBarDelegate({
    required this.tabController,
    required this.tabs,
  });

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: TabBar(
        controller: tabController,
        tabs: tabs
            .map((t) => Tab(
                  child: Text(
                    t.toUpperCase(),
                    style: AppTextStyles.categoryChip.copyWith(
                      fontSize: 11,
                      letterSpacing: 2.0,
                    ),
                  ),
                ))
            .toList(),
        labelColor: AppColors.forestGreen,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.gold,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate old) =>
      old.tabController != tabController || old.tabs != tabs;
}

// ── Filter Summary Bar ────────────────────────────────────────────────────────
class _FilterSummaryBar extends StatelessWidget {
  final int count;
  final String material;
  final _SortOrder sortOrder;
  final VoidCallback onSort;

  const _FilterSummaryBar({
    required this.count,
    required this.material,
    required this.sortOrder,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final isGold = material == 'Gold';
    final isSilver = material == 'Silver';
    final matColor = isGold
        ? AppColors.gold
        : isSilver
            ? const Color(0xFFC0C0C0)
            : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS + 2,
      ),
      child: Row(
        children: [
          // Count
          Text(
            '$count ${count == 1 ? 'item' : 'items'}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),

          if (material != 'All') ...[
            const SizedBox(width: AppConstants.paddingS),
            // Active filter chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: matColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                border: Border.all(
                  color: matColor.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: matColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    material.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: matColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ONLY',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: matColor.withValues(alpha: 0.7),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Sort button
          GestureDetector(
            onTap: onSort,
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 14,
                  color: sortOrder != _SortOrder.featured
                      ? AppColors.forestGreen
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  sortOrder != _SortOrder.featured ? 'SORTED' : 'SORT',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color: sortOrder != _SortOrder.featured
                        ? AppColors.forestGreen
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyMaterialState extends StatelessWidget {
  final String material;
  const _EmptyMaterialState({required this.material});

  @override
  Widget build(BuildContext context) {
    if (material == 'All') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.3), width: 1),
                color: AppColors.surface,
              ),
              child: const Icon(Icons.storefront_outlined, size: 32, color: AppColors.textMuted),
            )
                .animate()
                .fadeIn(duration: AppConstants.animSlow)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Text(
              'No items yet',
              style: AppTextStyles.headlineSmall.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'This store hasn\'t added any products yet',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    if (material == 'Coming Soon') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1),
                color: AppColors.gold.withValues(alpha: 0.06),
              ),
              child: const Icon(Icons.auto_awesome_outlined, size: 32, color: AppColors.gold),
            )
                .animate()
                .fadeIn(duration: AppConstants.animSlow)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Text(
              'NEW COLLECTION',
              style: AppTextStyles.categoryChip.copyWith(
                color: AppColors.gold,
                letterSpacing: 4.0,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dropping Soon',
              style: AppTextStyles.headlineSmall.copyWith(
                fontSize: 22,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(width: 32, height: 1, color: AppColors.gold.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              'Exclusive designs crafted for you',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    final color =
        material == 'Gold' ? AppColors.gold : const Color(0xFFC0C0C0);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.diamond_outlined, size: 48, color: color),
          const SizedBox(height: AppConstants.paddingM),
          Text(
            'No $material items',
            style: AppTextStyles.headlineSmall.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Text(
            'Check back soon for new arrivals',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ── Banner Pattern Painter ────────────────────────────────────────────────────
class _BannerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.07)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 28.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Vendor Share Sheet ────────────────────────────────────────────────────────
class _VendorShareSheet extends StatelessWidget {
  final VendorInfo vendor;
  const _VendorShareSheet({required this.vendor});

  String get _shareText =>
      '${vendor.name}\n${vendor.tagline}\n'
      '${vendor.totalProducts} products · ★ ${vendor.rating}\nShop on AURAMIKA';

  void _copyAndClose(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _shareText));
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(
      content: Text('Copied to clipboard',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
      backgroundColor: AppColors.forestGreen,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(AppConstants.paddingM, AppConstants.paddingM,
          AppConstants.paddingM, AppConstants.paddingM + bottomPad),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 3,
            decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: AppColors.forestGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    vendor.name.substring(0, 1),
                    style: AppTextStyles.displaySmall
                        .copyWith(color: AppColors.gold, fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendor.name,
                        style: AppTextStyles.titleSmall.copyWith(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(vendor.location,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _VendorShareOption(
                  icon: Icons.message_rounded, label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () => _copyAndClose(context)),
              _VendorShareOption(
                  icon: Icons.camera_alt_outlined, label: 'Instagram',
                  color: const Color(0xFFE1306C),
                  onTap: () => _copyAndClose(context)),
              _VendorShareOption(
                  icon: Icons.copy_rounded, label: 'Copy Link',
                  color: AppColors.gold,
                  onTap: () => _copyAndClose(context)),
              _VendorShareOption(
                  icon: Icons.more_horiz_rounded, label: 'More',
                  color: AppColors.textMuted,
                  onTap: () => _copyAndClose(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _VendorShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _VendorShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(fontSize: 10, letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

// ── Vendor Search Sheet ───────────────────────────────────────────────────────
class _VendorSearchSheet extends StatefulWidget {
  final List<VendorProduct> products;
  final ValueChanged<String> onProductTap;

  const _VendorSearchSheet(
      {required this.products, required this.onProductTap});

  @override
  State<_VendorSearchSheet> createState() => _VendorSearchSheetState();
}

class _VendorSearchSheetState extends State<_VendorSearchSheet> {
  String _query = '';

  List<VendorProduct> get _results {
    if (_query.isEmpty) return widget.products;
    final q = _query.toLowerCase();
    return widget.products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.material.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final results = _results;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(bottom: bottomPad),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppConstants.paddingM),
          Container(
            width: 36, height: 3,
            decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingM),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusS),
                border: Border.all(
                    color: AppColors.divider, width: 0.5),
              ),
              child: Row(
                children: [
                  const SizedBox(width: AppConstants.paddingS),
                  const Icon(Icons.search_rounded,
                      size: 18, color: AppColors.textMuted),
                  const SizedBox(width: AppConstants.paddingS),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTextStyles.bodySmall
                          .copyWith(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text('No products found',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingM),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final p = results[i];
                      final matColor = p.material == 'Gold'
                          ? AppColors.gold
                          : const Color(0xFFC0C0C0);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 4),
                        leading: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: matColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusXS),
                          ),
                          child: Icon(Icons.diamond_outlined,
                              color: matColor, size: 18),
                        ),
                        title: Text(p.name,
                            style: AppTextStyles.titleSmall
                                .copyWith(fontSize: 13)),
                        subtitle: Text(p.material,
                            style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10,
                                color: AppColors.textMuted)),
                        trailing: Text('₹${p.price.toInt()}',
                            style: AppTextStyles.priceTag
                                .copyWith(fontSize: 14)),
                        onTap: () => widget.onProductTap(p.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Sort Sheet ────────────────────────────────────────────────────────────────
class _SortSheet extends StatelessWidget {
  final _SortOrder current;
  final ValueChanged<_SortOrder> onSelect;

  const _SortSheet({required this.current, required this.onSelect});

  static const _options = [
    (_SortOrder.featured, 'Featured', Icons.auto_awesome_outlined),
    (_SortOrder.priceLow, 'Price: Low to High', Icons.arrow_upward_rounded),
    (_SortOrder.priceHigh, 'Price: High to Low', Icons.arrow_downward_rounded),
    (_SortOrder.nameAZ, 'Name: A to Z', Icons.sort_by_alpha_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(AppConstants.paddingM, AppConstants.paddingM,
          AppConstants.paddingM, AppConstants.paddingM + bottomPad),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 3,
            decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Text('SORT BY',
              style: AppTextStyles.categoryChip
                  .copyWith(fontSize: 11, letterSpacing: 3.0)),
          const SizedBox(height: AppConstants.paddingM),
          ..._options.map((opt) {
            final (order, label, icon) = opt;
            final isSelected = current == order;
            return GestureDetector(
              onTap: () => onSelect(order),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.paddingM,
                    horizontal: AppConstants.paddingS),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.forestGreen.withValues(alpha: 0.06)
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusXS),
                ),
                child: Row(
                  children: [
                    Icon(icon,
                        size: 18,
                        color: isSelected
                            ? AppColors.forestGreen
                            : AppColors.textMuted),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: Text(label,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14,
                            color: isSelected
                                ? AppColors.forestGreen
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          )),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_rounded,
                          size: 16, color: AppColors.forestGreen),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
