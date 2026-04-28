import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/home_models.dart';

/// "Shop the Vibe" Staggered Grid Section
///
/// Layout: 2-column staggered grid with alternating heights
///   Col 0: Old Money (tall 200) + Daily Minimalist (short 160)
///   Col 1: Street Wear (short 160) + Party/Glam (tall 200)
///
/// Each tile:
///   • Full-bleed color background with pattern
///   • Vibe title in Cinzel serif
///   • Descriptor text (e.g. "Pearls · Gold · Classic")
///   • Icon overlay
///   • Press scale animation
class VibeGridSection extends StatelessWidget {
  final ValueChanged<String>? onVibeTap;

  const VibeGridSection({super.key, this.onVibeTap});

  @override
  Widget build(BuildContext context) {
    final vibes = HomeData.vibeCategories;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Column 0: Old Money (tall) + Daily Minimalist (short) ────────
          Expanded(
            child: Column(
              children: [
                _VibeTile(
                  vibe: vibes[0], // Old Money
                  animIndex: 0,
                  onTap: () => onVibeTap?.call(vibes[0].id),
                ),
                const SizedBox(height: AppConstants.masonryMainAxisSpacing),
                _VibeTile(
                  vibe: vibes[2], // Daily Minimalist
                  animIndex: 2,
                  onTap: () => onVibeTap?.call(vibes[2].id),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppConstants.masonryCrossAxisSpacing),

          // ── Column 1: Street Wear (short) + Party/Glam (tall) ───────────
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 40), // stagger offset
                _VibeTile(
                  vibe: vibes[1], // Street Wear
                  animIndex: 1,
                  onTap: () => onVibeTap?.call(vibes[1].id),
                ),
                const SizedBox(height: AppConstants.masonryMainAxisSpacing),
                _VibeTile(
                  vibe: vibes[3], // Party / Glam
                  animIndex: 3,
                  onTap: () => onVibeTap?.call(vibes[3].id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual Vibe Tile ──────────────────────────────────────────────────────
class _VibeTile extends StatefulWidget {
  final VibeCategory vibe;
  final int animIndex;
  final VoidCallback? onTap;

  const _VibeTile({
    required this.vibe,
    required this.animIndex,
    this.onTap,
  });

  @override
  State<_VibeTile> createState() => _VibeTileState();
}

class _VibeTileState extends State<_VibeTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final vibe = widget.vibe;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: AppConstants.animFast,
        curve: Curves.easeOut,
        child: Container(
          height: vibe.gridHeight,
          decoration: BoxDecoration(
            color: vibe.primaryColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Photo background ──────────────────────────────────────
              if (vibe.imageUrl != null)
                CachedNetworkImage(
                  imageUrl: vibe.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: vibe.primaryColor),
                  errorWidget: (_, __, ___) => Container(color: vibe.primaryColor),
                )
              else
                Container(color: vibe.primaryColor),

              // ── Scrim: transparent at top so photo shows, dark at bottom for text
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      vibe.primaryColor.withValues(alpha: 0.45),
                      vibe.primaryColor.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),

              // ── Pattern overlay ───────────────────────────────────────
              CustomPaint(
                painter: _VibeTilePatternPainter(
                  accentColor: vibe.accentColor,
                ),
              ),

              // ── Large background icon ─────────────────────────────────
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  vibe.icon,
                  size: 80,
                  color: vibe.accentColor.withValues(alpha: 0.12),
                ),
              ),

              // ── Content ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Small icon
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: vibe.accentColor.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusXS),
                      ),
                      child: Icon(
                        vibe.icon,
                        size: 14,
                        color: vibe.accentColor,
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingS),

                    // Vibe title
                    Text(
                      vibe.title,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.white,
                        fontSize: 15,
                        letterSpacing: 0.3,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Descriptor
                    Text(
                      vibe.descriptor,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.6),
                        fontSize: 9,
                        letterSpacing: 1.0,
                      ),
                    ),

                    const SizedBox(height: AppConstants.paddingS),

                    // "Explore" — liquid glass chip
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: vibe.accentColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                            border: Border.all(
                              color: vibe.accentColor.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'EXPLORE',
                                style: AppTextStyles.categoryChip.copyWith(
                                  color: vibe.accentColor,
                                  fontSize: 8,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 10, color: vibe.accentColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.animIndex * 80))
        .fadeIn(duration: AppConstants.animNormal)
        .slideY(
          begin: 0.06,
          end: 0,
          duration: AppConstants.animNormal,
          curve: Curves.easeOutCubic,
        );
  }
}

// ── Vibe Tile Pattern Painter ─────────────────────────────────────────────────
class _VibeTilePatternPainter extends CustomPainter {
  final Color accentColor;
  const _VibeTilePatternPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 24.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VibeTilePatternPainter old) =>
      old.accentColor != accentColor;
}
