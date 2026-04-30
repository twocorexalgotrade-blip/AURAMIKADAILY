/// AURAMIKA — Global App Constants
abstract class AppConstants {
  // ── App Identity ──────────────────────────────────────────────────────────
  static const String appName = 'AURAMIKA DAILY';
  static const String appTagline = 'Wear Your Vibe';
  static const String appVersion = '1.0.0';

  // ── Express Delivery ──────────────────────────────────────────────────────
  static const int expressDeliveryHours = 2;
  static const String expressDeliveryLabel = 'Get it in 2 Hours';
  static const String expressDeliveryBadge = '⚡ 2-HR EXPRESS';

  // ── Style Vibes / Categories ──────────────────────────────────────────────
  static const List<String> styleVibes = [
    'Old Money',
    'Street Wear',
    'Daily Minimalist',
    'Party / Glam',
  ];

  // ── Material Types ────────────────────────────────────────────────────────
  static const List<String> materialTypes = ['All', 'Brass', 'Copper'];

  // ── Website URLs ─────────────────────────────────────────────────────────
  static const String websiteBase       = 'https://auramikadaily.com';
  static const String urlPrivacyPolicy  = 'https://auramikadaily.com/privacy.html';
  static const String urlTerms          = 'https://auramikadaily.com/terms.html';
  static const String urlRefundPolicy   = 'https://auramikadaily.com/returns';
  static const String urlShippingPolicy = 'https://auramikadaily.com/shipping-policy';

  // ── Cashfree ──────────────────────────────────────────────────────────────
  // Set to true to force Cashfree sandbox (test) mode regardless of backend.
  static const bool cashfreeTestMode = true;

  // ── API ───────────────────────────────────────────────────────────────────
  // Update to your Render backend URL (Render dashboard → service → URL).
  static const String baseUrl = 'https://auramikadaily.com';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Hive Box Names ────────────────────────────────────────────────────────
  static const String cartBox = 'cart_box';
  static const String userBox = 'user_box';
  static const String wishlistBox = 'wishlist_box';
  static const String settingsBox = 'settings_box';

  // ── Animation Durations ───────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration animVerySlow = Duration(milliseconds: 900);

  // ── Layout ────────────────────────────────────────────────────────────────
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  static const double radiusXS = 2.0;
  static const double radiusS = 4.0;   // Sharp/minimalist — brand standard
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusRound = 100.0;

  static const double cardElevation = 0.0;
  static const double bottomNavHeight = 72.0;
  static const double appBarHeight = 120.0;

  // ── Masonry Grid ──────────────────────────────────────────────────────────
  static const int masonryCrossAxisCount = 2;
  static const double masonryMainAxisSpacing = 12.0;
  static const double masonryCrossAxisSpacing = 12.0;
}
