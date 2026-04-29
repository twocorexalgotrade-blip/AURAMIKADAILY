import 'package:dio/dio.dart';

/// Wraps Cashfree REST API for order creation.
///
/// SECURITY NOTE: _secretKey must never ship in a production build.
/// Move order creation to a backend endpoint and pass only
/// payment_session_id to the app.
class CashfreeService {
  static const _appId     = '12060982a633b3a49e76d91fb768906021';
  static const _secretKey = 'cfsk_ma_prod_3811f21c4f21540a2727bddaelc2f2e6_253d91';
  static const _baseUrl   = 'https://api.cashfree.com/pg';

  // Expose appId so the SDK can be initialised elsewhere.
  static String get appId => _appId;

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Creates a Cashfree order and returns the [paymentSessionId].
  Future<String> createOrder({
    required String orderId,
    required double amount,
    required String customerName,
    required String customerPhone,
    String customerEmail = 'customer@auramika.in',
  }) async {
    final response = await _dio.post(
      '$_baseUrl/orders',
      data: {
        'order_id':        orderId,
        'order_amount':    amount,
        'order_currency':  'INR',
        'customer_details': {
          'customer_id':    'CUST_$orderId',
          'customer_name':  customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
        },
      },
      options: Options(headers: {
        'x-api-version':   '2023-08-01',
        'x-client-id':     _appId,
        'x-client-secret': _secretKey,
        'Content-Type':    'application/json',
      }),
    );
    return response.data['payment_session_id'] as String;
  }
}
