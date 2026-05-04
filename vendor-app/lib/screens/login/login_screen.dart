import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final obscure = useState(true);
    final authState = ref.watch(authProvider);
    final screenH = MediaQuery.of(context).size.height;
    final topPad  = MediaQuery.of(context).padding.top;

    ref.listen(authProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(children: [

          // ── Full-width gradient hero ─────────────────────────────────────
          Container(
            width: double.infinity,
            height: screenH * 0.42,
            padding: EdgeInsets.fromLTRB(28, topPad + 36, 28, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB8922A), Color(0xFFC9A84C), Color(0xFFE8C97A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Logo row
              Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                const Text(
                  'AURAMIKA',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: 3.5,
                  ),
                ),
              ]),
              const Spacer(),
              const Text(
                'Vendor Portal',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage your products & orders',
                style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(210), fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 8),
            ]),
          ),

          // ── White form card ──────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.background,
            ),
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.cardShadow,
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(
                  'Sign in to your account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enter your vendor credentials below',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 24),

                // Username
                TextField(
                  controller: usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.textSecondary, size: 20),
                  ),
                  autofillHints: const [AutofillHints.username],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // Password
                TextField(
                  controller: passwordCtrl,
                  obscureText: obscure.value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.textSecondary, size: 20,
                      ),
                      onPressed: () => obscure.value = !obscure.value,
                    ),
                  ),
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(ref, usernameCtrl.text, passwordCtrl.text),
                ),
                const SizedBox(height: 24),

                // Sign In button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isLoading
                        ? null
                        : () => _login(ref, usernameCtrl.text, passwordCtrl.text),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Sign In'),
                  ),
                ),
              ]),
            ),
          ),

          // ── Info & contact ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.secondary.withAlpha(40)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline_rounded, size: 15, color: AppTheme.secondary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Credentials are provided by the Auramika admin team.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
                  ),
                ),
              ]),
            ),
          ),

          TextButton.icon(
            onPressed: () => _showContactSheet(context),
            icon: const Icon(Icons.headset_mic_outlined, size: 15),
            label: const Text('Need access? Contact Auramika Admin'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.secondary,
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  void _login(WidgetRef ref, String username, String password) {
    if (username.trim().isEmpty || password.isEmpty) return;
    ref.read(authProvider.notifier).login(username.trim(), password);
  }

  void _showContactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.support_agent_rounded, color: AppTheme.secondary, size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Get Vendor Access',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Vendor accounts are created by the Auramika admin team. Reach out to get your credentials.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          _ContactRow(icon: Icons.email_outlined, label: 'Email', value: 'admin@auramikadaily.com'),
          const SizedBox(height: 8),
          _ContactRow(icon: Icons.phone_outlined, label: 'WhatsApp', value: '+91 XXXXX XXXXX'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContactRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppTheme.surfaceVariant,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(children: [
      Icon(icon, size: 18, color: AppTheme.secondary),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
    ]),
  );
}
