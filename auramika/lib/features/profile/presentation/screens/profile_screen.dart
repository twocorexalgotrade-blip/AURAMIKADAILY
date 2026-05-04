import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/domain/auth_controller.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../domain/user_profile_controller.dart';
import '../../domain/wishlist_controller.dart';
import 'profile_details_screen.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'refunds_screen.dart';
import 'transactions_screen.dart';
import 'gift_cards_screen.dart';
import 'rate_review_screen.dart';
import 'help_screen.dart';
import 'terms_conditions_screen.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final wishlistCount = ref.watch(wishlistProvider).items.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'Me',
        showSearch: false,
        showCart: false,
        showBack: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Profile Header ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHeader(),
          ),

          // ── Menu Items ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingM,
                AppConstants.paddingS,
                AppConstants.paddingM,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACCOUNT',
                    style: AppTextStyles.categoryChip.copyWith(
                      fontSize: 10,
                      letterSpacing: 3.0,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Profile Details',
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const ProfileDetailsScreen(),
                        )),
                      ),
                      _MenuItem(
                        icon: Icons.receipt_long_outlined,
                        label: 'Orders',
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const OrdersScreen(),
                        )),
                      ),
                      _MenuItem(
                        icon: Icons.favorite_border_rounded,
                        label: 'Wishlist',
                        badge: wishlistCount > 0 ? '$wishlistCount' : null,
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const WishlistScreen(),
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Text(
                    'PAYMENTS',
                    style: AppTextStyles.categoryChip.copyWith(
                      fontSize: 10,
                      letterSpacing: 3.0,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.replay_rounded,
                        label: 'Refunds',
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const RefundsScreen(),
                        )),
                      ),
                      _MenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Transactions',
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const TransactionsScreen(),
                        )),
                      ),
                      _MenuItem(
                        icon: Icons.card_giftcard_outlined,
                        label: 'Gift Cards',
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const GiftCardsScreen(),
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Text(
                    'MORE',
                    style: AppTextStyles.categoryChip.copyWith(
                      fontSize: 10,
                      letterSpacing: 3.0,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.star_border_rounded,
                        label: 'Rate & Review',
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const RateReviewScreen(),
                        )),
                      ),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help',
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const HelpScreen(),
                        )),
                      ),
                      _MenuItem(
                        icon: Icons.smart_toy_outlined,
                        label: 'AI Stylist Settings',
                        onTap: () => _showAiConsentDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Text(
                    'LEGAL',
                    style: AppTextStyles.categoryChip.copyWith(
                      fontSize: 10,
                      letterSpacing: 3.0,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.gavel_rounded,
                        label: 'Terms & Conditions',
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const TermsConditionsScreen(),
                        )),
                      ),
                      _MenuItem(
                        icon: Icons.description_outlined,
                        label: 'Terms of Service',
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const TermsOfServiceScreen(),
                        )),
                      ),
                      _MenuItem(
                        icon: Icons.shield_outlined,
                        label: 'Privacy Policy',
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        )),
                      ),
                      _MenuItem(
                        icon: Icons.replay_rounded,
                        label: 'Refund Policy',
                        onTap: () async {
                          final uri = Uri.parse(AppConstants.urlRefundPolicy);
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                      ),
                      _MenuItem(
                        icon: Icons.local_shipping_outlined,
                        label: 'Shipping Policy',
                        onTap: () async {
                          final uri = Uri.parse(AppConstants.urlShippingPolicy);
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingXL),

                  // Sign Out + Delete only shown when logged in
                  if (auth.isLoggedIn) GestureDetector(
                    onTap: () => _confirmSignOut(context, ref),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.terraCotta.withValues(alpha: 0.4),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded,
                              color: AppColors.terraCotta, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'SIGN OUT',
                            style: AppTextStyles.categoryChip.copyWith(
                              color: AppColors.terraCotta,
                              fontSize: 11,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (auth.isLoggedIn) const SizedBox(height: AppConstants.paddingM),

                  if (auth.isLoggedIn) GestureDetector(
                    onTap: () => _confirmDeleteAccount(context, ref),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.05),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.25),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_forever_outlined,
                              color: AppColors.error.withValues(alpha: 0.8), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'DELETE ACCOUNT',
                            style: AppTextStyles.categoryChip.copyWith(
                              color: AppColors.error.withValues(alpha: 0.8),
                              fontSize: 11,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: AppConstants.animNormal),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        var deleting = false;
        return StatefulBuilder(
          builder: (ctx, setLocalState) => AlertDialog(
            backgroundColor: AppColors.background,
            title: Text('Delete account?', style: AppTextStyles.titleMedium),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will permanently delete your ${AppConstants.appName} account and all associated data — orders, addresses, wishlist, cart. This action cannot be undone.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                if (deleting) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.error),
                      ),
                      const SizedBox(width: 10),
                      Text('Deleting account…',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: deleting ? null : () => Navigator.pop(dialogContext),
                child: Text('Cancel',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
              ),
              TextButton(
                onPressed: deleting ? null : () async {
                  setLocalState(() => deleting = true);
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    Navigator.pop(dialogContext);
                    if (context.mounted) context.go('/auth/register');
                    return;
                  }
                  try {
                    final token = await user.getIdToken();
                    await Dio().delete(
                      '${AppConstants.baseUrl}/api/v1/auth/account',
                      options: Options(
                        headers: {'Authorization': 'Bearer $token'},
                        receiveTimeout: const Duration(seconds: 15),
                      ),
                    );
                  } on DioException catch (e) {
                    if (!ctx.mounted) return;
                    Navigator.pop(dialogContext);
                    final body = e.response?.data;
                    final msg = (body is Map && body['error'] is String)
                        ? body['error'] as String
                        : 'Could not delete account. Please check your connection and try again.';
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(msg),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 5),
                      ));
                    }
                    return;
                  } catch (_) {
                    if (!ctx.mounted) return;
                    Navigator.pop(dialogContext);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Could not reach the server. Please try again.'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                    return;
                  }

                  // Backend confirmed deletion — purge all local state.
                  await FirebaseAuth.instance.signOut().catchError((_) {});
                  ref.read(authProvider.notifier).logout();
                  ref.read(userProfileProvider.notifier).reset();
                  ref.read(cartProvider.notifier).clear();
                  ref.read(wishlistProvider.notifier).clear();

                  if (!ctx.mounted) return;
                  Navigator.pop(dialogContext);
                  if (context.mounted) context.go('/auth/register');
                },
                child: Text('Delete',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAiConsentDialog(BuildContext context) {
    final box = Hive.box('profile');
    final consentGiven = box.get('aiStylistConsent', defaultValue: false) as bool;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('AI Stylist Settings', style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${consentGiven ? 'Consent active' : 'No consent given'}',
              style: AppTextStyles.bodySmall.copyWith(
                color: consentGiven ? AppColors.forestGreen : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'When you use the Magic Mirror feature, your outfit photo is sent to our AI styling service for jewellery matching. You can withdraw consent at any time — you will be asked again on next use.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          ),
          if (consentGiven)
            TextButton(
              onPressed: () {
                box.put('aiStylistConsent', false);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('AI consent withdrawn. You will be asked again next time.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
                    backgroundColor: AppColors.forestGreen,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              child: Text('Withdraw Consent',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.terraCotta)),
            ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('Sign out?', style: AppTextStyles.titleMedium),
        content: Text(
          'You will be signed out of your ${AppConstants.appName} account.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              ref.read(userProfileProvider.notifier).reset();
              ref.read(cartProvider.notifier).clear();
              ref.read(wishlistProvider.notifier).clear();
              context.go('/');
            },
            child: Text('Sign Out',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.terraCotta)),
          ),
        ],
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────
class _ProfileHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final profile = ref.watch(userProfileProvider);

    if (!auth.isLoggedIn) {
      return Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: AppColors.divider, width: 0.8),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.forestGreen.withValues(alpha: 0.08),
                      border: Border.all(
                        color: AppColors.forestGreen.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 30,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  Text(
                    'Sign in to AURAMIKA',
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: AppConstants.paddingS),
                  Text(
                    'View orders, wishlist & manage your profile.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.paddingL),
                  GestureDetector(
                    onTap: () => context.push('/auth/login',
                        extra: {'redirect': '/profile'}),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen,
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.login_rounded, size: 15, color: AppColors.gold),
                          const SizedBox(width: AppConstants.paddingS),
                          Text(
                            'SIGN IN',
                            style: AppTextStyles.categoryChip.copyWith(
                              color: AppColors.white,
                              fontSize: 11,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingM),
                  GestureDetector(
                    onTap: () => context.push('/auth/register',
                        extra: {'redirect': '/profile'}),
                    child: Text.rich(
                      TextSpan(
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        children: const [
                          TextSpan(
                            text: 'New to AURAMIKA?  ',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          TextSpan(
                            text: 'Create Account',
                            style: TextStyle(
                              color: AppColors.forestGreen,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.forestGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: AppConstants.animNormal);
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => const ProfileDetailsScreen(),
      )),
      child: Container(
        margin: const EdgeInsets.all(AppConstants.paddingM),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.forestGreen,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.2),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
              ),
              child: const Center(
                child: Icon(Icons.person_rounded, size: 30, color: AppColors.gold),
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name.isNotEmpty ? profile.name : 'Add your name',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: profile.name.isNotEmpty
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                      fontStyle: profile.name.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    profile.phone.isNotEmpty ? profile.phone : 'Tap to complete profile',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (profile.email.isNotEmpty)
                    Text(
                      profile.email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: AppColors.gold, size: 18),
          ],
        ),
      ),
    ).animate().fadeIn(duration: AppConstants.animNormal).slideY(begin: -0.05, end: 0);
  }
}

// ── Menu Card ─────────────────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              _MenuTile(item: item),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  indent: 48,
                  color: AppColors.divider,
                  thickness: 0.5,
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Menu Tile ─────────────────────────────────────────────────────────────────
class _MenuTile extends StatefulWidget {
  final _MenuItem item;
  const _MenuTile({required this.item});

  @override
  State<_MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<_MenuTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.item.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        color: _pressed
            ? AppColors.forestGreen.withValues(alpha: 0.04)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(widget.item.icon, size: 20, color: AppColors.forestGreen),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Text(
                widget.item.label,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
              ),
            ),
            if (widget.item.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.item.badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });
}
