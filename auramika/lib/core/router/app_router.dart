import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/custom_order/presentation/screens/custom_order_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/jewellery_category_screen.dart';
import '../../features/home/presentation/screens/style_vibe_screen.dart';
import '../../features/product/presentation/screens/product_detail_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/profile/presentation/screens/gift_cards_screen.dart';
import '../../features/profile/presentation/screens/help_screen.dart';
import '../../features/profile/presentation/screens/orders_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/profile/presentation/screens/profile_details_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/rate_review_screen.dart';
import '../../features/profile/presentation/screens/refunds_screen.dart';
import '../../features/profile/presentation/screens/terms_conditions_screen.dart';
import '../../features/profile/presentation/screens/terms_of_service_screen.dart';
import '../../features/profile/presentation/screens/transactions_screen.dart';
import '../../features/profile/presentation/screens/wishlist_screen.dart';
import '../../features/stylist/presentation/screens/stylist_screen.dart';
import '../../features/vendor/presentation/screens/vendor_screen.dart';
import '../../shared/widgets/main_wrapper.dart';

// ── Route paths ───────────────────────────────────────────────────────────────
class AppRoutes {
  static const home = '/';
  static const categories = '/categories';
  static const stylist = '/mirror';
  static const shop = '/shop';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const customOrder = '/custom-order';
  static const profile = '/profile';
  static const orders = '/orders';
  static const wishlist = '/wishlist';
  static const transactions = '/transactions';
  static const giftCards = '/gift-cards';
  static const rateReview = '/rate-review';
  static const refunds = '/refunds';
  static const help = '/help';
  static const privacyPolicy = '/privacy-policy';
  static const termsConditions = '/terms-conditions';
  static const termsOfService = '/terms-of-service';
  static const login = '/login';
  static const orderConfirmation = '/order-confirmation';

  static String product(String id) => '/product/$id';
}

// ── Router provider ───────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: false,
    routes: [
      // ── Shell (bottom nav) ────────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainWrapper(navigationShell: navigationShell),
        branches: [
          // Branch 0 — Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 1 — Categories (Jewellery)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.categories,
                builder: (context, state) => const JewelleryCategoryScreen(),
              ),
            ],
          ),

          // Branch 2 — Mirror (AI Stylist)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stylist,
                builder: (context, state) => const StylistScreen(),
              ),
            ],
          ),

          // Branch 3 — Shop (Vendor)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.shop,
                builder: (context, state) => const VendorScreen(),
              ),
            ],
          ),

          // Branch 4 — Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Full-screen routes (outside shell) ───────────────────────────────
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.customOrder,
        builder: (context, state) => const CustomOrderScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.wishlist,
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: AppRoutes.transactions,
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.giftCards,
        builder: (context, state) => const GiftCardsScreen(),
      ),
      GoRoute(
        path: AppRoutes.rateReview,
        builder: (context, state) => const RateReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.refunds,
        builder: (context, state) => const RefundsScreen(),
      ),
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: AppRoutes.termsConditions,
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.termsOfService,
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return LoginScreen(
            redirectPath: extra?['redirect'] as String?,
            isCreateAccount: false,
          );
        },
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return LoginScreen(
            redirectPath: extra?['redirect'] as String?,
            isCreateAccount: true,
          );
        },
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpScreen(
            phone: extra['phone'] as String? ?? '',
            redirectPath: extra['redirect'] as String? ?? '/',
            expectNewUser: extra['expectNewUser'] as bool? ?? false,
            name: extra['name'] as String?,
            email: extra['email'] as String?,
            dob: extra['dob'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.orderConfirmation,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Order Confirmed!')),
        ),
      ),
    ],
  );
});
