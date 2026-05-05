import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import 'shop_models.dart';

// Deterministic brand palettes cycled by vendor index — must stay in sync with
// ShopData.allShops colours so API shops get clearly distinct jewel tones
const _brandColors = [
  Color(0xFF0C2B1E),  // forest green
  Color(0xFF5A0E1E),  // burgundy
  Color(0xFF0A1A38),  // royal navy
  Color(0xFF7A2C08),  // cognac
  Color(0xFF1A1816),  // obsidian
  Color(0xFF2C0858),  // amethyst
];

const _gradients = [
  [Color(0xFF061810), Color(0xFF1A4828)],
  [Color(0xFF380810), Color(0xFF881828)],
  [Color(0xFF060F22), Color(0xFF102050)],
  [Color(0xFF4A1A04), Color(0xFFA04818)],
  [Color(0xFF0A0908), Color(0xFF2C2A26)],
  [Color(0xFF180430), Color(0xFF460A88)],
];

// Per-name colour overrides — key is the vendor name lowercased & trimmed
const _nameColors = <String, Color>{
  'test jeweles': Color(0xFF3A2600),  // dark antique gold
};
const _nameGradients = <String, List<Color>>{
  'test jeweles': [Color(0xFF1E1300), Color(0xFF604000)],
};

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
      final nameLower = (v['name'] as String).toLowerCase().trim();
      return ShopModel(
        id: v['id'] as String,
        name: v['name'] as String,
        description: (v['description'] as String?) ?? 'Premium jewelry collection',
        bannerImageUrl: (v['banner_url'] as String?) ?? '',
        brandColor: _nameColors[nameLower] ?? _brandColors[i],
        gradientColors: _nameGradients[nameLower] ?? _gradients[i],
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
