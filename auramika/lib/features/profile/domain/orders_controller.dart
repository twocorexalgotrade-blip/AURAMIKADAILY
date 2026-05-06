import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';

enum OrderStatus { processing, inTransit, delivered, cancelled }

class OrderModel {
  final String id;
  final String productName;
  final String? imageAsset;
  final double total;
  final String date;
  final OrderStatus status;
  final int itemCount;

  const OrderModel({
    required this.id,
    required this.productName,
    this.imageAsset,
    required this.total,
    required this.date,
    required this.status,
    required this.itemCount,
  });

  OrderModel copyWith({OrderStatus? status}) => OrderModel(
        id: id,
        productName: productName,
        imageAsset: imageAsset,
        total: total,
        date: date,
        status: status ?? this.status,
        itemCount: itemCount,
      );

  static OrderStatus _parseStatus(String s) => switch (s) {
        'shipped'                   => OrderStatus.inTransit,
        'delivered'                 => OrderStatus.delivered,
        'cancelled' || 'refunded'   => OrderStatus.cancelled,
        _                           => OrderStatus.processing,
      };

  static String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  factory OrderModel.fromBackend(Map<String, dynamic> json) {
    final items = (json['items'] as List? ?? []).cast<Map<String, dynamic>>();
    final first = items.isNotEmpty ? items.first : null;
    final name = first == null
        ? 'Order'
        : items.length > 1
            ? '${first['product_name']} & ${items.length - 1} more'
            : (first['product_name'] as String? ?? 'Order');
    final count = items.fold<int>(0, (s, i) => s + ((i['quantity'] as int?) ?? 1));
    return OrderModel(
      id: json['id'] as String,
      productName: name,
      imageAsset: first?['image_url'] as String?,
      total: (json['total'] as num).toDouble(),
      date: _formatDate(json['created_at'] as String? ?? ''),
      status: _parseStatus(json['status'] as String? ?? ''),
      itemCount: count,
    );
  }
}

class OrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  @override
  Future<List<OrderModel>> build() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return _demoOrders;

    try {
      final token = await user.getIdToken();
      final dio = Dio(BaseOptions(baseUrl: '${AppConstants.baseUrl}/api/v1'));
      final res = await dio.get<Map<String, dynamic>>(
        '/orders',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final raw = (res.data!['orders'] as List).cast<Map<String, dynamic>>();
      final orders = raw.map(OrderModel.fromBackend).toList();
      return orders.isEmpty ? _demoOrders : orders;
    } catch (_) {
      return _demoOrders;
    }
  }

  void addOrder(OrderModel order) {
    final current = state.valueOrNull ?? [];
    state = AsyncData([order, ...current]);
  }

  Future<void> cancelOrder(String id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        final dio = Dio(BaseOptions(baseUrl: '${AppConstants.baseUrl}/api/v1'));
        await dio.post(
          '/orders/$id/cancel',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (_) {
      // Demo orders (ORD-*) 404 on the backend — still update local state
    }
    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final o in current)
        if (o.id == id) o.copyWith(status: OrderStatus.cancelled) else o,
    ]);
  }
}

final ordersProvider =
    AsyncNotifierProvider<OrdersNotifier, List<OrderModel>>(OrdersNotifier.new);

// Shown when user is not logged in or has placed no real orders yet
const _demoOrders = [
  OrderModel(
    id: 'ORD-2025-004',
    productName: 'Gold Link Bracelet',
    imageAsset: 'assets/images/products/b2_gold_link.jpg',
    total: 699,
    date: '20 Feb 2025',
    status: OrderStatus.processing,
    itemCount: 1,
  ),
  OrderModel(
    id: 'ORD-2025-003',
    productName: 'Kundan Chandbali',
    imageAsset: 'assets/images/products/e8_kundan_chandbali.jpg',
    total: 1299,
    date: '5 Feb 2025',
    status: OrderStatus.inTransit,
    itemCount: 1,
  ),
  OrderModel(
    id: 'ORD-2025-002',
    productName: 'Heavy Temple Necklace',
    imageAsset: 'assets/images/products/n12_temple_neck.jpg',
    total: 2499,
    date: '28 Dec 2024',
    status: OrderStatus.delivered,
    itemCount: 1,
  ),
  OrderModel(
    id: 'ORD-2025-001',
    productName: 'Pearl Choker',
    imageAsset: 'assets/images/products/n4_pearl_choker.jpg',
    total: 599,
    date: '15 Jan 2025',
    status: OrderStatus.delivered,
    itemCount: 1,
  ),
];
