import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/auramika_app_bar.dart';
import '../../domain/user_profile_controller.dart';

class ProfileDetailsScreen extends ConsumerStatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  ConsumerState<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends ConsumerState<ProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _dobCtrl;
  bool _saving = false;
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameCtrl  = TextEditingController(text: profile.name);
    _emailCtrl = TextEditingController(text: profile.email);
    _phoneCtrl = TextEditingController(text: profile.phone);
    _dobCtrl   = TextEditingController(text: profile.dob);
    _imagePath = profile.imagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // close bottom sheet
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 600,
    );
    if (picked == null) return;
    setState(() => _imagePath = picked.path);
    // Persist immediately
    ref.read(userProfileProvider.notifier).update(imagePath: picked.path);
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Profile Photo',
              style: AppTextStyles.titleSmall.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.forestGreen),
              title: Text('Choose from Gallery',
                  style: AppTextStyles.bodyMedium),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.forestGreen),
              title: Text('Take a Photo', style: AppTextStyles.bodyMedium),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            if (_imagePath.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.error),
                title: Text('Remove Photo',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _imagePath = '');
                  ref
                      .read(userProfileProvider.notifier)
                      .update(imagePath: '');
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    ref.read(userProfileProvider.notifier).update(
      name:      _nameCtrl.text.trim(),
      email:     _emailCtrl.text.trim(),
      phone:     _phoneCtrl.text.trim(),
      dob:       _dobCtrl.text.trim(),
      imagePath: _imagePath,
    );
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)),
        backgroundColor: AppColors.forestGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXS)),
      ),
    );
  }

  void _showAddressForm({Address? existing, int? index}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddressFormSheet(
        existing: existing,
        onSave: (addr) {
          if (existing != null && index != null) {
            ref.read(userProfileProvider.notifier).updateAddress(index, addr);
          } else {
            ref.read(userProfileProvider.notifier).addAddress(addr);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AuramikaAppBar(
        showLogo: false,
        title: 'Profile Details',
        showSearch: false,
        showCart: false,
        showBack: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          children: [
            // ── Avatar ───────────────────────────────────────────────────
            Center(
              child: GestureDetector(
                onTap: _showImageOptions,
                child: Stack(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.goldLight,
                        border: Border.all(color: AppColors.gold, width: 1.5),
                        image: _imagePath.isNotEmpty
                            ? DecorationImage(
                                image: FileImage(File(_imagePath)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imagePath.isEmpty
                          ? const Center(
                              child: Icon(Icons.person_rounded,
                                  size: 44, color: AppColors.forestGreen),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.forestGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            size: 14, color: AppColors.gold),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: AppConstants.animNormal),
            const SizedBox(height: AppConstants.paddingXL),

            // ── Fields ───────────────────────────────────────────────────
            _SectionLabel('PERSONAL INFO'),
            const SizedBox(height: AppConstants.paddingS),
            _Field(
              label: 'Full Name',
              controller: _nameCtrl,
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppConstants.paddingM),
            _Field(
              label: 'Email Address',
              controller: _emailCtrl,
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppConstants.paddingM),
            _Field(
              label: 'Phone Number',
              controller: _phoneCtrl,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppConstants.paddingM),
            _Field(
              label: 'Date of Birth',
              controller: _dobCtrl,
              icon: Icons.cake_outlined,
              readOnly: true,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1995, 3, 12),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.forestGreen,
                        onPrimary: AppColors.white,
                        onSurface: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) {
                  _dobCtrl.text =
                      '${picked.day} ${_monthName(picked.month)} ${picked.year}';
                }
              },
            ),
            const SizedBox(height: AppConstants.paddingXL),

            // ── Addresses ────────────────────────────────────────────────
            _SectionLabel('ADDRESSES'),
            const SizedBox(height: AppConstants.paddingS),
            ...ref.watch(userProfileProvider).addresses.asMap().entries.map((e) {
              return _AddressCard(
                address: e.value,
                onEdit: () => _showAddressForm(existing: e.value, index: e.key),
                onDelete: () =>
                    ref.read(userProfileProvider.notifier).removeAddress(e.key),
              );
            }),
            GestureDetector(
              onTap: () => _showAddressForm(),
              child: Container(
                margin: const EdgeInsets.only(top: 4, bottom: 4),
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                  border: Border.all(color: AppColors.divider, width: 0.8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded,
                        size: 18, color: AppColors.forestGreen),
                    const SizedBox(width: 10),
                    Text(
                      'Add New Address',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.paddingXL),

            // ── Save ─────────────────────────────────────────────────────
            GestureDetector(
              onTap: _saving ? null : _save,
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.forestGreen,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Center(
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.gold,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'SAVE CHANGES',
                          style: AppTextStyles.categoryChip.copyWith(
                            color: AppColors.gold,
                            fontSize: 12,
                            letterSpacing: 2.0,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) => const [
        '',
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ][m];
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTextStyles.categoryChip.copyWith(
          fontSize: 10,
          letterSpacing: 3.0,
          color: AppColors.textMuted,
        ),
      );
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall
            .copyWith(color: AppColors.textMuted, fontSize: 12),
        prefixIcon: Icon(icon, size: 18, color: AppColors.forestGreen),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXS),
          borderSide: const BorderSide(color: AppColors.divider, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXS),
          borderSide: const BorderSide(color: AppColors.divider, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXS),
          borderSide:
              const BorderSide(color: AppColors.forestGreen, width: 1.0),
        ),
      ),
    );
  }
}

// ── Address Card ──────────────────────────────────────────────────────────────
class _AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final icon = address.label == 'Home'
        ? Icons.home_outlined
        : address.label == 'Work'
            ? Icons.work_outline_rounded
            : Icons.location_on_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.forestGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.label,
                  style: AppTextStyles.titleSmall.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    address.line1,
                    address.city,
                    if (address.pinCode.isNotEmpty) address.pinCode,
                  ].join(', '),
                  style: AppTextStyles.bodySmall
                      .copyWith(fontSize: 11, color: AppColors.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined,
                size: 16, color: AppColors.textMuted),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded,
                size: 16, color: AppColors.error),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ── Address Form Sheet ────────────────────────────────────────────────────────
class _AddressFormSheet extends StatefulWidget {
  final Address? existing;
  final void Function(Address) onSave;

  const _AddressFormSheet({this.existing, required this.onSave});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  late String _label;
  late final TextEditingController _line1Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _pinCtrl;

  @override
  void initState() {
    super.initState();
    _label = widget.existing?.label ?? 'Home';
    _line1Ctrl = TextEditingController(text: widget.existing?.line1 ?? '');
    _cityCtrl  = TextEditingController(text: widget.existing?.city ?? '');
    _pinCtrl   = TextEditingController(text: widget.existing?.pinCode ?? '');
  }

  @override
  void dispose() {
    _line1Ctrl.dispose();
    _cityCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_line1Ctrl.text.trim().isEmpty || _cityCtrl.text.trim().isEmpty) return;
    widget.onSave(Address(
      label: _label,
      line1: _line1Ctrl.text.trim(),
      city: _cityCtrl.text.trim(),
      pinCode: _pinCtrl.text.trim(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingM, 0,
            AppConstants.paddingM, AppConstants.paddingM,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                widget.existing != null ? 'Edit Address' : 'Add New Address',
                style: AppTextStyles.titleSmall.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // ── Label chips ──────────────────────────────────────────────
              Row(
                children: ['Home', 'Work', 'Other'].map((lbl) {
                  final isSelected = _label == lbl;
                  final icon = lbl == 'Home'
                      ? Icons.home_outlined
                      : lbl == 'Work'
                          ? Icons.work_outline_rounded
                          : Icons.location_on_outlined;
                  return GestureDetector(
                    onTap: () => setState(() => _label = lbl),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.forestGreen.withValues(alpha: 0.08)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.forestGreen
                              : AppColors.divider,
                          width: isSelected ? 1.5 : 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon,
                              size: 14,
                              color: isSelected
                                  ? AppColors.forestGreen
                                  : AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            lbl,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              color: isSelected
                                  ? AppColors.forestGreen
                                  : AppColors.textMuted,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // ── Fields ───────────────────────────────────────────────────
              _Field(
                label: 'Street / Flat No.',
                controller: _line1Ctrl,
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      label: 'City',
                      controller: _cityCtrl,
                      icon: Icons.location_city_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: _Field(
                      label: 'Pin Code',
                      controller: _pinCtrl,
                      icon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Save button ──────────────────────────────────────────────
              GestureDetector(
                onTap: _save,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Center(
                    child: Text(
                      'SAVE ADDRESS',
                      style: AppTextStyles.categoryChip.copyWith(
                        color: AppColors.gold,
                        fontSize: 12,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
