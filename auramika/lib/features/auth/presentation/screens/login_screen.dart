import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? redirectPath;
  final bool isCreateAccount;
  final String? initialPhone;
  final bool alreadyExists;

  const LoginScreen({
    super.key,
    this.redirectPath,
    this.isCreateAccount = false,
    this.initialPhone,
    this.alreadyExists = false,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  DateTime? _selectedDob;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null) {
      _phoneCtrl.text = widget.initialPhone!.replaceFirst('+91', '').trim();
    }
    if (widget.alreadyExists) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This number is already registered. Please sign in instead.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
            ),
            backgroundColor: AppColors.terraCotta,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  void _proceed() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final phone = '+91${_phoneCtrl.text.trim()}';
    context.push('/auth/otp', extra: {
      'phone': phone,
      'redirect': widget.redirectPath ?? '/',
      'expectNewUser': widget.isCreateAccount,
      if (widget.isCreateAccount) 'name': _nameCtrl.text.trim(),
      if (widget.isCreateAccount) 'email': _emailCtrl.text.trim(),
      if (widget.isCreateAccount) 'dob': _dobCtrl.text.trim(),
    });

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  widget.isCreateAccount ? 'Create Account' : 'Welcome Back',
                  style: AppTextStyles.displaySmall,
                ).animate().fadeIn(duration: AppConstants.animNormal),
                const SizedBox(height: 8),
                Text(
                  widget.isCreateAccount
                      ? 'Join AURAMIKA for exclusive jewellery curation'
                      : 'Sign in to continue your jewellery journey',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ).animate().fadeIn(
                      duration: AppConstants.animNormal,
                      delay: const Duration(milliseconds: 80),
                    ),
                const SizedBox(height: 40),

                if (widget.isCreateAccount) ...[
                  _buildField(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    hint: 'Your name',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'your@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(),
                  const SizedBox(height: 16),
                ],

                _buildPhoneField(),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _proceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forestGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusS),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            'Send OTP',
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.pushReplacement(
                        widget.isCreateAccount
                            ? '/auth/login'
                            : '/auth/register',
                        extra: {'redirect': widget.redirectPath},
                      );
                    },
                    child: Text(
                      widget.isCreateAccount
                          ? 'Already have an account? Sign In'
                          : 'New to AURAMIKA? Create Account',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mobile Number', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: _inputDecoration('10-digit mobile number').copyWith(
            prefixText: '+91  ',
            prefixStyle: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textPrimary),
          ),
          validator: (v) {
            if (v == null || v.length != 10) {
              return 'Enter a valid 10-digit number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hint),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date of Birth', style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDob ?? DateTime(2000),
              firstDate: DateTime(1940),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.forestGreen,
                    onPrimary: AppColors.white,
                    surface: AppColors.background,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setState(() {
                _selectedDob = picked;
                _dobCtrl.text =
                    '${picked.day.toString().padLeft(2, '0')}/'
                    '${picked.month.toString().padLeft(2, '0')}/'
                    '${picked.year}';
              });
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: _dobCtrl,
              readOnly: true,
              decoration: _inputDecoration('Tap to select').copyWith(
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Please select your date of birth' : null,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          borderSide:
              const BorderSide(color: AppColors.forestGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      );
}
