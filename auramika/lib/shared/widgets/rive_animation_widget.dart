import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../core/constants/app_colors.dart';

// ── Rive Asset Paths ──────────────────────────────────────────────────────────
/// Central registry of all Rive animation asset paths.
/// When real .riv files are dropped into assets/animations/, only these
/// constants need updating — all widgets pick up the change automatically.
class RiveAssets {
  RiveAssets._();

  // Bottom Nav
  static const navHome    = 'assets/animations/nav_home.riv';
  static const navShop    = 'assets/animations/nav_shop.riv';
  static const navMirror  = 'assets/animations/nav_mirror.riv';
  static const navCart    = 'assets/animations/nav_cart.riv';
  static const navProfile = 'assets/animations/nav_profile.riv';

  // Feature animations
  static const sparkleBurst = 'assets/animations/sparkle_burst.riv';
  static const scanBeam     = 'assets/animations/scan_beam.riv';
  static const successTick  = 'assets/animations/success_tick.riv';
  static const heroShimmer  = 'assets/animations/hero_shimmer.riv';
  static const loadingRing  = 'assets/animations/loading_ring.riv';
}

// ── RiveAnimationWidget ───────────────────────────────────────────────────────
/// A robust Rive player that:
///   • Loads a .riv asset by path
///   • Optionally drives a named state machine or simple animation
///   • Falls back gracefully to [fallback] if the file fails to load
///   • Exposes [onInit] so callers can grab the [StateMachineController]
///
/// Usage:
/// ```dart
/// RiveAnimationWidget(
///   asset: RiveAssets.successTick,
///   stateMachine: 'State Machine 1',
///   fit: BoxFit.contain,
///   fallback: Icon(Icons.check_circle, color: AppColors.gold),
///   onInit: (artboard) {
///     final ctrl = StateMachineController.fromArtboard(artboard, 'State Machine 1');
///     if (ctrl != null) artboard.addController(ctrl);
///   },
/// )
/// ```
class RiveAnimationWidget extends StatefulWidget {
  final String asset;
  final String? animationName;
  final String? stateMachine;
  final BoxFit fit;
  final Alignment alignment;
  final Widget? fallback;
  final void Function(Artboard)? onInit;
  final bool autoplay;

  const RiveAnimationWidget({
    super.key,
    required this.asset,
    this.animationName,
    this.stateMachine,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.fallback,
    this.onInit,
    this.autoplay = true,
  });

  @override
  State<RiveAnimationWidget> createState() => _RiveAnimationWidgetState();
}

class _RiveAnimationWidgetState extends State<RiveAnimationWidget> {
  Artboard? _artboard;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadRive();
  }

  Future<void> _loadRive() async {
    try {
      final file = await RiveFile.asset(widget.asset);
      final artboard = file.mainArtboard;

      // Attach state machine if specified
      if (widget.stateMachine != null) {
        final ctrl = StateMachineController.fromArtboard(
          artboard,
          widget.stateMachine!,
        );
        if (ctrl != null) artboard.addController(ctrl);
      } else if (widget.animationName != null) {
        // Named simple animation
        final ctrl = SimpleAnimation(widget.animationName!, autoplay: widget.autoplay);
        artboard.addController(ctrl);
      } else if (widget.autoplay) {
        // Default: play first animation
        artboard.addController(SimpleAnimation('idle', autoplay: true));
      }

      widget.onInit?.call(artboard);

      if (mounted) setState(() => _artboard = artboard);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error || (_artboard == null && widget.fallback != null)) {
      // Show fallback while loading OR on error
      if (_artboard == null) {
        return widget.fallback ?? const SizedBox.shrink();
      }
    }

    if (_artboard == null) return const SizedBox.shrink();

    return Rive(
      artboard: _artboard!,
      fit: widget.fit,
      alignment: widget.alignment,
    );
  }
}

// ── RiveNavIcon ───────────────────────────────────────────────────────────────
/// Specialized Rive widget for bottom nav icons.
/// Shows a Rive animation when active, falls back to a Flutter [Icon] always.
/// When real nav .riv files are available, the Rive layer renders on top.
class RiveNavIcon extends StatefulWidget {
  final String riveAsset;
  final String? stateMachine;
  final String? triggerInput;   // input name to fire on activation
  final bool isActive;
  final IconData fallbackIcon;
  final IconData fallbackActiveIcon;
  final double size;

