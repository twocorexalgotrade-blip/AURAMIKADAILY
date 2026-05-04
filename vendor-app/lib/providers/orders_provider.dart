import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/api_client.dart';

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
    final api = ref.read(apiClientProvider);
    await api.put('/vendor/orders/$orderId/status', data: {'status': newStatus});
    state = AsyncData(
      (state.value ?? []).map((o) {
        return o.id == orderId ? VendorOrder.fromJson({
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
        }) : o;
      }).toList(),
    );
  }
}
