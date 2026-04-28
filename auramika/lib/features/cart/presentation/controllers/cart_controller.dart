import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/cart_model.dart';

/// CartController - StateNotifier for managing cart state globally
class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState());

  /// Add item to cart - increments quantity if already exists
  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere((i) => i.productId == item.productId);
    
    if (existingIndex != -1) {
      // Item exists - increment quantity
      final updatedItems = [...state.items];
      updatedItems[existingIndex] = CartItem(
        id: updatedItems[existingIndex].id,
        productId: updatedItems[existingIndex].productId,
        brandName: updatedItems[existingIndex].brandName,
        productName: updatedItems[existingIndex].productName,
        price: updatedItems[existingIndex].price,
        material: updatedItems[existingIndex].material,
        size: updatedItems[existingIndex].size,
        imageUrl: updatedItems[existingIndex].imageUrl,
        isExpressAvailable: updatedItems[existingIndex].isExpressAvailable,
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // New item - add to cart
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  /// Remove item from cart by ID
  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
  }

  /// Update quantity - increment or decrement
  void updateQty(String id, int delta) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        final newQty = (item.quantity + delta).clamp(1, 10);
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
    state = const CartState();
  }
}

/// Global cart provider using StateNotifierProvider
final cartProvider = StateNotifierProvider<CartController, CartState>((ref) {
  return CartController();
});
