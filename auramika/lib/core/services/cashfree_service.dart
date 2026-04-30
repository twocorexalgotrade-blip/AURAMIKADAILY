import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';

class PaymentSessionResult {
  final String orderId;
  final String sessionId;
  final double total;
  final bool isTestMode;
  final bool isMock;

  const PaymentSessionResult({
    required this.orderId,
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
    if (user == null) throw Exception('Please sign in before placing an order.');
    return user.getIdToken().then((t) => t!);
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

    final isMock = paymentRes.data['isMock'] as bool? ?? false;
    final sessionId = paymentRes.data['paymentSessionId'] as String? ?? '';
    if (!isMock && sessionId.isEmpty) {
      throw Exception('No payment session ID returned from server.');
    }

    final isTestMode = (paymentRes.data['mode'] as String?) != 'PROD';

    return PaymentSessionResult(
      orderId: orderId,
      sessionId: sessionId,
      total: total,
      isTestMode: isTestMode,
      isMock: isMock,
    );
  }
}
