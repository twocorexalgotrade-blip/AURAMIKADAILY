import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Full-screen "going to Cashfree" launch screen.
///
/// Shown the moment the user taps PAY and stays up until either the Cashfree
/// SDK takes over or an error fires. Five layered animations on top of a
/// radial gradient — rotating gold rings, orbiting sparkles, drifting dust
/// particles, cross-fading status text, and a shimmering trust badge.
class PaymentLaunchOverlay extends StatefulWidget {
  /// Total in INR — shown front and center so the user knows what they're
  /// about to pay before Cashfree takes over.
  final double total;

  const PaymentLaunchOverlay({super.key, required this.total});

  @override
  State<PaymentLaunchOverlay> createState() => _PaymentLaunchOverlayState();
}

class _PaymentLaunchOverlayState extends State<PaymentLaunchOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _ringCtrl;
  late final AnimationController _orbitCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _dustCtrl;

  // Status messages cross-fade through these as we wait.
  static const _statuses = <String>[
    'VERIFYING ORDER',
    'CONNECTING TO PAYMENT GATEWAY',
    'SECURING PAYMENT SESSION',
    'OPENING CHECKOUT',
  ];
  int _statusIndex = 0;

  @override
  void initState() {
    super.initState();
    _ringCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _orbitCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);
    _dustCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

    // Cycle status text every 1.2s; clamps at the last message until parent
    // dismisses the overlay.
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return false;
      if (_statusIndex < _statuses.length - 1) {
        setState(() => _statusIndex += 1);
      }
      return mounted;
    });
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    _dustCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: radial gradient backdrop ──────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.1,
                colors: [
                  Color(0xFF1A2F25), // forest green core
                  Color(0xFF0A0A0A), // near-black edge
                ],
                stops: [0.0, 1.0],
              ),
            ),
          ),

          // ── Layer 2: drifting gold dust particles ──────────────────────
          AnimatedBuilder(
            animation: _dustCtrl,
            builder: (_, __) => CustomPaint(
              painter: _DustPainter(progress: _dustCtrl.value),
              size: Size.infinite,
            ),
          ),

          // ── Layer 3: brand mark top ────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 32,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'AURAMIKA',
                style: AppTextStyles.categoryChip.copyWith(
                  color: AppColors.gold,
                  fontSize: 14,
                  letterSpacing: 6.0,
                  fontWeight: FontWeight.w400,
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: 2500.ms,
                color: AppColors.goldLight,
                size: 0.6,
              ),
            ),
          ),

          // ── Layer 4: center ring stack ─────────────────────────────────
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating gold ring
                  AnimatedBuilder(
                    animation: _ringCtrl,
                    builder: (_, __) => Transform.rotate(
                      angle: _ringCtrl.value * 2 * math.pi,
                      child: CustomPaint(
                        painter: _ArcPainter(color: AppColors.gold,        sweep: 1.4, strokeWidth: 2.0),
                        size: const Size(220, 220),
                      ),
                    ),
                  ),
                  // Middle counter-rotating ring
                  AnimatedBuilder(
                    animation: _ringCtrl,
                    builder: (_, __) => Transform.rotate(
                      angle: -_ringCtrl.value * 2 * math.pi * 1.6,
                      child: CustomPaint(
                        painter: _ArcPainter(color: AppColors.goldLight,   sweep: 0.8, strokeWidth: 1.2),
                        size: const Size(170, 170),
                      ),
                    ),
                  ),
                  // Inner thin ring
                  AnimatedBuilder(
                    animation: _ringCtrl,
                    builder: (_, __) => Transform.rotate(
                      angle: _ringCtrl.value * 2 * math.pi * 2.4,
                      child: CustomPaint(
                        painter: _ArcPainter(color: AppColors.gold.withValues(alpha: 0.5), sweep: 2.6, strokeWidth: 0.8),
                        size: const Size(130, 130),
                      ),
                    ),
                  ),
                  // Orbiting particle dots
                  AnimatedBuilder(
                    animation: _orbitCtrl,
                    builder: (_, __) => CustomPaint(
                      painter: _OrbitPainter(progress: _orbitCtrl.value),
                      size: const Size(220, 220),
                    ),
                  ),
                  // Pulsing center: lotus icon + total
                  AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, child) => Transform.scale(
                      scale: 0.92 + 0.08 * _pulseCtrl.value,
                      child: child,
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.gold.withValues(alpha: 0.25),
                            AppColors.gold.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_rounded, size: 22, color: AppColors.gold),
                            const SizedBox(height: 4),
                            Text(
                              '₹${widget.total.toInt()}',
                              style: AppTextStyles.priceTag.copyWith(
                                color: AppColors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Layer 5: status cross-fade + progress dots ─────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                32, 0, 32, MediaQuery.of(context).padding.bottom + 60,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (c, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(anim),
                        child: c,
                      ),
                    ),
                    child: Text(
                      _statuses[_statusIndex],
                      key: ValueKey(_statusIndex),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.categoryChip.copyWith(
                        color: AppColors.white,
                        fontSize: 11,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_statuses.length, (i) {
                      final reached = i <= _statusIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: reached ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: reached
                              ? AppColors.gold
                              : AppColors.gold.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  // Trust badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 12,
                        color: AppColors.gold.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '256-BIT SSL · POWERED BY CASHFREE',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white.withValues(alpha: 0.4),
                          fontSize: 9,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ).animate(onPlay: (c) => c.repeat()).shimmer(
                    duration: 3000.ms,
                    color: AppColors.gold.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 280.ms);
  }
}

// ── Painters ────────────────────────────────────────────────────────────────

/// A partial circle arc — multiple of these stacked at different speeds gives
/// the whirling-gold-ring look.
class _ArcPainter extends CustomPainter {
  final Color color;
  final double sweep; // radians
  final double strokeWidth;
  _ArcPainter({required this.color, required this.sweep, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final rect = Offset.zero & size;
    canvas.drawArc(rect.deflate(strokeWidth / 2), 0, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.color != color || old.sweep != sweep || old.strokeWidth != strokeWidth;
}

/// Six gold particles orbiting the center at varying radii and angular
/// offsets, each with a glowing halo.
class _OrbitPainter extends CustomPainter {
  final double progress;
  _OrbitPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const particles = 6;
    for (var i = 0; i < particles; i++) {
      final t       = (progress + i / particles) % 1.0;
      final angle   = t * 2 * math.pi;
      final radius  = 95.0 + (math.sin(t * math.pi * 2) * 8);
      final pos     = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      final size    = 3.0 + math.sin(t * math.pi * 2) * 1.5;

      // halo
      canvas.drawCircle(
        pos,
        size * 3,
        Paint()..color = const Color(0xFFD4AF37).withValues(alpha: 0.18),
      );
      // core
      canvas.drawCircle(
        pos,
        size,
        Paint()..color = const Color(0xFFF5E9A0),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter old) => old.progress != progress;
}

/// Tiny gold dust specks drifting upward — adds atmosphere to the backdrop.
class _DustPainter extends CustomPainter {
  final double progress;
  static final List<_DustParticle> _particles = List.generate(40, (_) => _DustParticle.random());
  _DustPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in _particles) {
      final yOffset = (p.y - progress * p.speed) % 1.0;
      final pos = Offset(p.x * size.width, yOffset * size.height);
      paint.color = const Color(0xFFD4AF37).withValues(alpha: p.alpha);
      canvas.drawCircle(pos, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter old) => old.progress != progress;
}

class _DustParticle {
  final double x, y, radius, alpha, speed;
  _DustParticle(this.x, this.y, this.radius, this.alpha, this.speed);
  factory _DustParticle.random() {
    final rng = math.Random();
    return _DustParticle(
      rng.nextDouble(),
      rng.nextDouble(),
      0.5 + rng.nextDouble() * 1.4,
      0.08 + rng.nextDouble() * 0.20,
      0.5  + rng.nextDouble() * 1.5,
    );
  }
}
