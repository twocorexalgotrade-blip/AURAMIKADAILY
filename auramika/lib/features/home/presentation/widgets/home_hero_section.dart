import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Full-screen editorial Hero Section
///
/// Simulates a video/image loop with:
///   • Animated gradient background cycling through brand colors
///   • "Redefine Elegance" headline in Cinzel serif
///   • Diagonal gold line pattern overlay
///   • Express delivery badge
///   • Scroll-down indicator
class HomeHeroSection extends StatefulWidget {
  final ValueChanged<Color>? onBgColorChanged;
  const HomeHeroSection({super.key, this.onBgColorChanged});

  @override
  State<HomeHeroSection> createState() => _HomeHeroSectionState();
}

class _HomeHeroSectionState extends State<HomeHeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gradientAnim;
  int _currentSlide = 0;

  static const List<_HeroSlide> _slides = [
    _HeroSlide(
      headline: 'Redefine\nElegance',
      subline: 'Gold · Silver · Diamond',
      tag: 'OLD MONEY',
      vibeId: 'old_money',
      bgColor: AppColors.forestGreen,
      accentColor: AppColors.gold,
      imageUrl: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=800&q=80',
    ),
    _HeroSlide(
      headline: 'Own The\nStreet',
      subline: 'Chunky · Edgy · Bold',
      tag: 'STREET WEAR',
      vibeId: 'street_wear',
      bgColor: Color(0xFF1A1A1A),
      accentColor: AppColors.terraCotta,
      imageUrl: 'https://images.unsplash.com/photo-1679973297332-cb76bf05275c?auto=format&fit=crop&w=800&h=1200&q=80',
    ),
    _HeroSlide(
      headline: 'Simply\nYou',
      subline: 'Office · College · Everyday',
      tag: 'MINIMALIST',
      vibeId: 'daily_minimalist',
      bgColor: AppColors.brass,
      accentColor: AppColors.goldLight,
      imageUrl: 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?auto=format&fit=crop&crop=entropy&w=800&h=1200&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _gradientAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Auto-advance slides
    Future.delayed(const Duration(seconds: 4), _nextSlide);
  }

  void _nextSlide() {
    if (!mounted) return;
    final next = (_currentSlide + 1) % _slides.length;
    setState(() => _currentSlide = next);
    widget.onBgColorChanged?.call(_slides[next].bgColor);
    Future.delayed(const Duration(seconds: 4), _nextSlide);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentSlide];
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.72,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Photo background ────────────────────────────────────────────
          AnimatedSwitcher(
            duration: AppConstants.animSlow,
            child: SizedBox.expand(
              key: ValueKey(_currentSlide),
              child: CachedNetworkImage(
                imageUrl: slide.imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                placeholder: (_, __) => Container(color: slide.bgColor),
                errorWidget: (_, __, ___) => Container(color: slide.bgColor),
              ),
            ),
          ),

          // ── Brand-color scrim so photo blends into editorial palette ────
          AnimatedContainer(
            duration: AppConstants.animVerySlow,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: slide.bgColor.withValues(alpha: 0.42),
            ),
          ),

          // ── Diagonal gold line pattern ──────────────────────────────────
          CustomPaint(
            painter: _HeroPatternPainter(accentColor: slide.accentColor),
          ),

          // ── Shimmer overlay (simulates video light play) ─────────────────
          AnimatedBuilder(
            animation: _gradientAnim,
            builder: (_, __) => Opacity(
              opacity: 0.06 + (_gradientAnim.value * 0.04),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      -0.3 + (_gradientAnim.value * 0.6),
                      -0.5,
                    ),
                    radius: 1.2,
                    colors: [slide.accentColor, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // ── Rive sparkle shimmer overlay ────────────────────────────────
          // const Positioned.fill(child: RiveHeroShimmer()),

          // ── Bottom dark gradient ────────────────────────────────────────
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xE6FAFAF5)],
                ),
              ),
            ),
          ),

          // ── Content — liquid glass panel ─────────────────────────────
          Positioned(
            left: AppConstants.paddingL,
            right: AppConstants.paddingL,
            bottom: AppConstants.paddingXXL,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.paddingM,
                    AppConstants.paddingM,
                    AppConstants.paddingM,
                    AppConstants.paddingM,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.12),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                // Vibe tag
                AnimatedSwitcher(
                  duration: AppConstants.animNormal,
                  child: _VibePill(
                    key: ValueKey('tag_$_currentSlide'),
                    label: slide.tag,
                    color: slide.accentColor,
                  ),
                ),

                const SizedBox(height: AppConstants.paddingM),

                // Main headline
                AnimatedSwitcher(
                  duration: AppConstants.animSlow,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Text(
                    slide.headline,
                    key: ValueKey('headline_$_currentSlide'),
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.white,
                      height: 1.05,
                      fontSize: 38,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingS),

                // Sub-line
                AnimatedSwitcher(
                  duration: AppConstants.animNormal,
                  child: Text(
                    slide.subline,
                    key: ValueKey('sub_$_currentSlide'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.6),
                      letterSpacing: 2.0,
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingL),

                // CTA row
                Row(
                  children: [
                    _HeroCTA(accentColor: slide.accentColor, vibeId: slide.vibeId),
                    const SizedBox(width: AppConstants.paddingM),
                    _ExpressHeroBadge(),
                  ],
                ),
              ],
            ),
                ),
              ),
            ),
          ),

          // ── Slide dots ──────────────────────────────────────────────────
          Positioned(
            right: AppConstants.paddingL,
            bottom: AppConstants.paddingXXL + 8,
            child: Column(
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: AppConstants.animFast,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  width: 2,
                  height: i == _currentSlide ? 20 : 8,
                  decoration: BoxDecoration(
                    color: i == _currentSlide
                        ? slide.accentColor
                        : AppColors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AppConstants.animSlow);
  }
}

// ── Vibe Pill ─────────────────────────────────────────────────────────────────
class _VibePill extends StatelessWidget {
  final String label;
  final Color color;

  const _VibePill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
      ),
      child: Text(
        label,
        style: AppTextStyles.categoryChip.copyWith(
          color: color,
          fontSize: 9,
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}

// ── Hero CTA Button ───────────────────────────────────────────────────────────
class _HeroCTA extends StatelessWidget {
  final Color accentColor;
  final String vibeId;
  const _HeroCTA({required this.accentColor, required this.vibeId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/style-vibe/$vibeId'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SHOP NOW',
              style: AppTextStyles.categoryChip.copyWith(
                color: AppColors.textPrimary,
                fontSize: 10,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 13,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Express Hero Badge ────────────────────────────────────────────────────────
class _ExpressHeroBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.gold, width: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 11, color: AppColors.gold),
          const SizedBox(width: 3),
          Text(
            '2 HR DELIVERY',
            style: AppTextStyles.expressBadge.copyWith(
              color: AppColors.gold,
              fontSize: 9,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Pattern Painter ──────────────────────────────────────────────────────
class _HeroPatternPainter extends CustomPainter {
  final Color accentColor;
  const _HeroPatternPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 32.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }

    // Horizontal lines (subtle grid)
    final hPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.03)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double y = 0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroPatternPainter old) =>
      old.accentColor != accentColor;
}

// ── Hero Slide Data ───────────────────────────────────────────────────────────
class _HeroSlide {
  final String headline;
  final String subline;
  final String tag;
  final String vibeId;
  final Color bgColor;
  final Color accentColor;
  final String imageUrl;

  const _HeroSlide({
    required this.headline,
    required this.subline,
    required this.tag,
    required this.vibeId,
    required this.bgColor,
    required this.accentColor,
    required this.imageUrl,
  });
}
