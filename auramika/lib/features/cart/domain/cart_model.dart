import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// A single item in the cart
class CartItem {
  final String id;
  final String productId;
  final String brandName;
  final String productName;
  final double price;
  final String material;
  final String? size;
  final String? imageUrl;
  final bool isExpressAvailable;
  int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.brandName,
    required this.productName,
    required this.price,
    required this.material,
    this.size,
    this.imageUrl,
    this.isExpressAvailable = true,
    this.quantity = 1,
  });

  double get subtotal => price * quantity;

  Color get materialColor =>
      material == 'Brass' ? AppColors.brass : AppColors.copper;
}

/// Cart state — holds items and computes delivery logic
class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  bool get isEmpty => items.isEmpty;
  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => items.fold(0, (sum, i) => sum + i.subtotal);
  double get deliveryFee => isAllExpress ? 0 : 49;
  double get total => subtotal + deliveryFee;

  /// CORE RULE: ALL items must be express for 2-hour delivery
  bool get isAllExpress =>
      items.isNotEmpty && items.every((i) => i.isExpressAvailable);

  CartState copyWith({List<CartItem>? items}) =>
      CartState(items: items ?? this.items);
}

/// Mock initial cart data
final mockCartState = CartState(
  items: [
    CartItem(
      id: 'ci1',
      productId: 'p1',
      brandName: 'AURAMIKA',
      productName: 'Twisted Brass Cuff',
      price: 1299,
      material: 'Brass',
      size: 'M',
      imageUrl: 'assets/images/products/p1_brass_cuff.jpg',
      isExpressAvailable: true,
    ),
    CartItem(
      id: 'ci2',
      productId: 'p2',
      brandName: 'AURAMIKA',
      productName: 'Copper Pearl Drop',
      price: 949,
      material: 'Copper',
      imageUrl: 'assets/images/products/p2_copper_pearl.jpg',
      isExpressAvailable: true,
    ),
    CartItem(
      id: 'ci3',
      productId: 'p5',
      brandName: 'AURAMIKA',
      productName: 'Minimalist Brass Bar',
      price: 699,
      material: 'Brass',
      imageUrl: 'assets/images/products/p3_brass_chain.jpg',
      isExpressAvailable: true,
    ),
  ],
);
