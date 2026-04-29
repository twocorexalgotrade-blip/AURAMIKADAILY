import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';

class PaymentSessionResult {
  final String orderId;
  final String sessionId;
  final double total;
  final bool isTestMode;

  const PaymentSessionResult({
    required this.orderId,
    required this.sessionId,
    required this.total,
    required this.isTestMode,
  });
}

class CashfreeService {
  final _dio = Dio(BaseOptions(
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
  ));

  Future<String> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Please sign in before placing an order.');
    return user.getIdToken();
  }

  /// Creates a backend order and returns a Cashfree payment session.
  /// The backend is the source of truth for the order amount.
  Future<PaymentSessionResult> createOrderAndGetSession({
    required List<Map<String, dynamic>> items,
    required Map<String, String> address,
    required bool isExpress,
    required String customerName,
    required String customerPhone,
  }) async {
    final token = await _getIdToken();
    final authHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Step 1: Create order record in backend → get orderId + server-side total.
    final orderRes = await _dio.post(
      '${AppConstants.baseUrl}/api/v1/orders',
      data: {
        'items': items,
        'address': address,
        'isExpress': isExpress,
      },
      options: Options(headers: authHeaders),
    );

    final orderId = orderRes.data['orderId'] as String;
    final total = (orderRes.data['total'] as num).toDouble();

    // Step 2: Ask backend to create a Cashfree order → get payment_session_id.
    final paymentRes = await _dio.post(
      '${AppConstants.baseUrl}/api/v1/payments/create-order',
      data: {
        'orderId': orderId,
        'customerName': customerName.isNotEmpty ? customerName : 'Customer',
        'customerPhone': customerPhone.isNotEmpty ? customerPhone : '9999999999',
      },
      options: Options(headers: authHeaders),
    );

    final sessionId = paymentRes.data['paymentSessionId'] as String?;
    if (sessionId == null) throw Exception('No payment session ID returned from server.');

    final isTestMode = (paymentRes.data['mode'] as String?) != 'PROD';

    return PaymentSessionResult(
      orderId: orderId,
      sessionId: sessionId,
      total: total,
      isTestMode: isTestMode,
    );
  }
}
