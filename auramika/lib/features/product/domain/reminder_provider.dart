import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';

// Set of product IDs the current user has registered reminders for.
final remindersProvider =
    StateNotifierProvider<RemindersNotifier, Set<String>>(
  (_) => RemindersNotifier(),
);

class RemindersNotifier extends StateNotifier<Set<String>> {
  RemindersNotifier() : super({}) {
    _load();
  }

  final _dio = Dio(BaseOptions(
    baseUrl: '${AppConstants.baseUrl}/api/v1',
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
  ));

  Future<String?> _token() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }

  Future<void> _load() async {
    try {
      final token = await _token();
      if (token == null) return;
      final res = await _dio.get<Map<String, dynamic>>(
        '/reminders',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final ids = (res.data!['productIds'] as List).cast<String>().toSet();
      state = ids;
    } catch (e) {
      debugPrint('[Reminders] load error: $e');
    }
  }

  Future<bool> toggle(String productId) async {
    final wasSet = state.contains(productId);
    // Optimistic update
    state = wasSet
        ? {...state}..remove(productId)
        : {...state, productId};
    try {
      final token = await _token();
      if (token == null) {
        state = wasSet ? {...state, productId} : {...state}..remove(productId);
        return false;
      }
      if (wasSet) {
        await _dio.delete(
          '/reminders/$productId',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } else {
        await _dio.post(
          '/reminders',
          data: {'productId': productId},
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
      return true;
    } catch (e) {
      // Revert on failure
      state = wasSet ? {...state, productId} : {...state}..remove(productId);
      debugPrint('[Reminders] toggle error: $e');
      return false;
    }
  }
}
