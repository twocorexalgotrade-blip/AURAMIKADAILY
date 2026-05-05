import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import 'shop_models.dart';

// Deterministic brand palettes cycled by vendor index
const _brandColors = [
  Color(0xFF1A2F25),
  Color(0xFF6B5334),
  Color(0xFF1A1A2E),
  Color(0xFF8B4513),
  Color(0xFF2C2C2C),
  Color(0xFF4A0A60),
];

const _gradients = [
  [Color(0xFF0F1F18), Color(0xFF2D5016)],
  [Color(0xFF4A3520), Color(0xFF8B6B44)],
  [Color(0xFF0D0D1A), Color(0xFF2A2A40)],
  [Color(0xFF6B3010), Color(0xFFAA6030)],
  [Color(0xFF1A1A1A), Color(0xFF3D3D3D)],
  [Color(0xFF2D0440), Color(0xFF6B1580)],
];

final shopsProvider = FutureProvider<List<ShopModel>>((ref) async {
  try {
    final dio = Dio(BaseOptions(
      baseUrl: '${AppConstants.baseUrl}/api/v1',
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
    ));
    final res = await dio.get<Map<String, dynamic>>('/vendors');
    final vendors = (res.data!['vendors'] as List).cast<Map<String, dynamic>>();

    final apiShops = vendors.asMap().entries.map((entry) {
      final i = entry.key % _brandColors.length;
      final v = entry.value;
      return ShopModel(
        id: v['id'] as String,
        name: v['name'] as String,
        description: (v['description'] as String?) ?? 'Premium jewelry collection',
        bannerImageUrl: (v['banner_url'] as String?) ?? '',
        brandColor: _brandColors[i],
        gradientColors: _gradients[i],
        rating: (v['rating'] as num?)?.toDouble() ?? 0.0,
        totalProducts: (v['total_products'] as int?) ?? 0,
        tags: const [],
        location: 'India',
      );
    }).toList();

    // Static shops: Auramika first, then real vendor-app stores, then the rest
    final staticIds = ShopData.allShops.map((s) => s.id).toSet();
    final newVendors = apiShops.where((s) => !staticIds.contains(s.id)).toList();
    return [ShopData.allShops.first, ...newVendors, ...ShopData.allShops.skip(1)];
  } catch (_) {
    return ShopData.allShops;
  }
});
