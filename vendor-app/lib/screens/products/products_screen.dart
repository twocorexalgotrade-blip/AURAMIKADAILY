import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme.dart';
import '../../models/product.dart';
import '../../providers/products_provider.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => ref.read(productsProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/products/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.error))),
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inventory_2_outlined, size: 44, color: AppTheme.primary),
                ),
                const SizedBox(height: 20),
                const Text('No products yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                const Text('Tap + Add Product to get started', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              ]),
            );
          }
          return RefreshIndicator(
            color: AppTheme.primary,
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(children: [
        // Coloured left accent strip
        Container(
          width: 4,
          height: 84,
          decoration: BoxDecoration(
            color: product.inStock ? AppTheme.primary : AppTheme.border,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
          ),
        ),
        // Image
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: SizedBox(
            width: 76, height: 84,
            child: product.imageUrls.isNotEmpty
                ? CachedNetworkImage(imageUrl: product.imageUrls.first, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const _ImagePlaceholder())
                : const _ImagePlaceholder(),
          ),
        ),
        const SizedBox(width: 12),
        // Details
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.productName,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(product.brandName,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Row(children: [
              Text('₹${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary, fontSize: 15)),
              const SizedBox(width: 8),
              _StockBadge(inStock: product.inStock),
              if (product.isExpress) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withAlpha(18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('⚡ Express',
                      style: TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
          ]),
        )),
        // Menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary, size: 20),
          onSelected: (action) async {
            if (action == 'edit') {
              context.go('/products/${product.id}/edit');
            } else if (action == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  backgroundColor: AppTheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Delete Product', style: TextStyle(fontWeight: FontWeight.w700)),
                  content: Text('Delete "${product.productName}"? This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Delete', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w700)),
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
            const PopupMenuItem(value: 'edit', child: Row(children: [
              Icon(Icons.edit_outlined, size: 16, color: AppTheme.secondary),
              SizedBox(width: 10), Text('Edit'),
            ])),
            const PopupMenuItem(value: 'delete', child: Row(children: [
              Icon(Icons.delete_outline, size: 16, color: AppTheme.error),
              SizedBox(width: 10), Text('Delete', style: TextStyle(color: AppTheme.error)),
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
      color: inStock ? AppTheme.success.withAlpha(22) : AppTheme.error.withAlpha(18),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      inStock ? 'In Stock' : 'Out',
      style: TextStyle(
          color: inStock ? AppTheme.success : AppTheme.error,
          fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) => Container(
    color: AppTheme.surfaceVariant,
    child: const Icon(Icons.image_outlined, color: AppTheme.primary, size: 24),
  );
}
