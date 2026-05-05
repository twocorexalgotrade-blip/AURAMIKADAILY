import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../models/product.dart';
import '../../providers/products_provider.dart';

// Luxury palette — matches dashboard
const _black     = Color(0xFF0A0A0A);
const _gold      = Color(0xFFC9A84C);
const _goldLight = Color(0xFFE8C97A);
const _olive     = Color(0xFF6B7C3F);
const _oliveDeep = Color(0xFF4A5E20);

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: _black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.2,
          ),
        ),
        iconTheme: const IconThemeData(color: _goldLight),
        actionsIconTheme: const IconThemeData(color: _goldLight),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, _gold, Colors.transparent],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.read(productsProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/products/new'),
        backgroundColor: _black,
        foregroundColor: _gold,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: _gold.withAlpha(110), width: 1),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.4)),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _gold, strokeWidth: 2)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.error))),
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: _gold.withAlpha(18),
                    shape: BoxShape.circle,
                    border: Border.all(color: _gold.withAlpha(60), width: 1.5),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, size: 44, color: _gold),
                ),
                const SizedBox(height: 20),
                const Text('No products yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _black)),
                const SizedBox(height: 6),
                const Text('Tap + Add Product to get started',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ]),
            );
          }
          return RefreshIndicator(
            color: _gold,
            backgroundColor: Colors.white,
            onRefresh: () => ref.read(productsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ProductTile(product: products[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ProductTile extends ConsumerWidget {
  final Product product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentColor = product.inStock ? _gold : AppTheme.error.withAlpha(140);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withAlpha(65)),
        boxShadow: [
          BoxShadow(color: _gold.withAlpha(16), blurRadius: 12, offset: const Offset(0, 3)),
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(children: [
        // Left accent strip
        Container(
          width: 4,
          height: 84,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
          ),
        ),
        // Product image
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: SizedBox(
            width: 76,
            height: 84,
            child: product.imageUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.imageUrls.first,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const _ImagePlaceholder())
                : const _ImagePlaceholder(),
          ),
        ),
        const SizedBox(width: 12),
        // Details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                product.productName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                product.brandName,
                style: const TextStyle(fontSize: 12, color: _olive, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Row(children: [
                Text(
                  '₹${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: _gold, fontSize: 15),
                ),
                const SizedBox(width: 8),
                _StockBadge(inStock: product.inStock),
                if (product.isExpress) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _oliveDeep.withAlpha(18),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _oliveDeep.withAlpha(50), width: 0.8),
                    ),
                    child: const Text('⚡ Express',
                        style: TextStyle(
                            fontSize: 10, color: _oliveDeep, fontWeight: FontWeight.w700)),
                  ),
                ],
              ]),
            ]),
          ),
        ),
        // Context menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: _gold, size: 20),
          onSelected: (action) async {
            if (action == 'edit') {
              context.go('/products/${product.id}/edit');
            } else if (action == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Delete Product',
                          style: TextStyle(fontWeight: FontWeight.w800, color: _black)),
                      const SizedBox(height: 8),
                      Container(
                        height: 1.5,
                        width: 60,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [_gold, Colors.transparent]),
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    'Delete "${product.productName}"? This cannot be undone.',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Delete',
                          style: TextStyle(
                              color: AppTheme.error, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                try {
                  await ref.read(productsProvider.notifier).deleteProduct(product.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Product deleted')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete: $e')),
                    );
                  }
                }
              }
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 16, color: _olive),
                  SizedBox(width: 10),
                  Text('Edit'),
                ])),
            const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline, size: 16, color: AppTheme.error),
                  SizedBox(width: 10),
                  Text('Delete', style: TextStyle(color: AppTheme.error)),
                ])),
          ],
        ),
        const SizedBox(width: 4),
      ]),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final bool inStock;
  const _StockBadge({required this.inStock});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: inStock ? _olive.withAlpha(22) : AppTheme.error.withAlpha(18),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: inStock ? _olive.withAlpha(70) : AppTheme.error.withAlpha(60),
            width: 0.8,
          ),
        ),
        child: Text(
          inStock ? 'In Stock' : 'Out',
          style: TextStyle(
              color: inStock ? _olive : AppTheme.error,
              fontSize: 10,
              fontWeight: FontWeight.w700),
        ),
      );
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        color: _oliveDeep.withAlpha(15),
        child: const Icon(Icons.image_outlined, color: _oliveDeep, size: 24),
      );
}
