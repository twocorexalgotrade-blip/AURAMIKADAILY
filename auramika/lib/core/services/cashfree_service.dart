import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class PaymentSessionResult {
  final String orderId;
  final String cashfreeOrderId;
  final String sessionId;
  final double total;
  final bool isTestMode;
  final bool isMock;

  const PaymentSessionResult({
    required this.orderId,
    required this.cashfreeOrderId,
    required this.sessionId,
    required this.total,
    required this.isTestMode,
    this.isMock = false,
  });
}

class CashfreeService {
  final _dio = Dio(BaseOptions(
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
  ));

  Future<String> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    debugPrint('[CF] 🔐 currentUser=${user?.uid ?? "NULL — not signed in"}');
    if (user == null) throw Exception('Please sign in before placing an order.');
    final token = await user.getIdToken();
    debugPrint('[CF] 🔐 idToken obtained (first 30): ${token!.substring(0, 30)}…');
    return token;
  }

  /// Creates a backend order and returns a Cashfree payment session.
  /// When the backend is in mock mode (CASHFREE_MOCK=true), isMock is true
  /// and the caller should skip the Cashfree SDK entirely.
  Future<PaymentSessionResult> createOrderAndGetSession({
    required List<Map<String, dynamic>> items,
    required Map<String, String> address,
    required bool isExpress,
    required String customerName,
    required String customerPhone,
  }) async {
    debugPrint('[CF] ── createOrderAndGetSession START ──');
    debugPrint('[CF] baseUrl=${AppConstants.baseUrl}');
    debugPrint('[CF] items count=${items.length}  isExpress=$isExpress');

    final token = await _getIdToken();
    final authHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Single call: backend creates the order AND the Cashfree session in one
    // round trip. Saves ~150-300ms vs. the legacy 2-step /orders → /payments
    // flow.
    final payload = {
      'items': items,
      'address': address,
      'isExpress': isExpress,
      'customerName': customerName.isNotEmpty ? customerName : 'Customer',
      'customerPhone': customerPhone.isNotEmpty ? customerPhone : '9999999999',
    };
    debugPrint('[CF] POST /api/v1/payments/start  payload=$payload');

    late Response res;
    try {
      res = await _dio.post(
        '${AppConstants.baseUrl}/api/v1/payments/start',
        data: payload,
        options: Options(headers: authHeaders),
      );
      debugPrint('[CF] response ${res.statusCode}: ${res.data}');
    } on DioException catch (e) {
      debugPrint('[CF] DioException: ${e.type}  status=${e.response?.statusCode}  body=${e.response?.data}  msg=${e.message}');
      rethrow;
    }

    final orderId         = res.data['orderId'] as String;
    final cashfreeOrderId = res.data['cashfreeOrderId'] as String? ?? '';
    final total           = (res.data['total'] as num).toDouble();
    final isMock          = res.data['isMock'] as bool? ?? false;
    final sessionId       = res.data['paymentSessionId'] as String? ?? '';
    final mode            = res.data['mode'] as String? ?? '?';

    debugPrint('[CF] orderId=$orderId  cfOrderId=$cashfreeOrderId  total=$total  isMock=$isMock  mode=$mode');

    if (!isMock && sessionId.isEmpty) {
      debugPrint('[CF] ❌ No payment session ID — aborting');
      throw Exception('No payment session ID returned from server.');
    }

    final isTestMode = mode != 'PROD';
    debugPrint('[CF] ── createOrderAndGetSession DONE  isTestMode=$isTestMode ──');

    return PaymentSessionResult(
      orderId: orderId,
      cashfreeOrderId: cashfreeOrderId,
      sessionId: sessionId,
      total: total,
      isTestMode: isTestMode,
      isMock: isMock,
    );
  }

  /// Calls the verify endpoint after Cashfree SDK returns success.
  /// The backend confirms the order if Cashfree reports PAID — this is the
  /// fallback for sandbox where webhooks may not fire.
  Future<void> verifyAndConfirm(String cashfreeOrderId) async {
    final token = await _getIdToken();
    await _dio.get(
      '${AppConstants.baseUrl}/api/v1/payments/verify/$cashfreeOrderId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    debugPrint('[CF] verifyAndConfirm done for $cashfreeOrderId');
  }
}
