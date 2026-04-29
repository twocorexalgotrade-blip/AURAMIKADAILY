import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/cart_model.dart';

/// CartController - StateNotifier for managing cart state globally
class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState());

  /// Add item to cart - increments quantity if already exists
  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere((i) => i.productId == item.productId);

    if (existingIndex != -1) {
      final updatedItems = [...state.items];
      final prev = updatedItems[existingIndex];
      debugPrint('[Cart] addItem → qty++ for productId=${item.productId} name="${item.productName}" qty=${prev.quantity}→${prev.quantity + 1}');
      updatedItems[existingIndex] = CartItem(
        id: prev.id,
        productId: prev.productId,
        brandName: prev.brandName,
        productName: prev.productName,
        price: prev.price,
        material: prev.material,
        size: prev.size,
        imageUrl: prev.imageUrl,
        isExpressAvailable: prev.isExpressAvailable,
        quantity: prev.quantity + 1,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      debugPrint('[Cart] addItem → new item productId=${item.productId} name="${item.productName}" price=${item.price}');
      state = state.copyWith(items: [...state.items, item]);
    }
    debugPrint('[Cart] totalItems=${state.totalItems} subtotal=${state.subtotal}');
  }

  /// Remove item from cart by ID
  void removeItem(String id) {
    final item = state.items.firstWhere((i) => i.id == id, orElse: () => state.items.first);
    debugPrint('[Cart] removeItem → id=$id name="${item.productName}"');
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
    debugPrint('[Cart] totalItems=${state.totalItems} subtotal=${state.subtotal}');
  }

  /// Update quantity - increment or decrement
  void updateQty(String id, int delta) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        final newQty = (item.quantity + delta).clamp(1, 10);
        debugPrint('[Cart] updateQty → id=$id name="${item.productName}" qty=${item.quantity}→$newQty');
        return CartItem(
          id: item.id,
          productId: item.productId,
          brandName: item.brandName,
          productName: item.productName,
          price: item.price,
          material: item.material,
          size: item.size,
          imageUrl: item.imageUrl,
          isExpressAvailable: item.isExpressAvailable,
          quantity: newQty,
        );
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);
  }

  /// Clear all items from cart (after successful checkout)
  void clear() {
    debugPrint('[Cart] clear → removing ${state.totalItems} items');
    state = const CartState();
  }
}

/// Global cart provider using StateNotifierProvider
final cartProvider = StateNotifierProvider<CartController, CartState>((ref) {
  return CartController();
});