  const RiveNavIcon({
    super.key,
    required this.riveAsset,
    required this.isActive,
    required this.fallbackIcon,
    required this.fallbackActiveIcon,
    this.stateMachine,
    this.triggerInput,
    this.size = 22,
  });

  @override
  State<RiveNavIcon> createState() => _RiveNavIconState();
}

class _RiveNavIconState extends State<RiveNavIcon> {
  Artboard? _artboard;
  SMIBool? _activeInput;
  SMITrigger? _triggerInput;

  @override
  void initState() {
    super.initState();
    _loadRive();
  }

  @override
  void didUpdateWidget(RiveNavIcon old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive) {
      _activeInput?.value = widget.isActive;
      if (widget.isActive) _triggerInput?.fire();
    }
  }

  Future<void> _loadRive() async {
    try {
      final file = await RiveFile.asset(widget.riveAsset);
      final artboard = file.mainArtboard;

      if (widget.stateMachine != null) {
        final ctrl = StateMachineController.fromArtboard(
          artboard,
          widget.stateMachine!,
        );
        if (ctrl != null) {
          artboard.addController(ctrl);
          // Look for boolean "active" input
          try {
            _activeInput = ctrl.findInput<bool>('active') as SMIBool?;
            _activeInput?.value = widget.isActive;
          } catch (_) {}
          // Look for trigger input
          if (widget.triggerInput != null) {
            try {
              _triggerInput = ctrl.findInput<bool>(widget.triggerInput!) as SMITrigger?;
            } catch (_) {}
          }
        }
      } else {
        artboard.addController(SimpleAnimation('idle', autoplay: true));
      }

      if (mounted) setState(() => _artboard = artboard);
    } catch (_) {
      // Silently fall back to Flutter icon
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always show Flutter icon as base layer
    final icon = Icon(
      widget.isActive ? widget.fallbackActiveIcon : widget.fallbackIcon,
      size: widget.size,
      color: widget.isActive ? AppColors.forestGreen : AppColors.textMuted,
    );

    if (_artboard == null) return icon;

    // Overlay Rive on top of icon (Rive replaces icon when loaded)
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Rive(
        artboard: _artboard!,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ── RiveSparkle ───────────────────────────────────────────────────────────────
/// One-shot sparkle burst — plays once then disappears.
/// Used on: add-to-cart, product card tap, success states.
class RiveSparkle extends StatefulWidget {
  final double size;
  final VoidCallback? onComplete;

  const RiveSparkle({super.key, this.size = 60, this.onComplete});

  @override
  State<RiveSparkle> createState() => _RiveSparkleState();
}

class _RiveSparkleState extends State<RiveSparkle> {
  Artboard? _artboard;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await RiveFile.asset(RiveAssets.sparkleBurst);
      final artboard = file.mainArtboard;
      final ctrl = SimpleAnimation('burst', autoplay: true);
      ctrl.isActiveChanged.addListener(() {
        if (!ctrl.isActive) widget.onComplete?.call();
      });
      artboard.addController(ctrl);
      if (mounted) setState(() => _artboard = artboard);
    } catch (_) {
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard == null) return SizedBox(width: widget.size, height: widget.size);
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Rive(artboard: _artboard!, fit: BoxFit.contain),
    );
  }
}

// ── RiveLoadingRing ───────────────────────────────────────────────────────────
/// Looping gold loading ring — used in scan overlay and loading states.
class RiveLoadingRing extends StatefulWidget {
  final double size;
  final Color color;

  const RiveLoadingRing({
    super.key,
    this.size = 48,
    this.color = AppColors.gold,
  });

  @override
  State<RiveLoadingRing> createState() => _RiveLoadingRingState();
}

