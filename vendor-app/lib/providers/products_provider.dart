import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_client.dart';

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  () => ProductsNotifier(),
);

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() => _fetch();

  Future<List<Product>> _fetch() async {
    final api = ref.read(apiClientProvider);
    final res = await api.get<Map<String, dynamic>>('/vendor/products');
    final list = res.data!['products'] as List;
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final api = ref.read(apiClientProvider);
    final res = await api.post<Map<String, dynamic>>('/vendor/products', data: data);
    final product = Product.fromJson(res.data!);
    state = AsyncData([product, ...state.value ?? []]);
    return product;
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> data) async {
    final api = ref.read(apiClientProvider);
    final res = await api.put<Map<String, dynamic>>('/vendor/products/$id', data: data);
    final updated = Product.fromJson(res.data!);
    state = AsyncData(
      (state.value ?? []).map((p) => p.id == id ? updated : p).toList(),
    );
    return updated;
  }

  Future<void> deleteProduct(String id) async {
    final api = ref.read(apiClientProvider);
    await api.delete('/vendor/products/$id');
    state = AsyncData((state.value ?? []).where((p) => p.id != id).toList());
  }

  Future<String> uploadImage(File file, String filename) async {
    final api = ref.read(apiClientProvider);
    final bytes = await file.readAsBytes();
    final ext = filename.split('.').last.toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';

    final presignRes = await api.post<Map<String, dynamic>>(
      '/vendor/images/presign',
      data: {'filename': filename, 'contentType': contentType},
    );
    final uploadUrl = presignRes.data!['uploadUrl'] as String;
    final publicUrl = presignRes.data!['publicUrl'] as String;

    await api.putToS3(uploadUrl, bytes, contentType);
    return publicUrl;
  }
}
