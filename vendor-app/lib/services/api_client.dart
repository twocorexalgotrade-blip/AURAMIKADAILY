import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

class ApiClient {
  final FlutterSecureStorage _storage;
  final void Function()? onUnauthorized;
  late final Dio _dio;

  ApiClient(this._storage, {this.onUnauthorized}) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        // Dio silently stores raw strings when the server returns non-JSON
        // (e.g. an HTML page from a misconfigured reverse proxy). Detect this
        // early and surface a clear error instead of a confusing type-cast crash.
        if (response.data is String) {
          final raw = response.data as String;
          try {
            response.data = jsonDecode(raw);
          } catch (_) {
            return handler.reject(DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
              error: 'Backend returned an unexpected response (not JSON). '
                  'The server may still be deploying — please try again in a moment.',
            ));
          }
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: AppConstants.tokenKey);
          onUnauthorized?.call();
        }
        handler.next(error);
      },
    ));
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? params}) =>
      _dio.get<T>(path, queryParameters: params);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);

  // Direct HttpClient PUT to S3 presigned URL (Dio stream approach is unreliable for binary)
  Future<void> putToS3(String presignedUrl, List<int> bytes, String contentType) async {
    final client = HttpClient();
    try {
      final request = await client.putUrl(Uri.parse(presignedUrl));
      request.headers.set(HttpHeaders.contentTypeHeader, contentType);
      request.headers.set(HttpHeaders.contentLengthHeader, bytes.length);
      request.add(bytes);
      final response = await request.close();
      await response.drain<void>();
      if (response.statusCode >= 400) {
        throw Exception('S3 upload failed: ${response.statusCode}');
      }
    } finally {
      client.close();
    }
  }
}
