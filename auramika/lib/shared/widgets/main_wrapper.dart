import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import 'rive_animation_widget.dart';

/// AURAMIKA Main Shell Wrapper
///
/// Hosts the persistent [AuramikaBottomNav] and renders the active
/// branch child via [StatefulNavigationShell] (go_router ShellRoute).
class MainWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true, // body extends behind the floating nav
      body: navigationShell,
      bottomNavigationBar: AuramikaBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AURAMIKA Bottom Navigation Bar
// Design: Floating glassmorphism pill / bar
//   • Frosted glass background (BackdropFilter blur)
//   • Warm cream tint with subtle gold border
//   • Thin stroke icons — elegant minimalism
//   • Active: Forest Green icon + gold underline accent
//   • Center "Magic Mirror" AI button — gold gradient square
//   • Floats above content with rounded top corners
// ─────────────────────────────────────────────────────────────────────────────
class AuramikaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AuramikaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavDestination> _destinations = [
    _NavDestination(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      riveAsset: RiveAssets.navHome,
    ),
    _NavDestination(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Categories',
      riveAsset: RiveAssets.navShop,
    ),
    _NavDestination(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      label: 'Mirror',
      isCenter: true,
      riveAsset: RiveAssets.navMirror,
    ),
    _NavDestination(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
      label: 'Shop',
      riveAsset: RiveAssets.navShop,
    ),
    _NavDestination(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: 'Cart',
      riveAsset: RiveAssets.navCart,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navHeight = 64.0 + bottomPadding;

    return SizedBox(
      height: navHeight,
      child: Stack(
        children: [
          // ── Glass background ──────────────────────────────────────────
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.88),
                    border: const Border(
                      top: BorderSide(color: AppColors.divider, width: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Nav items ─────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 64,
            child: Row(
              children: List.generate(_destinations.length, (i) {
                final dest = _destinations[i];
                final isActive = i == currentIndex;

                if (dest.isCenter) {
                  return Expanded(
                    child: _MirrorNavButton(
                      isActive: isActive,
                      onTap: () => onTap(i),
                    ),
                  );
                }

                return Expanded(
                  child: _NavItem(
                    destination: dest,
                    isActive: isActive,
                    onTap: () => onTap(i),
                  ),
                );
              }),
            ),
          ),

          // ── Safe area padding ─────────────────────────────────────────
          if (bottomPadding > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: bottomPadding,
              child: Container(
                color: AppColors.background.withValues(alpha: 0.88),
              ),
            ),
        ],
      ),
    )
        .animate()
        .slideY(
          begin: 1,
          end: 0,
          duration: AppConstants.animSlow,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: AppConstants.animNormal);
  }
}

// ── Individual Nav Item ───────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final _NavDestination destination;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.destination,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? 0.88 : 1.0,
          duration: AppConstants.animFast,
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Rive Icon (falls back to Flutter Icon automatically) ──
              RiveNavIcon(
                riveAsset: widget.destination.riveAsset,
                isActive: widget.isActive,
                fallbackIcon: widget.destination.icon,
                fallbackActiveIcon: widget.destination.activeIcon,
                stateMachine: 'State Machine 1',
                triggerInput: 'press',
                size: 22,
              ),

              const SizedBox(height: 3),

              // ── Label ────────────────────────────────────────────────
              AnimatedDefaultTextStyle(
                duration: AppConstants.animFast,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  color: widget.isActive
                      ? AppColors.forestGreen
                      : AppColors.textMuted,
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w400,
                  letterSpacing: 0.5,
                ),
                child: Text(widget.destination.label),
              ),

              const SizedBox(height: 4),

              // ── Gold underline indicator ──────────────────────────────
              AnimatedContainer(
                duration: AppConstants.animFast,
                curve: Curves.easeOut,
                height: 2,
                width: widget.isActive ? 20 : 0,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

// ── Center "Magic Mirror" AI Button ──────────────────────────────────────────
class _MirrorNavButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _MirrorNavButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Gold gradient square button ─────────────────────────────────
          AnimatedContainer(
            duration: AppConstants.animNormal,
            curve: Curves.easeOutCubic,
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: isActive
                  ? AppColors.goldGradient
                  : const LinearGradient(
                      colors: [AppColors.forestGreen, Color(0xFF2A4A38)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? AppColors.gold.withValues(alpha: 0.35)
                      : AppColors.forestGreen.withValues(alpha: 0.25),
                  blurRadius: isActive ? 14 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                isActive ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                size: 20,
                color: AppColors.gold,
              ),
            ),
          ),

          const SizedBox(height: 2),

          // ── Label ──────────────────────────────────────────────────────
          AnimatedDefaultTextStyle(
            duration: AppConstants.animFast,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              color: isActive ? AppColors.gold : AppColors.textMuted,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              letterSpacing: 0.5,
            ),
            child: const Text('Mirror'),
          ),

          const SizedBox(height: 2),
        ],
      ),
    );
  }
}

// ── Nav Destination Data ──────────────────────────────────────────────────────
class _NavDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isCenter;
  final String riveAsset;

  const _NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.riveAsset,
    this.isCenter = false,
  });
}
