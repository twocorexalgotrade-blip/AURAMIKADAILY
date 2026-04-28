import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/rive_animation_widget.dart';

// ── Custom Order Screen — Bespoke Request Wizard ──────────────────────────────
/// 4-step PageView:
///   Step 1 — Category  (Ring / Necklace / Cuff / Earrings)
///   Step 2 — Material  (Brass / Copper)
///   Step 3 — Reference (Upload image / sketch)
///   Step 4 — Contact   (Name + WhatsApp)
/// Success State — Gold tick animation + "artisans will contact you" message
class CustomOrderScreen extends StatefulWidget {
  const CustomOrderScreen({super.key});
  @override
  State<CustomOrderScreen> createState() => _CustomOrderScreenState();
}

class _CustomOrderScreenState extends State<CustomOrderScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentStep = 0;
  bool _submitted = false;

  // Step 1
  String? _selectedCategory;
  // Step 2
  String? _selectedMaterial;
  // Step 3
  File? _referenceImage;
  // Step 4
  final _nameCtrl = TextEditingController();
  final _waCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Success animation
  late AnimationController _tickCtrl;

  static const _totalSteps = 4;

  @override
  void initState() {
    super.initState();
    _tickCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _waCtrl.dispose();
    _tickCtrl.dispose();
    super.dispose();
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0: return _selectedCategory != null;
      case 1: return _selectedMaterial != null;
      case 2: return true; // reference is optional
      case 3: return _nameCtrl.text.trim().isNotEmpty && _waCtrl.text.trim().length >= 10;
      default: return false;
    }
  }

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      _pageCtrl.nextPage(
        duration: AppConstants.animNormal,
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _pageCtrl.previousPage(
        duration: AppConstants.animNormal,
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _submit() {
    setState(() => _submitted = true);
    _tickCtrl.forward();
  }

  Future<void> _pickReference(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, maxWidth: 1080, imageQuality: 85);
    if (file != null) setState(() => _referenceImage = File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _SuccessScreen(tickCtrl: _tickCtrl, onDone: () => Navigator.of(context).pop());

    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            color: AppColors.background,
            padding: EdgeInsets.fromLTRB(AppConstants.paddingM, topPad + 8, AppConstants.paddingM, AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _back,
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                    const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      child: Text(
                        'BESPOKE REQUEST',
                        style: AppTextStyles.categoryChip.copyWith(fontSize: 11, letterSpacing: 3.0),
                      ),
                    ),
                    Text(
                      '${_currentStep + 1} of $_totalSteps',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingM),
                // Step indicator
                Row(
                  children: List.generate(_totalSteps, (i) {
                    final active = i <= _currentStep;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: AppConstants.animFast,
                        height: 2,
                        margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: active ? AppColors.forestGreen : AppColors.divider,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // ── PageView ─────────────────────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1Category(
                  selected: _selectedCategory,
                  onSelect: (v) => setState(() => _selectedCategory = v),
                ),
                _Step2Material(
                  selected: _selectedMaterial,
                  onSelect: (v) => setState(() => _selectedMaterial = v),
                ),
                _Step3Reference(
                  image: _referenceImage,
                  onPickGallery: () => _pickReference(ImageSource.gallery),
                  onPickCamera: () => _pickReference(ImageSource.camera),
                  onRemove: () => setState(() => _referenceImage = null),
                ),
                _Step4Contact(
                  nameCtrl: _nameCtrl,
                  waCtrl: _waCtrl,
                  formKey: _formKey,
                  onChanged: () => setState(() {}),
                ),
              ],
            ),
          ),

          // ── Bottom CTA ───────────────────────────────────────────────────
          Container(
            color: AppColors.background,
            padding: EdgeInsets.fromLTRB(
              AppConstants.paddingM,
              AppConstants.paddingM,
              AppConstants.paddingM,
              botPad + AppConstants.paddingM,
            ),
            child: GestureDetector(
              onTap: _canProceed ? _next : null,
              child: AnimatedContainer(
                duration: AppConstants.animFast,
                height: 52,
                decoration: BoxDecoration(
                  color: _canProceed ? AppColors.forestGreen : AppColors.divider,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Center(
                  child: Text(
                    _currentStep == _totalSteps - 1 ? 'SUBMIT REQUEST' : 'CONTINUE',
                    style: AppTextStyles.categoryChip.copyWith(
                      color: _canProceed ? AppColors.white : AppColors.textMuted,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Category ──────────────────────────────────────────────────────────
class _Step1Category extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  static const _items = [
    ('Ring', Icons.circle_outlined),
    ('Necklace', Icons.link_outlined),
    ('Cuff', Icons.watch_outlined),
    ('Earrings', Icons.hearing_outlined),
  ];

  const _Step1Category({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What are we making?', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 6),
          Text('Choose the type of jewelry', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: AppConstants.paddingL),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppConstants.paddingM,
            crossAxisSpacing: AppConstants.paddingM,
            childAspectRatio: 1.1,
            children: _items.map((item) {
              final isSelected = selected == item.$1;
              return GestureDetector(
                onTap: () => onSelect(item.$1),
                child: AnimatedContainer(
                  duration: AppConstants.animFast,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.forestGreen.withValues(alpha: 0.08) : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    border: Border.all(
                      color: isSelected ? AppColors.forestGreen : AppColors.divider,
                      width: isSelected ? 1.5 : 0.8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.$2,
                        size: 32,
                        color: isSelected ? AppColors.forestGreen : AppColors.textMuted,
                      ),
                      const SizedBox(height: AppConstants.paddingS),
                      Text(
                        item.$1.toUpperCase(),
                        style: AppTextStyles.categoryChip.copyWith(
                          fontSize: 11,
                          letterSpacing: 2.0,
                          color: isSelected ? AppColors.forestGreen : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: _items.indexOf(item) * 60)).fadeIn().slideY(begin: 0.1, end: 0);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Material ──────────────────────────────────────────────────────────
class _Step2Material extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _Step2Material({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose your metal', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 6),
          Text('Each metal has its own character', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: AppConstants.paddingXL),
          _MaterialTile(
            label: 'BRASS',
            subtitle: 'Warm, golden tones. Timeless & classic.',
            color: AppColors.brass,
            isSelected: selected == 'Brass',
            onTap: () => onSelect('Brass'),
          ),
          const SizedBox(height: AppConstants.paddingM),
          _MaterialTile(
            label: 'COPPER',
            subtitle: 'Rich, earthy tones. Bold & distinctive.',
            color: AppColors.copper,
            isSelected: selected == 'Copper',
            onTap: () => onSelect('Copper'),
          ),
        ],
      ),
    );
  }
}

class _MaterialTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _MaterialTile({required this.label, required this.subtitle, required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        height: 90,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          border: Border.all(color: isSelected ? color : AppColors.divider, width: isSelected ? 1.5 : 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusS),
                  bottomLeft: Radius.circular(AppConstants.radiusS),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Center(child: Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle))),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.titleSmall.copyWith(color: isSelected ? color : AppColors.textPrimary, letterSpacing: 2.0, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: AppConstants.paddingM),
                child: Icon(Icons.check_circle_rounded, color: color, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Step 3: Reference ─────────────────────────────────────────────────────────
class _Step3Reference extends StatelessWidget {
  final File? image;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onRemove;
  const _Step3Reference({required this.image, required this.onPickGallery, required this.onPickCamera, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Do you have a design in mind?', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 6),
          Text('Upload a photo or sketch for reference (optional)', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: AppConstants.paddingXL),
          if (image == null) ...[
            Row(
              children: [
                Expanded(
                  child: _RefOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: onPickGallery,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingM),
                Expanded(
                  child: _RefOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: onPickCamera,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingL),
            Center(
              child: Text(
                'or skip this step',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 11),
              ),
            ),
          ] else ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  child: Image.file(image!, height: 220, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppConstants.radiusXS),
                      ),
                      child: const Icon(Icons.close_rounded, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingM),
            Text('Reference uploaded', style: AppTextStyles.bodySmall.copyWith(color: AppColors.forestGreen, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}

class _RefOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _RefOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          border: Border.all(color: AppColors.divider, width: 0.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: AppColors.forestGreen),
            const SizedBox(height: AppConstants.paddingS),
            Text(label.toUpperCase(), style: AppTextStyles.categoryChip.copyWith(fontSize: 10, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}

// ── Step 4: Contact ───────────────────────────────────────────────────────────
class _Step4Contact extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController waCtrl;
  final GlobalKey<FormState> formKey;
  final VoidCallback onChanged;
  const _Step4Contact({required this.nameCtrl, required this.waCtrl, required this.formKey, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Almost there!', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 6),
            Text('Our artisans will reach out to you directly', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: AppConstants.paddingXL),
            _AtelierField(
              controller: nameCtrl,
              label: 'YOUR NAME',
              hint: 'e.g. Priya Sharma',
              icon: Icons.person_outline_rounded,
              onChanged: (_) => onChanged(),
              inputType: TextInputType.name,
            ),
            const SizedBox(height: AppConstants.paddingM),
            _AtelierField(
              controller: waCtrl,
              label: 'WHATSAPP NUMBER',
              hint: '+91 98765 43210',
              icon: Icons.phone_outlined,
              onChanged: (_) => onChanged(),
              inputType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: AppConstants.paddingL),
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 0.8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.gold),
                  const SizedBox(width: AppConstants.paddingS),
                  Expanded(
                    child: Text(
                      'Our artisans will contact you within 24 hours to discuss your design.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 10, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AtelierField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextInputType inputType;
  final List<TextInputFormatter>? inputFormatters;

  const _AtelierField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    required this.inputType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.categoryChip.copyWith(fontSize: 9, letterSpacing: 2.0, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: inputType,
          inputFormatters: inputFormatters,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM, vertical: AppConstants.paddingM),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              borderSide: const BorderSide(color: AppColors.divider, width: 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              borderSide: const BorderSide(color: AppColors.divider, width: 0.8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
              borderSide: const BorderSide(color: AppColors.forestGreen, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Success Screen ────────────────────────────────────────────────────────────
class _SuccessScreen extends StatelessWidget {
  final AnimationController tickCtrl;
  final VoidCallback onDone;
  const _SuccessScreen({required this.tickCtrl, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final botPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rive success tick (falls back to Flutter animation)
              RiveSuccessTick(
                size: 88,
                fallbackController: tickCtrl,
              ),

              const SizedBox(height: AppConstants.paddingXL),

              Text(
                'REQUEST RECEIVED',
                style: AppTextStyles.categoryChip.copyWith(fontSize: 13, letterSpacing: 3.0),
              ).animate(delay: 400.ms).fadeIn(),

              const SizedBox(height: AppConstants.paddingM),

              Text(
                'Our artisans will contact you\nwithin 24 hours.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted, height: 1.6),
                textAlign: TextAlign.center,
              ).animate(delay: 600.ms).fadeIn(),

              const SizedBox(height: 6),

              Text(
                'We\'ll discuss your design, timeline & pricing on WhatsApp.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 10, height: 1.5),
                textAlign: TextAlign.center,
              ).animate(delay: 800.ms).fadeIn(),

              const SizedBox(height: AppConstants.paddingXL * 2),

              GestureDetector(
                onTap: onDone,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen,
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Center(
                    child: Text(
                      'BACK TO HOME',
                      style: AppTextStyles.categoryChip.copyWith(color: AppColors.white, fontSize: 12, letterSpacing: 1.5),
                    ),
                  ),
                ),
              ).animate(delay: 1000.ms).fadeIn().slideY(begin: 0.1, end: 0),

              SizedBox(height: botPad),
            ],
          ),
        ),
      ),
    );
  }
}
