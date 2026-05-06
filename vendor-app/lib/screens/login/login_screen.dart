import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/auth_provider.dart';

// Auramika Daily palette
const _black      = Color(0xFF1A2F25);
const _darkCard   = Color(0xFF0F1F18);
const _gold       = Color(0xFFD4AF37);
const _goldLight  = Color(0xFFF5E9A0);
const _goldPale   = Color(0xFFF5E9A0);
const _olive      = Color(0xFF1A2F25);
const _oliveDeep  = Color(0xFF1A2F25);
const _white      = Color(0xFFFFFFFF);
const _offWhite   = Color(0xFFFAFAF5);
const _textDark   = Color(0xFF1A2F25);
const _textMuted  = Color(0xFF8A8A8A);

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final obscure     = useState(true);
    final authState   = ref.watch(authProvider);
    final screenH     = MediaQuery.of(context).size.height;
    final topPad      = MediaQuery.of(context).padding.top;

    ref.listen(authProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFB00020),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: _offWhite,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(children: [

          // ── Dark hero (matches dashboard header gradient) ─────────────────────
          Container(
            width: double.infinity,
            height: screenH * 0.46,
            padding: EdgeInsets.fromLTRB(28, topPad + 32, 28, 36),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF060806), Color(0xFF0C1006), Color(0xFF121808)],
                stops: [0.0, 0.55, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(children: [

              // Faint gold diamond lattice
              Positioned.fill(child: CustomPaint(painter: _LatticePatternPainter())),

              // Diagonal shine sweep across the whole hero
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withAlpha(0),
                        Colors.white.withAlpha(10),
                        Colors.white.withAlpha(0),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Gold radial shimmer — top right
              Positioned(
                top: -40,
                right: -20,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_gold.withAlpha(50), Colors.transparent],
                    ),
                  ),
                ),
              ),

              // Deep olive radial shimmer — bottom left
              Positioned(
                bottom: -20,
                left: -10,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_oliveDeep.withAlpha(70), Colors.transparent],
                    ),
                  ),
                ),
              ),

              // Olive shimmer — centre
              Positioned(
                top: 60, left: 80,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_olive.withAlpha(28), Colors.transparent],
                    ),
                  ),
                ),
              ),

              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Logo row
                Row(children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: _white.withAlpha(12),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: _goldLight.withAlpha(180), width: 1.5),
                    ),
                    child: const Icon(Icons.diamond_outlined, color: _goldLight, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'AURAMIKA',
                      style: TextStyle(
                        fontSize: 21, fontWeight: FontWeight.w800,
                        color: _white, letterSpacing: 4.5,
                        shadows: [Shadow(color: Color(0x50000000), blurRadius: 8)],
                      ),
                    ),
                    Text(
                      'VENDOR PORTAL',
                      style: TextStyle(
                        fontSize: 8, fontWeight: FontWeight.w600,
                        color: _goldLight, letterSpacing: 4.0,
                      ),
                    ),
                  ]),
                ]),

                const Spacer(),

                // Floating diamond ornament
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CustomPaint(size: const Size(48, 48), painter: _DiamondPainter()),
                  ),
                ),

                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 34, fontWeight: FontWeight.w800,
                    color: _white, height: 1.1, letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Container(width: 28, height: 1.5, color: _gold),
                  const SizedBox(width: 10),
                  Text(
                    'Manage your products & orders',
                    style: TextStyle(
                      fontSize: 13, color: _white.withAlpha(195),
                      fontWeight: FontWeight.w400, letterSpacing: 0.2,
                    ),
                  ),
                ]),
                const SizedBox(height: 4),
              ]),
            ]),
          ),

          // ── Sign-in card ─────────────────────────────────────────────────────
          Container(
            color: _offWhite,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              transform: Matrix4.translationValues(0, -30, 0),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _gold.withAlpha(55), width: 1),
                boxShadow: [
                  BoxShadow(color: _gold.withAlpha(28), blurRadius: 28, offset: const Offset(0, 10)),
                  BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Section header with gold accent bar
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Container(
                    width: 3, height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_gold, _goldLight],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      'Sign in to your account',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark, letterSpacing: -0.2),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Enter your vendor credentials below',
                      style: TextStyle(fontSize: 12, color: _textMuted),
                    ),
                  ]),
                ]),
                const SizedBox(height: 26),

                // Username field
                _LuxuryField(
                  controller: usernameCtrl,
                  label: 'Username',
                  icon: Icons.person_outline_rounded,
                  autofillHints: const [AutofillHints.username],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),

                // Password field
                _LuxuryField(
                  controller: passwordCtrl,
                  label: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: obscure.value,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(ref, usernameCtrl.text, passwordCtrl.text),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: _textMuted, size: 20,
                    ),
                    onPressed: () => obscure.value = !obscure.value,
                  ),
                ),
                const SizedBox(height: 30),

                // Gold gradient sign-in button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: authState.isLoading
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [_gold, _goldLight]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: _white)),
                          ),
                        )
                      : GestureDetector(
                          onTap: () => _login(ref, usernameCtrl.text, passwordCtrl.text),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB8902E), _gold, _goldLight],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(color: _gold.withAlpha(80), blurRadius: 14, offset: const Offset(0, 5)),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'S I G N   I N',
                                style: TextStyle(
                                  color: _white, fontSize: 14,
                                  fontWeight: FontWeight.w800, letterSpacing: 3.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ]),
            ),
          ),

          // ── Info note ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _goldPale.withAlpha(80),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _gold.withAlpha(50)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.diamond_outlined, size: 14, color: _gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Credentials are provided by the Auramika admin team.',
                    style: TextStyle(fontSize: 12, color: _textMuted.withAlpha(220), height: 1.5),
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
              foregroundColor: _olive,
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
      backgroundColor: _white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: _goldPale, borderRadius: BorderRadius.circular(2)),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF080808), Color(0xFF111A0E)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: _gold.withAlpha(80), width: 1),
            ),
            child: const Icon(Icons.support_agent_rounded, color: _goldLight, size: 28),
          ),
          const SizedBox(height: 16),
          const Text('Get Vendor Access',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark)),
          const SizedBox(height: 8),
          const Text(
            'Vendor accounts are created by the Auramika admin team. Reach out to get your credentials.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _textMuted, height: 1.5),
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
              style: OutlinedButton.styleFrom(
                foregroundColor: _olive,
                side: const BorderSide(color: _olive, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Got it'),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Luxury text field ─────────────────────────────────────────────────────────
class _LuxuryField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final List<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  const _LuxuryField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscureText,
    autofillHints: autofillHints,
    textInputAction: textInputAction,
    onSubmitted: onSubmitted,
    style: const TextStyle(color: _textDark, fontSize: 14, fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _textMuted, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8F5EE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: _textMuted, fontSize: 13),
      floatingLabelStyle: const TextStyle(color: _olive, fontWeight: FontWeight.w600, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8DFC8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8DFC8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _olive, width: 1.5),
      ),
    ),
  );
}

// ── Gold diamond ornament ─────────────────────────────────────────────────────
class _DiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB8902E), _gold, _goldLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final path = Path()
      ..moveTo(cx, 0)
      ..lineTo(size.width, cy)
      ..lineTo(cx, size.height)
      ..lineTo(0, cy)
      ..close();

    canvas.drawPath(path, fill);

    // Shine line
    final shine = Paint()
      ..color = _white.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(cx * 0.6, cy * 0.5), Offset(cx * 1.1, cy * 0.3), shine);

    final border = Paint()
      ..color = _goldLight.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Gold lattice background pattern ──────────────────────────────────────────
class _LatticePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _goldLight.withAlpha(18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 44.0;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final path = Path()
          ..moveTo(x, y - spacing / 2)
          ..lineTo(x + spacing / 2, y)
          ..lineTo(x, y + spacing / 2)
          ..lineTo(x - spacing / 2, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Contact row ───────────────────────────────────────────────────────────────
class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContactRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: _goldPale.withAlpha(60),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _gold.withAlpha(50)),
    ),
    child: Row(children: [
      Icon(icon, size: 18, color: _olive),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(fontSize: 12, color: _textMuted, fontWeight: FontWeight.w500)),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w600)),
    ]),
  );
}
