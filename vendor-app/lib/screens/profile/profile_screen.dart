import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/products_provider.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor = ref.watch(authProvider).value;
    final productsAsync = ref.watch(productsProvider);
    final ordersAsync = ref.watch(ordersProvider);
    final profileImage = useState<File?>(null);

    final productCount = productsAsync.value?.length ?? 0;
    final orderCount = ordersAsync.value?.length ?? 0;
    final activeOrders = ordersAsync.value
            ?.where((o) => ['paid', 'processing', 'shipped'].contains(o.status))
            .length ??
        0;

    Future<void> pickProfileImage() async {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) {
        profileImage.value = File(picked.path);
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                bottom: 32,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFC9A84C), Color(0xFFE8C97A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(children: [
                // Tappable avatar
                GestureDetector(
                  onTap: pickProfileImage,
                  child: Stack(alignment: Alignment.bottomRight, children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(120), width: 2.5),
                        image: profileImage.value != null
                            ? DecorationImage(
                                image: FileImage(profileImage.value!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: profileImage.value == null
                          ? const Icon(Icons.storefront_rounded, size: 38, color: Colors.white)
                          : null,
                    ),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppTheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                Text(
                  vendor?.name ?? 'My Shop',
                  style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    '@${vendor?.username ?? ''}',
                    style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(200)),
                  ),
                  if (vendor?.isVerified == true) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(children: [
                        Icon(Icons.verified_rounded, size: 11, color: Colors.white),
                        SizedBox(width: 3),
                        Text('Verified', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ],
                ]),
                const SizedBox(height: 20),
                // Stats row
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _StatPill(label: 'Products', value: productCount.toString()),
                  Container(width: 1, height: 28, color: Colors.white.withAlpha(60), margin: const EdgeInsets.symmetric(horizontal: 20)),
                  _StatPill(label: 'Orders', value: orderCount.toString()),
                  Container(width: 1, height: 28, color: Colors.white.withAlpha(60), margin: const EdgeInsets.symmetric(horizontal: 20)),
                  _StatPill(label: 'Active', value: activeOrders.toString()),
                ]),
              ]),
            ),
          ),

          // ── Quick Actions ─────────────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text('Quick Actions',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary, letterSpacing: 0.5)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _Card(children: [
                _ActionTile(
                  icon: Icons.inventory_2_outlined,
                  iconColor: AppTheme.primary,
                  label: 'My Products',
                  subtitle: '$productCount product${productCount != 1 ? 's' : ''}',
                  onTap: () => context.go('/products'),
                ),
                const _Divider(),
                _ActionTile(
                  icon: Icons.add_circle_outline_rounded,
                  iconColor: AppTheme.secondary,
                  label: 'Add New Product',
                  subtitle: 'List a new item for sale',
                  onTap: () => context.go('/products/new'),
                ),
                const _Divider(),
                _ActionTile(
                  icon: Icons.receipt_long_outlined,
                  iconColor: const Color(0xFF7B68EE),
                  label: 'My Orders',
                  subtitle: '$activeOrders active · $orderCount total',
                  onTap: () => context.go('/orders'),
                ),
              ]),
            ),
          ),

          // ── Shop Info ─────────────────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text('Shop Info',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary, letterSpacing: 0.5)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _Card(children: [
                _InfoTile(label: 'Shop Name', value: vendor?.name ?? '—'),
                const _Divider(),
                _InfoTile(label: 'Username', value: vendor?.username ?? '—'),
                if (vendor?.description != null && vendor!.description!.isNotEmpty) ...[
                  const _Divider(),
                  _InfoTile(label: 'Description', value: vendor.description!),
                ],
                const _Divider(),
                _InfoTile(
                  label: 'Rating',
                  value: vendor?.rating != null
                      ? '${vendor!.rating.toStringAsFixed(1)} ★'
                      : '—',
                ),
                const _Divider(),
                _InfoTile(
                  label: 'Status',
                  value: vendor?.isVerified == true ? 'Verified Vendor' : 'Pending Verification',
                  valueColor: vendor?.isVerified == true ? AppTheme.success : AppTheme.warning,
                ),
              ]),
            ),
          ),

          // ── Support & App ─────────────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text('Support',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary, letterSpacing: 0.5)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _Card(children: [
                _ActionTile(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppTheme.textSecondary,
                  label: 'Help & FAQs',
                  onTap: () {},
                ),
                const _Divider(),
                _ActionTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppTheme.textSecondary,
                  label: 'App Version',
                  trailing: const Text('1.0.0',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  onTap: null,
                ),
              ]),
            ),
          ),

          // ── Account ───────────────────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text('Account',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary, letterSpacing: 0.5)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
            sliver: SliverToBoxAdapter(
              child: _Card(children: [
                _ActionTile(
                  icon: Icons.logout_rounded,
                  iconColor: AppTheme.error,
                  label: 'Sign Out',
                  labelColor: AppTheme.error,
                  onTap: () => _confirmSignOut(context, ref),
                ),
                const _Divider(),
                _ActionTile(
                  icon: Icons.delete_forever_rounded,
                  iconColor: AppTheme.error,
                  label: 'Delete Account',
                  labelColor: AppTheme.error,
                  subtitle: 'Permanently remove your vendor account',
                  onTap: () => _confirmDeleteAccount(context, ref),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.error.withAlpha(18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Sign Out?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          const Text('You will need your credentials to sign back in.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).logout();
                },
                child: const Text('Sign Out'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.error.withAlpha(18),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_forever_rounded, color: AppTheme.error, size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Delete Account?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'This will permanently remove your vendor account, all products, and order history. This action cannot be undone.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warning.withAlpha(18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.warning.withAlpha(60)),
            ),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Contact Auramika admin to complete account deletion.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).logout();
                },
                child: const Text('Delete & Sign Out'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
    const SizedBox(height: 2),
    Text(label,
        style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(200), fontWeight: FontWeight.w500)),
  ]);
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border),
      boxShadow: AppTheme.cardShadow,
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Divider(
    height: 1, thickness: 1, color: AppTheme.border, indent: 56,
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.labelColor,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: iconColor.withAlpha(22),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: iconColor, size: 18),
    ),
    title: Text(label,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: labelColor ?? AppTheme.textPrimary)),
    subtitle: subtitle != null
        ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))
        : null,
    trailing: trailing ?? (onTap != null
        ? const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20)
        : null),
  );
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoTile({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
      const Spacer(),
      Text(value,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.textPrimary)),
    ]),
  );
}
