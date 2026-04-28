import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/domain/auth_controller.dart';
import '../../../profile/domain/user_profile_controller.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final String redirectPath;
  final bool expectNewUser;
  final String? name;
  final String? email;
  final String? dob;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.redirectPath,
    this.expectNewUser = false,
    this.name,
    this.email,
    this.dob,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _ctls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  String? _verificationId;
  bool _sending = true;
  bool _verifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    for (final c in _ctls) { c.dispose(); }
    for (final n in _nodes) { n.dispose(); }
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _signIn(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() {
            _sending = false;
            _error = e.message ?? 'Verification failed. Try again.';
          });
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _sending = false;
          });
          _nodes[0].requestFocus();
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (mounted) setState(() => _verificationId = verificationId);
      },
    );
  }

  Future<void> _verify() async {
    final otp = _ctls.map((c) => c.text).join();
    if (otp.length < 6 || _verificationId == null) return;

    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _signIn(credential);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _verifying = false;
          _error = e.message ?? 'Invalid OTP. Please try again.';
        });
      }
    }
  }

  Future<void> _signIn(PhoneAuthCredential credential) async {
    try {
      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;

      final isNewUser = result.additionalUserInfo?.isNewUser ?? false;

      if (widget.expectNewUser && !isNewUser) {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          setState(() {
            _verifying = false;
            _sending = false;
            _error =
                'This number is already registered. Please sign in instead.';
          });
        }
        return;
      }

      if (!widget.expectNewUser && isNewUser) {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          setState(() {
            _verifying = false;
            _sending = false;
            _error =
                'No account found for this number. Please create an account first.';
          });
        }
        return;
      }

      ref
          .read(authProvider.notifier)
          .login(result.user?.uid ?? widget.phone);

      if (widget.expectNewUser) {
        ref.read(userProfileProvider.notifier).update(
              name: widget.name,
              email: widget.email,
              phone: widget.phone,
              dob: widget.dob,
            );
      } else {
        ref.read(userProfileProvider.notifier).reload();
      }

      context.go(widget.redirectPath);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _verifying = false;
          _sending = false;
          _error = e.message ?? 'Sign-in failed. Try again.';
        });
      }
    }
  }

  void _onDigit(int index, String value) {
    if (value.length == 1 && index < 5) {
      _nodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    // Auto-verify when all 6 digits entered
    final otp = _ctls.map((c) => c.text).join();
    if (otp.length == 6) _verify();
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
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Verify Number', style: AppTextStyles.displaySmall)
                  .animate()
                  .fadeIn(duration: AppConstants.animNormal),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit OTP sent to ${widget.phone}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ).animate().fadeIn(
                    duration: AppConstants.animNormal,
                    delay: const Duration(milliseconds: 80),
                  ),
              const SizedBox(height: 40),

              if (_sending)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.forestGreen),
                )
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => _OtpBox(
                    controller: _ctls[i],
                    focusNode: _nodes[i],
                    onChanged: (v) => _onDigit(i, v),
                  )),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error),
                  ),
                ],

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _verifying ? null : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forestGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusS),
                      ),
                      elevation: 0,
                    ),
                    child: _verifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            'Verify OTP',
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppColors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: _sending ? null : _sendOtp,
                    child: Text(
                      'Resend OTP',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.forestGreen),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: AppTextStyles.titleLarge,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.zero,
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
        ),
        onChanged: onChanged,
      ),
    );
  }
}
