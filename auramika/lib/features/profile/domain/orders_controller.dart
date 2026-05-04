import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

class OrdersNotifier extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() => _initialOrders;

  void addOrder(OrderModel order) {
    state = [order, ...state];
  }

  void cancelOrder(String id) {
    state = [
      for (final o in state)
        if (o.id == id) o.copyWith(status: OrderStatus.cancelled) else o,
    ];
  }
}

final ordersProvider =
    NotifierProvider<OrdersNotifier, List<OrderModel>>(OrdersNotifier.new);

// Pre-existing demo orders shown before user places any real order
const _initialOrders = [
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
