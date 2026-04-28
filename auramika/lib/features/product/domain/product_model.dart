import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/domain/home_models.dart';

/// Full product detail model
class ProductDetail {
  final String id;
  final String brandName;
  final String productName;
  final String description;
  final double price;
  final double? originalPrice;
  final String material; // 'Brass' | 'Copper'
  final String category; // 'Earrings' | 'Necklace' | 'Cuff' | 'Ring' | 'Anklet'
  final String vibe;
  final bool isExpressAvailable;
  final bool isInStock;
  final List<String> imageUrls; // empty = use placeholder
  final List<String> sizes;
  final List<ProductDetail> wearItWith;

  const ProductDetail({
    required this.id,
    required this.brandName,
    required this.productName,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.material,
    required this.category,
    required this.vibe,
    this.isExpressAvailable = true,
    this.isInStock = true,
    this.imageUrls = const [],
    this.sizes = const [],
    this.wearItWith = const [],
  });

  Color get materialColor {
    final mat = material.toLowerCase();
    if (mat.contains('gold')) return AppColors.gold;
    if (mat.contains('silver')) return const Color(0xFFC0C0C0);
    if (mat.contains('rose')) return const Color(0xFFB76E79);
    if (mat.contains('copper')) return AppColors.copper;
    if (mat.contains('brass')) return AppColors.brass;
    return AppColors.gold; // Default fallback
  }

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price;

  int get discountPercent => hasDiscount
      ? (((originalPrice! - price) / originalPrice!) * 100).round()
      : 0;
}

/// Mock product catalogue
abstract class ProductCatalogue {
  /// Fetch product detail by ID — reads name, price, material, and imageUrl from
  /// HomeData so the detail page always matches the home/shop listings.
  static ProductDetail getProductById(String id) {
    final src = HomeData.allProducts.firstWhere(
      (p) => p.id == id,
      orElse: () => const HomeProduct(
        id: 'unknown',
        brandName: 'AURAMIKA',
        productName: 'Luxury Piece',
        price: 999,
        material: 'Gold Plated',
      ),
    );

    // Use weekendEdit URL if available, otherwise fall back to allProducts URL
    HomeProduct? weekendSrc;
    try {
      weekendSrc = HomeData.weekendEdit.firstWhere((p) => p.id == id);
    } catch (_) {
      weekendSrc = null;
    }

    final imageUrl = weekendSrc?.imageUrl ?? src.imageUrl;

    String category = 'Jewelry';
    if (id.startsWith('e')) {
      category = 'Earrings';
    } else if (id.startsWith('n')) {
      category = 'Necklace';
    } else if (id.startsWith('r')) {
      category = 'Ring';
    } else if (id.startsWith('b')) {
      category = 'Bracelet';
    } else if (id.startsWith('sw')) {
      category = 'Jewelry';
    }

    return ProductDetail(
      id: src.id,
      brandName: src.brandName,
      productName: src.productName,
      description:
          'Hand-crafted with precision, this piece embodies the AURAMIKA philosophy of '
          'timeless elegance meeting modern design. Featuring high-quality '
          '${src.material.toLowerCase()} finish and premium stones, designed to be '
          'a staple in your collection.',
      price: src.price,
      originalPrice: src.price * 1.4,
      material: src.material,
      category: category,
      vibe: src.vibe,
      isExpressAvailable: src.isExpressAvailable,
      sizes: category == 'Ring' ? ['6', '7', '8', '9'] : [],
      imageUrls: imageUrl != null ? [imageUrl] : [],
      wearItWith: [],
    );
  }
}
