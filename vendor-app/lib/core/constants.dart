class AppConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://auramikadaily-appbackend.onrender.com/api/v1',
  );

  static const String tokenKey = 'vendor_jwt';
  static const String vendorKey = 'vendor_data';
}
