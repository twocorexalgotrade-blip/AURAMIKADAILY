import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishlistItem {
  final String id;
  final String brandName;
  final String productName;
  final double price;
  final String material;
  final String? imageUrl;
  final bool isExpressAvailable;

  const WishlistItem({
    required this.id,
    required this.brandName,
    required this.productName,
    required this.price,
    required this.material,
    this.imageUrl,
    this.isExpressAvailable = true,
  });
}

class WishlistState {
  final List<WishlistItem> items;

  const WishlistState({this.items = const []});

  bool contains(String id) => items.any((i) => i.id == id);

  WishlistState copyWith({List<WishlistItem>? items}) =>
      WishlistState(items: items ?? this.items);
}

class WishlistController extends StateNotifier<WishlistState> {
  WishlistController() : super(const WishlistState());

  void toggle(WishlistItem item) {
    if (state.contains(item.id)) {
      state = state.copyWith(
        items: state.items.where((i) => i.id != item.id).toList(),
      );
    } else {
      state = state.copyWith(items: [...state.items, item]);
    }
  }

  void clear() {
    state = const WishlistState();
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistController, WishlistState>((ref) {
  return WishlistController();
});
