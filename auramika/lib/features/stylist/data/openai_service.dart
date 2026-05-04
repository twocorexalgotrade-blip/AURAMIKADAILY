import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_constants.dart';
import '../../home/domain/home_models.dart';

/// Magic Mirror styling service — proxies through the AURAMIKA backend.
///
/// The OpenAI key lives ONLY on the backend (env: `OPENAI_API_KEY`). The
/// client never sees it. This avoids:
///   • App Store 5.1.2 rejection for hardcoded credentials
///   • IPA decompilation → key theft → financial abuse
///   • OpenAI TOS violation
///
/// Backend route: `POST /api/v1/stylist/recommend` (Firebase-auth + 20/day cap).
class OpenAIService {
  final Dio _dio;

  OpenAIService()
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ));

  // Gender tag: M = men, F = women, U = unisex.
  // Used to filter the catalog so the model never recommends a women's piece
  // to a man and vice versa. Lives client-side because it depends on hardcoded
  // catalog IDs — moving it server-side would require a `gender` column.
  static String _genderTag(String id) {
    if (id == 'sw1' || id == 'sw4' || id == 'sw7') return 'M';
    if (id == 'sw3') return 'U';
    if (id.startsWith('sw')) return 'F';
    if (id == 'n1' || id == 'n8') return 'M';
    if (id == 'n5' || id == 'n6') return 'U';
    if (id.startsWith('n')) return 'F';
    if (id == 'e15' || id == 'e12' || id == 'e6') return 'U';
    if (id.startsWith('e')) return 'F';
    if (id.startsWith('r')) return 'U';
    if (id == 'b2' || id == 'b6' || id == 'b10') return 'U';
    if (id.startsWith('b')) return 'F';
    return 'U';
  }

  /// Returns the recommended product ID, or null on error / no match.
  Future<String?> getStylingRecommendation(
    File image,
    List<HomeProduct> catalog,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (kDebugMode) debugPrint('[Stylist] not signed in — aborting');
        return null;
      }
      final token = await user.getIdToken();

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final catalogPayload = catalog
          .map((p) => {
                'id':       p.id,
                'name':     p.productName,
                'material': p.material,
                'price':    p.price,
                'vibe':     p.vibe,
                'gender':   _genderTag(p.id),
              })
          .toList();

      final res = await _dio.post(
        '/api/v1/stylist/recommend',
        data: {
          'imageBase64': base64Image,
          'catalog': catalogPayload,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final productId = res.data['productId'] as String?;
      if (productId != null && catalog.any((p) => p.id == productId)) {
        return productId;
      }
      return null;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('[Stylist] backend error: ${e.response?.statusCode} ${e.response?.data}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('[Stylist] error: $e');
      return null;
    }
  }
}
