import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import 'auth_provider.dart';

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<VendorOrder>>(
  () => OrdersNotifier(),
);

class OrdersNotifier extends AsyncNotifier<List<VendorOrder>> {
  @override
  Future<List<VendorOrder>> build() => _fetch();

  Future<List<VendorOrder>> _fetch() async {
    final api = ref.read(apiClientProvider);
    final res = await api.get<Map<String, dynamic>>('/vendor/orders');
    final list = res.data!['orders'] as List;
    return list.map((e) => VendorOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    final previous = state;
    // Optimistic update — UI responds immediately
    state = AsyncData(
      (state.value ?? []).map((o) {
        if (o.id != orderId) return o;
        return VendorOrder.fromJson({
          'id': o.id,
          'status': newStatus,
          'subtotal': o.subtotal,
          'total': o.total,
          'is_express': o.isExpress,
          'cashfree_order_id': o.cashfreeOrderId,
          'items': o.items.map((i) => {
            'id': i.id,
            'product_id': i.productId,
            'product_name': i.productName,
            'brand_name': i.brandName,
            'price': i.price,
            'quantity': i.quantity,
            'image_url': i.imageUrl,
          }).toList(),
          'created_at': o.createdAt.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'address_name': o.addressName,
          'address_phone': o.addressPhone,
          'address_line1': o.addressLine1,
          'address_city': o.addressCity,
          'address_pincode': o.addressPincode,
        });
      }).toList(),
    );
    try {
      final api = ref.read(apiClientProvider);
      await api.put('/vendor/orders/$orderId/status', data: {'status': newStatus});
    } catch (e) {
      // Revert to previous state and rethrow so the UI can show an error
      state = previous;
      rethrow;
    }
  }
}
