import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/cart_model.dart';

class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState());

  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere((i) => i.productId == item.productId);

    if (existingIndex != -1) {
      final updatedItems = [...state.items];
      final prev = updatedItems[existingIndex];
      if (kDebugMode) debugPrint('[Cart] addItem → qty++ for productId=${item.productId} name="${item.productName}" qty=${prev.quantity}→${prev.quantity + 1}');
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
      if (kDebugMode) debugPrint('[Cart] addItem → new item productId=${item.productId} name="${item.productName}" price=${item.price}');
      state = state.copyWith(items: [...state.items, item]);
    }
    if (kDebugMode) debugPrint('[Cart] totalItems=${state.totalItems} subtotal=${state.subtotal}');
  }

  void removeItem(String id) {
    final item = state.items.firstWhere((i) => i.id == id, orElse: () => state.items.first);
    if (kDebugMode) debugPrint('[Cart] removeItem → id=$id name="${item.productName}"');
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
    if (kDebugMode) debugPrint('[Cart] totalItems=${state.totalItems} subtotal=${state.subtotal}');
  }

  void updateQty(String id, int delta) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        final newQty = (item.quantity + delta).clamp(1, 10);
        if (kDebugMode) debugPrint('[Cart] updateQty → id=$id name="${item.productName}" qty=${item.quantity}→$newQty');
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

  void clear() {
    if (kDebugMode) debugPrint('[Cart] clear → removing ${state.totalItems} items');
    state = const CartState();
  }
}

final cartProvider = StateNotifierProvider<CartController, CartState>((ref) {
  return CartController();
});
