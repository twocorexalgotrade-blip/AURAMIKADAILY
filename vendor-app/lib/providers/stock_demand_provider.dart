import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class StockDemandItem {
  final String id;
  final String productName;
  final double price;
  final String imageUrl;
  final int demandCount;

  const StockDemandItem({
    required this.id,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.demandCount,
  });

  factory StockDemandItem.fromJson(Map<String, dynamic> j) => StockDemandItem(
        id: j['id'] as String,
        productName: j['product_name'] as String,
        price: (j['price'] as num).toDouble(),
        imageUrl: j['image_url'] as String? ?? '',
        demandCount: (j['demand_count'] as num?)?.toInt() ?? 0,
      );
}

final stockDemandProvider =
    AsyncNotifierProvider<StockDemandNotifier, List<StockDemandItem>>(
  () => StockDemandNotifier(),
);

class StockDemandNotifier extends AsyncNotifier<List<StockDemandItem>> {
  @override
  Future<List<StockDemandItem>> build() => _fetch();

  Future<List<StockDemandItem>> _fetch() async {
    final api = ref.read(apiClientProvider);
    final res = await api.get<Map<String, dynamic>>('/vendor/stock-demand');
    final list = res.data!['items'] as List;
    return list
        .map((e) => StockDemandItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
