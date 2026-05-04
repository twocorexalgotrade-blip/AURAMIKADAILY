import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class _AppObserver extends ProviderObserver {
  @override
  void didAddProvider(ProviderBase provider, Object? value, ProviderContainer container) {
    debugPrint('[Riverpod] INIT ${provider.name ?? provider.runtimeType}: $value');
  }

  @override
  void didUpdateProvider(ProviderBase provider, Object? previousValue, Object? newValue, ProviderContainer container) {
    debugPrint('[Riverpod] UPDATE ${provider.name ?? provider.runtimeType}: $previousValue → $newValue');
  }

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer container) {
    debugPrint('[Riverpod] DISPOSE ${provider.name ?? provider.runtimeType}');
  }

  @override
  void providerDidFail(ProviderBase provider, Object error, StackTrace stackTrace, ProviderContainer container) {
    debugPrint('[Riverpod] ERROR ${provider.name ?? provider.runtimeType}: $error\n$stackTrace');
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
///  AURAMIKA — Entry Point
///
///  Architecture:
///    • ProviderScope  → Riverpod DI root
///    • MaterialApp.router → go_router integration
///    • AppTheme.lightTheme → "Premium Gen Z / Old Money" design system
/// ─────────────────────────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('profile');

  // ── System UI ──────────────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFFAFAF5),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ── Portrait lock (can be unlocked per-screen later) ──────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Pre-warm payment-critical paths so checkout feels instant ─────────────
  // 1. Touch the Cashfree native plugin so the SDK channel is ready by the
  //    time the user reaches the pay screen (~500ms saved on first invoke).
  // 2. Hit the backend /health endpoint so any cold connection / DNS / TLS
  //    handshake is paid up-front, not at checkout.
  // Both fire-and-forget; failures here must never block app launch.
  unawaited(_prewarmPaymentStack());

  runApp(
    ProviderScope(
      observers: kDebugMode ? [_AppObserver()] : [],
      child: const AuramikaApp(),
    ),
  );
}

Future<void> _prewarmPaymentStack() async {
  try {
    // Touch the singleton so its platform channel registers early. We do NOT
    // call setCallback here — that would clobber the real callbacks set in
    // CheckoutScreen.initState and silently break the verify/error flow.
    CFPaymentGatewayService();
    if (kDebugMode) debugPrint('[Prewarm] Cashfree SDK singleton touched');
  } catch (e) {
    if (kDebugMode) debugPrint('[Prewarm] Cashfree SDK init skipped: $e');
  }

  try {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
    ));
    final res = await dio.get('${AppConstants.baseUrl}/health');
    if (kDebugMode) debugPrint('[Prewarm] backend /health → ${res.statusCode}');
  } catch (e) {
    if (kDebugMode) debugPrint('[Prewarm] backend /health skipped: $e');
  }
}

/// Root application widget.
///
/// Consumes [appRouterProvider] via [ConsumerWidget] so the router
/// is properly scoped within Riverpod's dependency graph.
class AuramikaApp extends ConsumerWidget {
  const AuramikaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      // ── Identity ────────────────────────────────────────────────────────
      title: 'AURAMIKA',
      debugShowCheckedModeBanner: false,

      // ── Theme ────────────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      // Dark theme intentionally omitted for Phase 1 — "Old Money" is light
      themeMode: ThemeMode.light,

      // ── Router ───────────────────────────────────────────────────────────
      routerConfig: router,

      // ── Locale ───────────────────────────────────────────────────────────
      locale: const Locale('en', 'IN'),
      supportedLocales: const [
        Locale('en', 'IN'),
        Locale('en', 'US'),
      ],

      // ── Builder — global MediaQuery text scale clamp ─────────────────────
      builder: (context, child) {
        // Prevent system font scaling from breaking the editorial layout
        final mediaQuery = MediaQuery.of(context);
        final clampedScale = mediaQuery.textScaler
            .scale(1.0)
            .clamp(0.85, 1.15);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(clampedScale),
          ),
          child: child!,
        );
      },
    );
  }
}
