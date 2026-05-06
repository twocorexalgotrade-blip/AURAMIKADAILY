import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/login/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/products/product_form_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/profile/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authState.isLoading) return null;
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == '/login';
      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/products', builder: (_, __) => const ProductsScreen()),
          GoRoute(path: '/products/new', builder: (_, __) => const ProductFormScreen()),
          GoRoute(
            path: '/products/:id/edit',
            builder: (_, state) => ProductFormScreen(productId: state.pathParameters['id']),
          ),
          GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int index = 0;
    if (location.startsWith('/products')) index = 1;
    if (location.startsWith('/orders')) index = 2;
    if (location.startsWith('/profile')) index = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFAFAF5),
          border: Border(top: BorderSide(color: Color(0xFFD4AF37), width: 0.8)),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: const Color(0xFF1A2F25).withAlpha(18),
          labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? const Color(0xFF1A2F25)
                : const Color(0xFF8A8A8A),
          )),
          selectedIndex: index,
          onDestinationSelected: (i) {
            if (i == 0) context.go('/');
            if (i == 1) context.go('/products');
            if (i == 2) context.go('/orders');
            if (i == 3) context.go('/profile');
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined, color: Color(0xFF8A8A8A)),
              selectedIcon: Icon(Icons.grid_view, color: Color(0xFF1A2F25)),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined, color: Color(0xFF8A8A8A)),
              selectedIcon: Icon(Icons.inventory_2, color: Color(0xFF1A2F25)),
              label: 'Products',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: Color(0xFF8A8A8A)),
              selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF1A2F25)),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: Color(0xFF8A8A8A)),
              selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF1A2F25)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
