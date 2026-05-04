import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';
import '../models/vendor.dart';
import '../services/api_client.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, Vendor?>(() => AuthNotifier());

class AuthNotifier extends AsyncNotifier<Vendor?> {
  @override
  Future<Vendor?> build() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: AppConstants.tokenKey);
    if (token == null) return null;

    try {
      final api = ref.read(apiClientProvider);
      final res = await api.get<Map<String, dynamic>>('/vendor/me');
      final data = res.data!;
      return Vendor.fromJson({...data, 'username': data['username'] ?? ''});
    } catch (_) {
      await storage.delete(key: AppConstants.tokenKey);
      return null;
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      final res = await api.post<Map<String, dynamic>>('/vendor/login', data: {
        'username': username,
        'password': password,
      });
      final data = res.data!;
      final token = data['token'] as String;
      final storage = ref.read(secureStorageProvider);
      await storage.write(key: AppConstants.tokenKey, value: token);

      final vendorData = data['vendor'] as Map<String, dynamic>;
      return Vendor.fromJson({...vendorData, 'username': username});
    });
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: AppConstants.tokenKey);
    state = const AsyncData(null);
  }
}
