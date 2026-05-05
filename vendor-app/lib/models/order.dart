class OrderItem {
  final int id;
  final String productId;
  final String productName;
  final String brandName;
  final double price;
  final int quantity;
  final String? imageUrl;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.brandName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: (json['id'] as num).toInt(),
        productId: json['product_id'] as String,
        productName: json['product_name'] as String,
        brandName: json['brand_name'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
        imageUrl: json['image_url'] as String?,
      );
}

class VendorOrder {
  final String id;
  final String status;
  final double subtotal;
  final double total;
  final bool isExpress;
  final String? cashfreeOrderId;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? addressName;
  final String? addressPhone;
  final String? addressLine1;
  final String? addressCity;
  final String? addressPincode;

  const VendorOrder({
    required this.id,
    required this.status,
    required this.subtotal,
    required this.total,
    required this.isExpress,
    this.cashfreeOrderId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.addressName,
    this.addressPhone,
    this.addressLine1,
    this.addressCity,
    this.addressPincode,
  });

  factory VendorOrder.fromJson(Map<String, dynamic> json) => VendorOrder(
        id: json['id'] as String,
        status: json['status'] as String,
        subtotal: (json['subtotal'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        isExpress: json['is_express'] as bool? ?? false,
        cashfreeOrderId: json['cashfree_order_id'] as String?,
        items: (json['items'] as List? ?? [])
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
        addressName: json['address_name'] as String?,
        addressPhone: json['address_phone'] as String?,
        addressLine1: json['address_line1'] as String?,
        addressCity: json['address_city'] as String?,
        addressPincode: json['address_pincode'] as String?,
      );

  // Allowed transitions a vendor can make
  static const allowedStatuses = [
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];
}
