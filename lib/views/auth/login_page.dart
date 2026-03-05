import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../user/main/main_layout_page.dart';
import '../widgets/shared_widgets.dart';
import 'registration_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// LOGIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ── Demo credentials ──────────────────────────────────────────────────
  static const _demoPhone    = '0123456789';
  static const _demoPassword = '123';

  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;
  String? _phoneError;
  String? _passError;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final phone = _phoneCtrl.text.trim();
    final pass  = _passCtrl.text.trim();

    setState(() {
      _phoneError = phone.isEmpty
          ? 'Vui lòng nhập số điện thoại'
          : phone != _demoPhone
          ? 'Số điện thoại không đúng'
          : null;

      _passError = pass.isEmpty
          ? 'Vui lòng nhập mật khẩu'
          : pass != _demoPassword
          ? 'Mật khẩu không đúng'
          : null;
    });

    if (_phoneError == null && _passError == null) {
      pushScreen(context, const MainLayoutPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 16),

            // ── Top bar ────────────────────────────────────────────────
            const _LoginTopBar(),

            const SizedBox(height: 32),

            // ── Headline ───────────────────────────────────────────────
            const _LoginHeadline(),

            const SizedBox(height: 36),

            // ── Demo credential hint ───────────────────────────────────
            const _DemoCredentialHint(),

            const SizedBox(height: 20),

            // ── Phone field ────────────────────────────────────────────
            const FormFieldLabel('Phone Number'),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() => _phoneError = null),
              decoration: InputDecoration(
                hintText: '0123456789',
                errorText: _phoneError,
              ),
            ),

            const SizedBox(height: 20),

            // ── Password field ─────────────────────────────────────────
            const FormFieldLabel('Password'),
            const SizedBox(height: 8),
            _PasswordField(
              controller: _passCtrl,
              obscure: _obscure,
              errorText: _passError,
              onToggle: () => setState(() => _obscure = !_obscure),
              onChanged: (_) => setState(() => _passError = null),
            ),

            const SizedBox(height: 8),
            const _ForgotPasswordLink(),
            const SizedBox(height: 24),

            // ── Log In button ──────────────────────────────────────────
            GradientButton(
              label: 'Log In',
              onPressed: _handleLogin,
            ),

            const SizedBox(height: 32),

            // ── Sign Up hint ───────────────────────────────────────────
            _SignUpHint(onTap: () => pushScreen(context, const RegistrationScreen())),
          ]),
        ),
      ),
    );
  }
}

// ─── Sub-widget: top bar with back button + "LOGIN" label ────────────────────

class _LoginTopBar extends StatelessWidget {
  const _LoginTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const AppBackButton(),
      const Spacer(),
      const Text('LOGIN', style: AppTextStyles.badge),
      const Spacer(flex: 2),
    ]);
  }
}

// ─── Sub-widget: headline + subtitle ─────────────────────────────────────────

class _LoginHeadline extends StatelessWidget {
  const _LoginHeadline();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Text('Welcome Back', style: AppTextStyles.heading1),
      SizedBox(height: 8),
      Text('Sign in to access your health vitals.', style: AppTextStyles.body),
    ]);
  }
}

// ─── Sub-widget: password TextField with show/hide toggle ────────────────────

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Enter your password',
        errorText: errorText,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textHint,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widget: demo credential info box ────────────────────────────────────

class _DemoCredentialHint extends StatelessWidget {
  const _DemoCredentialHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FBF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text(
            'Tài khoản mẫu để đăng nhập:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          SizedBox(height: 2),
          Text(
            'SĐT: 0123456789   |   Mật khẩu: 123',
            style: TextStyle(fontSize: 12, color: AppColors.textMid),
          ),
        ]),
      ]),
    );
  }
}

// ─── Sub-widget: Forgot Password link ────────────────────────────────────────

class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: const Text('Forgot Password?', style: AppTextStyles.link),
      ),
    );
  }
}

// ─── Sub-widget: Sign Up hint at the bottom ──────────────────────────────────

class _SignUpHint extends StatelessWidget {
  const _SignUpHint({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("Don't have an account? ",
          style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
      GestureDetector(
        onTap: onTap,
        child: const Text('Sign Up', style: AppTextStyles.link),
      ),
    ]);
  }
}