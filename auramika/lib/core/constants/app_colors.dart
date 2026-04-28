import 'package:flutter/material.dart';

/// AURAMIKA Color Palette — "Premium Gen Z / Old Money"
abstract class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────────────
  /// Alabaster / Warm Cream — primary background
  static const Color background = Color(0xFFFAFAF5);

  /// Slightly deeper cream for cards / surfaces
  static const Color surface = Color(0xFFF5F5EE);

  /// Pure white for overlays
  static const Color white = Color(0xFFFFFFFF);

  // ── Text ─────────────────────────────────────────────────────────────────
  /// Deep Forest Green — primary text
  static const Color textPrimary = Color(0xFF1A2F25);

  /// Charcoal — secondary text
  static const Color textSecondary = Color(0xFF222222);

  /// Muted grey — hint / disabled text
  static const Color textMuted = Color(0xFF8A8A8A);

  // ── Accents ───────────────────────────────────────────────────────────────
  /// Burnished Gold — primary accent / CTA
  static const Color gold = Color(0xFFD4AF37);

  /// Lighter gold tint for backgrounds
  static const Color goldLight = Color(0xFFF5E9A0);

  /// Muted Terra Cotta — secondary accent
  static const Color terraCotta = Color(0xFFB5614A);

  /// Deep Forest Green — used as accent on light surfaces
  static const Color forestGreen = Color(0xFF1A2F25);

  /// Price highlight — near-black, high contrast on cream
  static const Color emeraldGreen = Color(0xFF0A0A0A);

  // ── Material Palette ─────────────────────────────────────────────────────
  /// Brass warm tone
  static const Color brass = Color(0xFFB5A642);

  /// Copper warm tone
  static const Color copper = Color(0xFFB87333);

  // ── UI States ─────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF2E7D32);
  static const Color divider = Color(0xFFE0DDD5);

  // ── Glassmorphism ─────────────────────────────────────────────────────────
  static const Color glassWhite = Color(0x99FFFFFF);
  static const Color glassDark = Color(0x661A2F25);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF5E9A0), Color(0xFFD4AF37)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFFAFAF5), Color(0xFFF0EDE4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC1A2F25)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
