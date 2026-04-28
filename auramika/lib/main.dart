import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

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

  runApp(
    // ProviderScope is the root of the Riverpod dependency injection tree
    const ProviderScope(
      child: AuramikaApp(),
    ),
  );
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
