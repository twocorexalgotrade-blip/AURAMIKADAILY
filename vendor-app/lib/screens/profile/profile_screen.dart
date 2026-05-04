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

// Luxury palette — matches dashboard
const _black     = Color(0xFF0A0A0A);
const _gold      = Color(0xFFC9A84C);
const _goldLight = Color(0xFFE8C97A);
const _olive     = Color(0xFF6B7C3F);
const _sapphire  = Color(0xFF2D6B4A);

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendor        = ref.watch(authProvider).valueOrNull;
    final productsAsync = ref.watch(productsProvider);
    final ordersAsync   = ref.watch(ordersProvider);
    final profileImage  = useState<File?>(null);

    final productCount = productsAsync.valueOrNull?.length ?? 0;
    final orderCount   = ordersAsync.valueOrNull?.length ?? 0;
    final activeOrders = ordersAsync.valueOrNull
            ?.where((o) => ['paid', 'processing', 'shipped'].contains(o.status))
            .length ?? 0;

    Future<void> pickProfileImage() async {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked != null) profileImage.value = File(picked.path);
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Luxury Header ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF080808), Color(0xFF111A0E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(children: [
                  // Gold radial shimmer — top right
                  Positioned(
                    top: -40, right: -20,
                    child: Container(
                      width: 220, height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [_gold.withAlpha(35), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  // Sapphire radial shimmer — bottom left
                  Positioned(
                    bottom: -20, left: -10,
                    child: Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [_sapphire.withAlpha(45), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  // Gold bottom line
                  Positioned(
                    bottom: 0, left: 24, right: 24,
                    child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, _gold, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 24,
                      bottom: 36,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(children: [
                      // Avatar
                      GestureDetector(
                        onTap: pickProfileImage,
                        child: Stack(alignment: Alignment.bottomRight, children: [
                          Container(
                            width: 88, height: 88,
                            decoration: BoxDecoration(
                              color: _gold.withAlpha(22),
                              shape: BoxShape.circle,
                              border: Border.all(color: _gold.withAlpha(180), width: 2.5),
                              image: profileImage.value != null
                                  ? DecorationImage(
                                      image: FileImage(profileImage.value!),
                                      fit: BoxFit.cover)
                                  : null,
                            ),
                            child: profileImage.value == null
                                ? const Icon(Icons.storefront_rounded, size: 40, color: _goldLight)
                                : null,
                          ),
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: _olive,
                              shape: BoxShape.circle,
                              border: Border.all(color: _black, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        vendor?.name ?? 'My Shop',
                        style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          '@${vendor?.username ?? ''}',
                          style: const TextStyle(
                              fontSize: 13, color: _goldLight, fontWeight: FontWeight.w500),
                        ),
                        if (vendor?.isVerified == true) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _gold.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _gold.withAlpha(100)),
                            ),
                            child: const Row(children: [
                              Icon(Icons.verified_rounded, size: 11, color: _goldLight),
                              SizedBox(width: 3),
                              Text('Verified',
                                  style: TextStyle(
                                      fontSize: 10, color: _goldLight, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ],
                      ]),
                      const SizedBox(height: 24),
                      // Stats row
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _StatPill(label: 'Products', value: productCount.toString()),
                        Container(
                          width: 1, height: 30,
                          color: _gold.withAlpha(70),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        _StatPill(label: 'Orders', value: orderCount.toString()),
                        Container(
                          width: 1, height: 30,
                          color: _gold.withAlpha(70),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        _StatPill(label: 'Active', value: activeOrders.toString()),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ),
          ),

          // ── Quick Actions ────────────────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _SectionLabel('Quick Actions'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            sliver: SliverToBoxAdapter(
              child: _Card(children: [
                _ActionTile(
                  icon: Icons.inventory_2_outlined,
                  iconColor: _gold,
                  label: 'My Products',
                  subtitle: '$productCount product${productCount != 1 ? 's' : ''}',
                  onTap: () => context.go('/products'),
                ),
                const _Divider(),
                _ActionTile(
                  icon: Icons.add_circle_outline_rounded,
                  iconColor: _olive,
                  label: 'Add New Product',
                  subtitle: 'List a new item for sale',
                  onTap: () => context.go('/products/new'),
                ),
                const _Divider(),
                _ActionTile(
                  icon: Icons.receipt_long_outlined,
                  iconColor: _sapphire,
                  label: 'My Orders',
                  subtitle: '$activeOrders active · $orderCount total',
                  onTap: () => context.go('/orders'),
                ),
              ]),
            ),
          ),

          // ── Shop Info ────────────────────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(child: _SectionLabel('Shop Info')),
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
                  valueColor: vendor?.isVerified == true ? _olive : AppTheme.warning,
                ),
              ]),
            ),
          ),

          // ── Support ──────────────────────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(child: _SectionLabel('Support')),
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

          // ── Account ──────────────────────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(child: _SectionLabel('Account')),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_gold, _goldLight]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.error.withAlpha(18), shape: BoxShape.circle),
            child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Sign Out?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _black)),
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
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_gold, _goldLight]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.error.withAlpha(18), shape: BoxShape.circle),
            child: const Icon(Icons.delete_forever_rounded, color: AppTheme.error, size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Delete Account?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _black)),
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
        style: const TextStyle(fontSize: 11, color: _goldLight, fontWeight: FontWeight.w500)),
  ]);
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 3, height: 14,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(2)),
    ),
    Text(text,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: _gold, letterSpacing: 0.5)),
  ]);
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _gold.withAlpha(65)),
      boxShadow: [
        BoxShadow(color: _gold.withAlpha(16), blurRadius: 12, offset: const Offset(0, 3)),
        BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 4, offset: const Offset(0, 1)),
      ],
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Divider(
    height: 1, thickness: 1, color: _gold.withAlpha(40), indent: 56,
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
        border: Border.all(color: iconColor.withAlpha(45), width: 0.8),
      ),
      child: Icon(icon, color: iconColor, size: 18),
    ),
    title: Text(label,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: labelColor ?? _black)),
    subtitle: subtitle != null
        ? Text(subtitle!,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))
        : null,
    trailing: trailing ?? (onTap != null
        ? Icon(Icons.chevron_right_rounded, color: _gold.withAlpha(160), size: 20)
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
      Text(label,
          style: const TextStyle(
              fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
      const Spacer(),
      Text(value,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: valueColor ?? _black)),
    ]),
  );
}
