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
import '../../../cart/domain/cart_model.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../profile/domain/wishlist_controller.dart';
import '../../domain/product_model.dart';
import '../widgets/pdp_image_gallery.dart';

/// AURAMIKA Product Detail Page — Phase 5
///
/// Layout (single CustomScrollView):
///   1. Full-screen image gallery (65% viewport) with AR button
///   2. Product info panel (brand, name, price, badges)
///   3. Size selector
///   4. Description
///   5. "Wear It With" horizontal cross-sell
///   6. Sticky "Add to Cart" bottom bar
class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductDetail? product; // null = use mock
  final String? productId;      // from router path param (ignored if product provided)

  const ProductDetailScreen({super.key, this.product, this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late ProductDetail _product;
  String? _selectedSize;

  @override
  void initState() {
    super.initState();
    _product = widget.product ?? ProductCatalogue.getProductById(widget.productId ?? 'e1');
    if (_product.sizes.isNotEmpty) _selectedSize = _product.sizes[0];
    if (widget.product == null && widget.productId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromApi(widget.productId!));
    }
  }

  Future<void> _loadFromApi(String productId) async {
    try {
      final dio = ref.read(apiServiceProvider);
      final res = await dio.get<Map<String, dynamic>>('/products/$productId');
      if (!mounted) return;
      final p = res.data!;
      final rawImages = p['image_urls'];
      final imageUrls = rawImages is List ? rawImages.cast<String>().toList() : <String>[];
      setState(() {
        _product = ProductDetail(
          id: p['id'] as String,
          brandName: (p['brand_name'] as String?)?.isNotEmpty == true
              ? p['brand_name'] as String
              : 'AURAMIKA',
          productName: (p['product_name'] as String?) ?? '',
          description: (p['description'] as String?)?.isNotEmpty == true
              ? p['description'] as String
              : 'Hand-crafted with precision, this piece embodies the AURAMIKA philosophy of '
                  'timeless elegance meeting modern design.',
          price: (p['price'] as num).toDouble(),
          originalPrice: p['original_price'] != null
              ? (p['original_price'] as num).toDouble()
              : null,
          material: (p['material'] as String?) ?? 'Gold',
          category: (p['category'] as String?) ?? 'Jewelry',
          vibe: (p['vibe'] as String?) ?? 'All',
          isExpressAvailable: (p['is_express'] as bool?) ?? false,
          isInStock: (p['in_stock'] as bool?) ?? true,
          imageUrls: imageUrls,
          sizes: [],
          wearItWith: [],
        );
      });
    } catch (_) {
      // keep mock fallback already set in initState
    }
  }

  void _onAddToCart() {
    final cartItem = CartItem(
      id: 'ci_${_product.id}_${DateTime.now().millisecondsSinceEpoch}',
      productId: _product.id,
      brandName: _product.brandName,
      productName: _product.productName,
      price: _product.price,
      material: _product.material,
      size: _selectedSize,
      imageUrl: _product.imageUrls.isNotEmpty ? _product.imageUrls.first : null,
      isExpressAvailable: _product.isExpressAvailable,
    );
    
    ref.read(cartProvider.notifier).addItem(cartItem);
    
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${_product.productName} added to bag',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: AppColors.forestGreen,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          action: SnackBarAction(
            label: 'GO TO BAG',
            textColor: AppColors.gold,
            onPressed: () => context.go(AppRoutes.cart),
          ),
        ),
      );
  }

  void _onMirrorTap() {
    context.push(AppRoutes.stylist);
  }

  void _onShare() {
    final product = _product;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareBottomSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Image gallery
              SliverToBoxAdapter(
                child: PdpImageGallery(
                  product: _product,
                  isWishlisted: ref.watch(wishlistProvider).contains(_product.id),
                  onWishlistTap: () {
                    ref.read(wishlistProvider.notifier).toggle(WishlistItem(
                          id: _product.id,
                          brandName: _product.brandName,
                          productName: _product.productName,
                          price: _product.price,
                          material: _product.material,
                          imageUrl: _product.imageUrls.isNotEmpty
                              ? _product.imageUrls.first
                              : null,
                          isExpressAvailable: _product.isExpressAvailable,
                        ));
                  },
                  onMirrorTap: _onMirrorTap,
                  onShareTap: _onShare,
                  onBack: () => Navigator.of(context).maybePop(),
                ),
              ),

              // 2. Product info
              SliverToBoxAdapter(
                child: _ProductInfoPanel(product: _product),
              ),

              // 3. Size selector
              if (_product.sizes.isNotEmpty)
                SliverToBoxAdapter(
                  child: _SizeSelector(
                    sizes: _product.sizes,
                    selected: _selectedSize,
                    onSelect: (s) => setState(() => _selectedSize = s),
                  ),
                ),

              // 4. Description
              SliverToBoxAdapter(
                child: _DescriptionPanel(product: _product),
              ),

              // 5. "Wear It With"
              if (_product.wearItWith.isNotEmpty)
                SliverToBoxAdapter(
                  child: _WearItWithSection(items: _product.wearItWith),
                ),

              // Bottom padding for sticky bar + safe area
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) => SizedBox(
                    height: 140 + MediaQuery.of(context).padding.bottom,
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky Add to Cart bar ──────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _StickyCartBar(
              product: _product,
              onAddToCart: _onAddToCart,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product Info Panel ────────────────────────────────────────────────────────
class _ProductInfoPanel extends StatelessWidget {
  final ProductDetail product;
  const _ProductInfoPanel({required this.product});

  @override
  Widget build(BuildContext context) {
    final matColor = product.materialColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingM,
        AppConstants.paddingM,
        AppConstants.paddingM,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand + vibe row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.brandName.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  letterSpacing: 2.5,
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
              // Vibe tag
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.forestGreen.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                ),
                child: Text(
                  product.vibe.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 8,
                    color: AppColors.forestGreen,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingS),

          // Product name
          Text(
            product.productName,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 22,
              height: 1.2,
            ),
          )
              .animate()
              .fadeIn(duration: AppConstants.animNormal)
              .slideY(begin: 0.05, end: 0),

          const SizedBox(height: AppConstants.paddingM),

          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${product.price.toInt()}',
                style: AppTextStyles.priceTag.copyWith(fontSize: 30),
              ),
              if (product.hasDiscount) ...[
                const SizedBox(width: AppConstants.paddingS),
                Text(
                  '₹${product.originalPrice!.toInt()}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingS),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.terraCotta.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusXS),
                  ),
                  child: Text(
                    '${product.discountPercent}% OFF',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.terraCotta,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: AppConstants.paddingM),

          // Badges row
          Wrap(
            spacing: AppConstants.paddingS,
            runSpacing: AppConstants.paddingS,
            children: [
              if (product.isExpressAvailable)
                _InfoBadge(
                  icon: Icons.bolt,
                  label: AppConstants.expressDeliveryBadge,
                  bgColor: AppColors.forestGreen,
                  textColor: AppColors.white,
                  iconColor: AppColors.gold,
                ),
              _InfoBadge(
                icon: Icons.verified_outlined,
                label: 'Handcrafted',
                bgColor: matColor.withValues(alpha: 0.1),
                textColor: matColor,
                iconColor: matColor,
                bordered: true,
                borderColor: matColor,
              ),
              _InfoBadge(
                icon: Icons.recycling_outlined,
                label: 'Sustainable',
                bgColor: AppColors.forestGreen.withValues(alpha: 0.08),
                textColor: AppColors.forestGreen,
                iconColor: AppColors.forestGreen,
                bordered: true,
                borderColor: AppColors.forestGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Info Badge ────────────────────────────────────────────────────────────────
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color iconColor;
  final bool bordered;
  final Color? borderColor;

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.iconColor,
    this.bordered = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
        border: bordered
            ? Border.all(
                color: borderColor!.withValues(alpha: 0.3), width: 0.8)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Size Selector ─────────────────────────────────────────────────────────────
class _SizeSelector extends StatelessWidget {
  final List<String> sizes;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _SizeSelector({
    required this.sizes,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingM,
        AppConstants.paddingL,
        AppConstants.paddingM,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'SIZE',
                style: AppTextStyles.categoryChip.copyWith(
                  fontSize: 10,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(width: AppConstants.paddingS),
              if (selected != null)
                Text(
                  selected!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingS),
          Row(
            children: sizes.map((s) {
              final isSelected = s == selected;
              return GestureDetector(
                onTap: () => onSelect(s),
                child: AnimatedContainer(
                  duration: AppConstants.animFast,
                  margin: const EdgeInsets.only(right: AppConstants.paddingS),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.forestGreen
                        : AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusS),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.forestGreen
                          : AppColors.divider,
                      width: isSelected ? 1.5 : 0.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      s,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 11,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Description Panel ─────────────────────────────────────────────────────────
class _DescriptionPanel extends StatefulWidget {
  final ProductDetail product;
  const _DescriptionPanel({required this.product});

  @override
  State<_DescriptionPanel> createState() => _DescriptionPanelState();
}

class _DescriptionPanelState extends State<_DescriptionPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingM,
        AppConstants.paddingL,
        AppConstants.paddingM,
        AppConstants.paddingL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 0.5,
            color: AppColors.divider,
          ),
          const SizedBox(height: AppConstants.paddingM),
          Text(
            'ABOUT THIS PIECE',
            style: AppTextStyles.categoryChip.copyWith(
              fontSize: 10,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: AppConstants.paddingS),
          AnimatedCrossFade(
            firstChild: Text(
              widget.product.description,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.7,
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              widget.product.description,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.7,
                color: AppColors.textSecondary,
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: AppConstants.animNormal,
          ),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _expanded ? 'Show less' : 'Read more',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.gold,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── "Wear It With" Section ────────────────────────────────────────────────────
class _WearItWithSection extends StatelessWidget {
  final List<ProductDetail> items;
  const _WearItWithSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.paddingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEAR IT WITH',
                  style: AppTextStyles.categoryChip.copyWith(
                    fontSize: 11,
                    letterSpacing: 3.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Complete the look',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingM),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppConstants.paddingS + 4),
              itemBuilder: (context, i) {
                final item = items[i];
                final matColor = item.materialColor;
                return GestureDetector(
                  onTap: () => context.push(AppRoutes.product(item.id)),
                  child: SizedBox(
                    width: 140,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusS),
                        border: Border.all(
                            color: AppColors.divider, width: 0.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          Expanded(
                            child: Container(
                              color: matColor.withValues(alpha: 0.1),
                              child: Center(
                                child: Icon(
                                  Icons.diamond_outlined,
                                  color: matColor,
                                  size: 36,
                                ),
                              ),
                            ),
                          ),
                          // Info
                          Padding(
                            padding: const EdgeInsets.all(
                                AppConstants.paddingS),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.category.toUpperCase(),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontSize: 8,
                                    color: AppColors.textMuted,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.productName,
                                  style: AppTextStyles.titleSmall
                                      .copyWith(fontSize: 11),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₹${item.price.toInt()}',
                                      style: AppTextStyles.priceTag.copyWith(
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (item.isExpressAvailable)
                                      const Icon(
                                        Icons.bolt,
                                        size: 12,
                                        color: AppColors.gold,
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
                )
                    .animate(
                        delay: Duration(milliseconds: i * 60))
                    .fadeIn(duration: AppConstants.animNormal)
                    .slideX(begin: 0.08, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sticky Add to Cart Bar ────────────────────────────────────────────────────
class _StickyCartBar extends StatelessWidget {
  final ProductDetail product;
  final VoidCallback onAddToCart;

  const _StickyCartBar({
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingM,
        AppConstants.paddingM,
        AppConstants.paddingM,
        AppConstants.paddingM + bottomPad,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: const Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Express delivery info
          if (product.isExpressAvailable)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt, size: 13, color: AppColors.gold),
                      const SizedBox(width: 3),
                      Text(
                        'Get it in 2 Hours',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.forestGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Express delivery available',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            )
          else
            const Expanded(child: SizedBox()),

          const SizedBox(width: AppConstants.paddingM),

          // Add to Cart button
          GestureDetector(
            onTap: product.isInStock ? onAddToCart : null,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL,
                vertical: AppConstants.paddingM,
              ),
              decoration: BoxDecoration(
                color: product.isInStock
                    ? AppColors.forestGreen
                    : AppColors.textMuted,
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: AppColors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    product.isInStock ? 'ADD TO CART' : 'OUT OF STOCK',
                    style: AppTextStyles.categoryChip.copyWith(
                      color: AppColors.white,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Share Bottom Sheet ────────────────────────────────────────────────────────
class _ShareBottomSheet extends StatelessWidget {
  final ProductDetail product;
  const _ShareBottomSheet({required this.product});

  String get _shareText =>
      '${product.productName} by ${product.brandName} — ₹${product.price.toInt()}\n'
      'Material: ${product.material}\n'
      'Shop on AURAMIKA';

  void _copyAndClose(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _shareText));
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Copied to clipboard',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.forestGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingM,
        AppConstants.paddingM,
        AppConstants.paddingM,
        AppConstants.paddingM + bottomPad,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),

          // Product info row
          Row(
            children: [
              Container(
                width: 52,
                height: 62,
                decoration: BoxDecoration(
                  color: product.materialColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                clipBehavior: Clip.antiAlias,
                child: product.imageUrls.isNotEmpty
                    ? (product.imageUrls.first.startsWith('http')
                        ? Image.network(
                            product.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.diamond_outlined,
                              color: product.materialColor,
                              size: 24,
                            ),
                          )
                        : Image.asset(
                            product.imageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.diamond_outlined,
                              color: product.materialColor,
                              size: 24,
                            ),
                          ))
                    : Icon(
                        Icons.diamond_outlined,
                        color: product.materialColor,
                        size: 24,
                      ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brandName.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 9,
                        letterSpacing: 2.0,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.productName,
                      style: AppTextStyles.titleSmall.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${product.price.toInt()}',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontSize: 14,
                        letterSpacing: 0,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingL),

          // Share options row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareOption(
                icon: Icons.message_rounded,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () => _copyAndClose(context),
              ),
              _ShareOption(
                icon: Icons.camera_alt_outlined,
                label: 'Instagram',
                color: const Color(0xFFE1306C),
                onTap: () => _copyAndClose(context),
              ),
              _ShareOption(
                icon: Icons.copy_rounded,
                label: 'Copy Link',
                color: AppColors.gold,
                onTap: () => _copyAndClose(context),
              ),
              _ShareOption(
                icon: Icons.more_horiz_rounded,
                label: 'More',
                color: AppColors.textMuted,
                onTap: () => _copyAndClose(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