class _RiveLoadingRingState extends State<RiveLoadingRing>
    with SingleTickerProviderStateMixin {
  Artboard? _artboard;
  late AnimationController _fallbackCtrl;

  @override
  void initState() {
    super.initState();
    _fallbackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _load();
  }

  @override
  void dispose() {
    _fallbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final file = await RiveFile.asset(RiveAssets.loadingRing);
      final artboard = file.mainArtboard;
      artboard.addController(SimpleAnimation('spin', autoplay: true));
      if (mounted) setState(() => _artboard = artboard);
    } catch (_) {
      // Use Flutter fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard != null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Rive(artboard: _artboard!, fit: BoxFit.contain),
      );
    }

    // Fallback: animated gold ring
    return AnimatedBuilder(
      animation: _fallbackCtrl,
      builder: (_, __) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          value: null,
          strokeWidth: 1.5,
          color: widget.color,
        ),
      ),
    );
  }
}

// ── RiveSuccessTick ───────────────────────────────────────────────────────────
/// Animated gold tick — plays once on success screens.
class RiveSuccessTick extends StatefulWidget {
  final double size;
  final AnimationController? fallbackController;

  const RiveSuccessTick({
    super.key,
    this.size = 88,
    this.fallbackController,
  });

  @override
  State<RiveSuccessTick> createState() => _RiveSuccessTickState();
}

class _RiveSuccessTickState extends State<RiveSuccessTick> {
  Artboard? _artboard;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await RiveFile.asset(RiveAssets.successTick);
      final artboard = file.mainArtboard;
      final ctrl = StateMachineController.fromArtboard(artboard, 'State Machine 1');
      if (ctrl != null) {
        artboard.addController(ctrl);
        final trigger = ctrl.findInput<bool>('play') as SMITrigger?;
        trigger?.fire();
      } else {
        artboard.addController(SimpleAnimation('success', autoplay: true));
      }
      if (mounted) setState(() => _artboard = artboard);
    } catch (_) {
      // Use Flutter fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard != null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Rive(artboard: _artboard!, fit: BoxFit.contain),
      );
    }

    // Flutter fallback: gold tick circle (same as before, but now driven by Rive when available)
    final ctrl = widget.fallbackController;
    if (ctrl != null) {
      return AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) => Transform.scale(
          scale: Curves.easeOutBack.transform(ctrl.value.clamp(0.0, 1.0)),
          child: _TickCircle(size: widget.size),
        ),
      );
    }
    return _TickCircle(size: widget.size);
  }
}

class _TickCircle extends StatelessWidget {
  final double size;
  const _TickCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gold.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: const Icon(Icons.check_rounded, color: AppColors.gold, size: 44),
    );
  }
}

// ── RiveHeroShimmer ───────────────────────────────────────────────────────────
/// Looping shimmer/sparkle overlay for the home hero section.
/// Renders as a transparent overlay on top of the hero image.
class RiveHeroShimmer extends StatefulWidget {
  const RiveHeroShimmer({super.key});

  @override
  State<RiveHeroShimmer> createState() => _RiveHeroShimmerState();
}

class _RiveHeroShimmerState extends State<RiveHeroShimmer> {
  Artboard? _artboard;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await RiveFile.asset(RiveAssets.heroShimmer);
      final artboard = file.mainArtboard;
      artboard.addController(SimpleAnimation('shimmer', autoplay: true));
      if (mounted) setState(() => _artboard = artboard);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard == null) return const SizedBox.shrink();
    return Rive(
      artboard: _artboard!,
      fit: BoxFit.cover,
    );
  }
}

// ── RiveScanBeam ──────────────────────────────────────────────────────────────
/// Animated scan beam for the Magic Mirror scanning state.
/// Replaces the manual AnimatedBuilder scan line with a Rive animation.
class RiveScanBeam extends StatefulWidget {
  const RiveScanBeam({super.key});

  @override
  State<RiveScanBeam> createState() => _RiveScanBeamState();
}

class _RiveScanBeamState extends State<RiveScanBeam> {
  Artboard? _artboard;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final file = await RiveFile.asset(RiveAssets.scanBeam);
      final artboard = file.mainArtboard;
      artboard.addController(SimpleAnimation('scan', autoplay: true));
      if (mounted) setState(() => _artboard = artboard);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard == null) return const SizedBox.shrink();
    return Rive(
      artboard: _artboard!,
      fit: BoxFit.fill,
    );
  }
}
