import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../user/main/main_layout_page.dart';
import '../widgets/shared_widgets.dart';
import 'forgot_password_screen.dart';
import 'registration_screen.dart';
import '../admin/main/admin_main_layout_page.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// LOGIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  String? _emailError;
  String? _passError;
  String? _formError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────
  bool _validate() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    bool valid = true;

    setState(() {
      _formError = null; // Clear overall form error on new attempt
      if (email.isEmpty) {
        _emailError = 'Vui lòng nhập email';
        valid = false;
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        _emailError = 'Email không hợp lệ';
        valid = false;
      } else {
        _emailError = null;
      }

      if (pass.isEmpty) {
        _passError = 'Vui lòng nhập mật khẩu';
        valid = false;
      } else {
        _passError = null;
      }
    });

    return valid;
  }

  // ── Handle login ────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_validate()) return;

    final vm = context.read<AuthViewModel>();
    final success = await vm.signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      final user = vm.currentUser;
      if (user?.role == 'admin') {
        replaceWithFade(context, const AdminMainLayoutPage());
      } else {
        replaceWithFade(context, const MainLayoutPage());
      }
    } else {
      setState(() {
        _formError = vm.errorMessage ?? 'Đăng nhập thất bại';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Top bar ─────────────────────────────────────────────
              const _LoginTopBar(),

              const SizedBox(height: 32),

              // ── Headline ────────────────────────────────────────────
              const _LoginHeadline(),

              const SizedBox(height: 32),

              // ── Email field ─────────────────────────────────────────
              const FormFieldLabel('Email'),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() => _emailError = null),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                decoration: AuthInputDecoration.build(
                  hintText: 'example@email.com',
                  errorText: _emailError,
                  prefixIcon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 20),

              // ── Password field ──────────────────────────────────────
              const FormFieldLabel('Mật khẩu'),
              _PasswordField(
                controller: _passCtrl,
                obscure: _obscure,
                errorText: _passError,
                onToggle: () => setState(() => _obscure = !_obscure),
                onChanged: (_) => setState(() => _passError = null),
              ),

              const SizedBox(height: 4),
              const _ForgotPasswordLink(),
              const SizedBox(height: 12),

              // ── General Form Error ──────────────────────────────────
              if (_formError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formError!,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Log In button ───────────────────────────────────────
              GradientButton(
                label: isLoading ? '' : 'Đăng nhập',
                isLoading: isLoading,
                onPressed: isLoading ? null : _handleLogin,
              ),

              const SizedBox(height: 32),

              // ── Sign Up hint ────────────────────────────────────────
              _SignUpHint(
                onTap: () => pushScreen(context, const RegistrationScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widget: top bar ──────────────────────────────────────────────────────

class _LoginTopBar extends StatelessWidget {
  const _LoginTopBar();

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Row(
      children: [
        // Only show the back button when there is a previous route
        if (canPop) const AppBackButton() else const SizedBox(width: 32),
        const Spacer(),
        const Text('Đăng nhập', style: AppTextStyles.heading3),
        const Spacer(flex: 1),
        const SizedBox(width: 32),
      ],
    );
  }
}

// ─── Sub-widget: headline + subtitle ─────────────────────────────────────────

class _LoginHeadline extends StatelessWidget {
  const _LoginHeadline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chào mừng trở lại',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.textDark,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Đăng nhập để tiếp tục theo dõi sức khoẻ và đạt được mục tiêu của bạn.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textGrey,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ─── Sub-widget: password field ───────────────────────────────────────────────

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
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: AuthInputDecoration.build(
        hintText: 'Nhập mật khẩu của bạn',
        errorText: errorText,
        prefixIcon: Icons.lock_outline,
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

// ─── Sub-widget: Forgot Password link ────────────────────────────────────────

class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => pushScreen(context, const ForgotPasswordScreen()),
        child: const Text('Quên mật khẩu?', style: AppTextStyles.link),
      ),
    );
  }
}

// ─── Sub-widget: Sign Up hint ─────────────────────────────────────────────────

class _SignUpHint extends StatelessWidget {
  const _SignUpHint({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Chưa có tài khoản? ',
          style: TextStyle(fontSize: 13, color: AppColors.textGrey),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text('Đăng ký', style: AppTextStyles.link),
        ),
      ],
    );
  }
}
