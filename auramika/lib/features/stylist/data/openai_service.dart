import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/secrets/app_secrets.dart';
import '../../home/domain/home_models.dart';

/// OpenAI Service for GPT-4o powered styling recommendations
class OpenAIService {
  final Dio _dio;

  OpenAIService() : _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openai.com/v1',
      headers: {
        'Authorization': 'Bearer $openAiKey',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Gender tag: M = men, F = women, U = unisex
  // Used to filter catalog so AI never recommends women's pieces to men and vice versa.
  static String _genderTag(String id) {
    // Street wear
    if (id == 'sw1' || id == 'sw4' || id == 'sw7') return 'M';
    if (id == 'sw3') return 'U';
    if (id.startsWith('sw')) return 'F';
    // Necklaces
    if (id == 'n1' || id == 'n8') return 'M';
    if (id == 'n5' || id == 'n6') return 'U';
    if (id.startsWith('n')) return 'F';
    // Earrings — mostly F; studs/small hoops can be U
    if (id == 'e15' || id == 'e12' || id == 'e6') return 'U';
    if (id.startsWith('e')) return 'F';
    // Rings — unisex
    if (id.startsWith('r')) return 'U';
    // Bracelets
    if (id == 'b2' || id == 'b6' || id == 'b10') return 'U';
    if (id.startsWith('b')) return 'F';
    return 'U';
  }

  /// Get styling recommendation from GPT-4o
  /// Analyzes the user's outfit image and recommends a product from the catalog
  /// Returns the product ID as a string, or null on error
  Future<String?> getStylingRecommendation(
    File image,
    List<HomeProduct> catalog,
  ) async {
    try {
      // Convert image to base64
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Build catalog JSON with gender tags so the AI can filter correctly
      final catalogJson = catalog.map((HomeProduct p) => {
        'id': p.id,
        'name': p.productName,
        'material': p.material,
        'price': p.price,
        'vibe': p.vibe,
        'gender': _genderTag(p.id), // M | F | U
      }).toList();
      final catalogString = jsonEncode(catalogJson);

      // Build messages
      final messages = [
        {
          'role': 'system',
          'content': '''You are a high-end fashion stylist for AURAMIKA, a luxury Indian jewelry brand.

STEP 1 — Detect gender presentation: Look at the person in the image and determine their gender presentation: M (male), F (female), or U (unclear/non-binary).

STEP 2 — Filter catalog:
  • If M → only consider products where gender is "M" or "U"
  • If F → only consider products where gender is "F" or "U"
  • If U → consider all products

STEP 3 — Select: From the filtered products, pick the SINGLE item that best complements the outfit style, colors, and occasion.

Return ONLY the product ID as a plain string. No markdown, no JSON, no explanation.''',
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': 'Analyze the outfit and recommend one jewelry piece. Catalog: $catalogString',
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ];

      // Make API call
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-4o',
          'messages': messages,
          'max_tokens': 50,
        },
      );

      // Parse response
      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'] as String;
        final productId = content.trim();

        // Validate that it's a valid product ID
        if (catalog.any((p) => p.id == productId)) {
          return productId;
        }
      }

      return null;
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('OpenAI API Error: ${e.message}');
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('OpenAI Error: $e');
      return null;
    }
  }
}
