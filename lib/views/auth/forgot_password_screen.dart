import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/shared_widgets.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// FORGOT PASSWORD SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  String? _emailError;
  String? _formError;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailCtrl.text.trim();
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
    });

    return valid;
  }

  Future<void> _handleResetPassword() async {
    if (!_validate()) return;

    final vm = context.read<AuthViewModel>();
    final success = await vm.resetPassword(email: _emailCtrl.text.trim());

    if (!mounted) return;

    if (success) {
      setState(() => _emailSent = true);
    } else {
      setState(() {
        _formError = vm.errorMessage ?? 'Có lỗi xảy ra';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_emailSent) {
      return _buildSuccessView(context);
    }

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
              Row(
                children: const [
                  AppBackButton(),
                  Spacer(),
                  Text('Quên mật khẩu', style: AppTextStyles.heading3),
                  Spacer(flex: 1),
                  SizedBox(width: 32),
                ],
              ),

              const SizedBox(height: 32),

              // ── Headline ────────────────────────────────────────────
              const Text('Khôi phục mật khẩu', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              const Text(
                'Nhập địa chỉ email của bạn và chúng tôi sẽ gửi liên kết để đặt lại mật khẩu.',
                style: AppTextStyles.body,
              ),

              const SizedBox(height: 36),

              // ── Email field ─────────────────────────────────────────
              const FormFieldLabel('Email'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() => _emailError = null),
                decoration: InputDecoration(
                  hintText: 'example@email.com',
                  errorText: _emailError,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(height: 32),

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

              // ── Reset button ───────────────────────────────────────
              GradientButton(
                label: isLoading ? '' : 'Gửi liên kết khôi phục',
                isLoading: isLoading,
                onPressed: isLoading ? null : _handleResetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const AppBackButton(),
              const Spacer(flex: 2),

              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8FBF8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Center(
                child: Text('Kiểm tra email', style: AppTextStyles.heading1),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  'Chúng tôi đã gửi liên kết khôi phục mật khẩu đến email:\n\n${_emailCtrl.text.trim()}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FBF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Vui lòng nhấn vào liên kết trong email để đặt lại mật khẩu mới. Đừng quên kiểm tra thư mục Spam.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMid,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              GradientButton(
                label: 'Trở về đăng nhập',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
