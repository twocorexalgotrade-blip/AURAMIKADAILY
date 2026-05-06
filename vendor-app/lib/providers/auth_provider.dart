import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';
import '../models/vendor.dart';
import '../services/api_client.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, Vendor?>(() => AuthNotifier());

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage, onUnauthorized: () {
    ref.read(authProvider.notifier).logout();
  });
});

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

  Future<void> uploadLogo(File file) async {
    final api = ref.read(apiClientProvider);
    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
    final filename = 'logo_${DateTime.now().millisecondsSinceEpoch}.$ext';

    final presignRes = await api.post<Map<String, dynamic>>(
      '/vendor/images/presign',
      data: {'filename': filename, 'contentType': contentType},
    );
    final uploadUrl = presignRes.data!['uploadUrl'] as String;
    final publicUrl = presignRes.data!['publicUrl'] as String;

    await api.putToS3(uploadUrl, bytes, contentType);
    await api.put<void>('/vendor/me/logo', data: {'logo_url': publicUrl});

    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(logoUrl: publicUrl));
    }
  }

  Future<void> uploadBanner(File file) async {
    final api = ref.read(apiClientProvider);
    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
    final filename = 'banner_${DateTime.now().millisecondsSinceEpoch}.$ext';

    final presignRes = await api.post<Map<String, dynamic>>(
      '/vendor/images/presign',
      data: {'filename': filename, 'contentType': contentType},
    );
    final uploadUrl = presignRes.data!['uploadUrl'] as String;
    final publicUrl = presignRes.data!['publicUrl'] as String;

    await api.putToS3(uploadUrl, bytes, contentType);
    await api.put<void>('/vendor/me/banner', data: {'banner_url': publicUrl});

    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(bannerUrl: publicUrl));
    }
  }
}
