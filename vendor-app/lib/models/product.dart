class Product {
  final String id;
  final String productName;
  final String brandName;
  final String? description;
  final double price;
  final double? originalPrice;
  final String? category;
  final String? vibe;
  final String? material;
  final List<String> imageUrls;
  final bool isExpress;
  final bool inStock;
  final List<String> tags;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.productName,
    required this.brandName,
    this.description,
    required this.price,
    this.originalPrice,
    this.category,
    this.vibe,
    this.material,
    required this.imageUrls,
    required this.isExpress,
    required this.inStock,
    required this.tags,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        productName: json['product_name'] as String,
        brandName: json['brand_name'] as String? ?? '',
        description: json['description'] as String?,
        price: (json['price'] as num).toDouble(),
        originalPrice: (json['original_price'] as num?)?.toDouble(),
        category: json['category'] as String?,
        vibe: json['vibe'] as String?,
        material: json['material'] as String?,
        imageUrls: List<String>.from(json['image_urls'] as List? ?? []),
        isExpress: json['is_express'] as bool? ?? false,
        inStock: json['in_stock'] as bool? ?? true,
        tags: List<String>.from(json['tags'] as List? ?? []),
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'product_name': productName,
        'brand_name': brandName,
        if (description != null) 'description': description,
        'price': price,
        if (originalPrice != null) 'original_price': originalPrice,
        if (category != null) 'category': category,
        if (vibe != null) 'vibe': vibe,
        if (material != null) 'material': material,
        'image_urls': imageUrls,
        'is_express': isExpress,
        'in_stock': inStock,
        'tags': tags,
      };
}
