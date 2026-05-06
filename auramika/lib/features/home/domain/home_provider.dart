import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import 'home_models.dart';

// Real products from the backend — falls back to static mock on any error.
final homeProductsProvider = FutureProvider<List<HomeProduct>>((ref) async {
  final dio = ref.watch(apiServiceProvider);
  try {
    final res = await dio.get<Map<String, dynamic>>(
      '/products',
      queryParameters: {'limit': '50'},
    );
    final rows = (res.data!['products'] as List).cast<Map<String, dynamic>>();
    return rows.map(_toHomeProduct).toList();
  } catch (_) {
    return HomeData.allProducts;
  }
});

// Per-query search — falls back to local filter on error.
final searchProductsProvider =
    FutureProvider.family<List<HomeProduct>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    final all = await ref.watch(homeProductsProvider.future);
    return all.take(12).toList();
  }
  final dio = ref.watch(apiServiceProvider);
  try {
    final res = await dio.get<Map<String, dynamic>>(
      '/products/search',
      queryParameters: {'q': query.trim()},
    );
    final rows = (res.data!['products'] as List).cast<Map<String, dynamic>>();
    return rows.map(_toHomeProduct).toList();
  } catch (_) {
    final q = query.toLowerCase();
    return HomeData.allProducts.where((p) {
      return p.productName.toLowerCase().contains(q) ||
          p.brandName.toLowerCase().contains(q) ||
          p.material.toLowerCase().contains(q) ||
          p.vibe.toLowerCase().contains(q);
    }).toList();
  }
});

HomeProduct _toHomeProduct(Map<String, dynamic> p) {
  final images = p['image_urls'];
  String? imageUrl;
  if (images is List && images.isNotEmpty) {
    imageUrl = images.first as String?;
  }
  return HomeProduct(
    id: p['id'] as String,
    brandName: (p['brand_name'] as String?) ?? 'AURAMIKA',
    productName: (p['product_name'] as String?) ?? '',
    price: (p['price'] as num).toDouble(),
    material: (p['material'] as String?) ?? 'Gold',
    imageUrl: imageUrl,
    isExpressAvailable: (p['is_express'] as bool?) ?? false,
    inStock: (p['in_stock'] as bool?) ?? true,
    vibe: (p['vibe'] as String?) ?? 'All',
  );
}
