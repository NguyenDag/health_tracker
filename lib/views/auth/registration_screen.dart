import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/shared_widgets.dart';
import 'login_page.dart';
import 'verification_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// REGISTRATION SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _ageCtrl        = TextEditingController(text: '25');
  final _weightCtrl     = TextEditingController(text: '70');
  final _heightCtrl     = TextEditingController(text: '175');
  String _gender = 'Male';
  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  // Error messages
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPassError;
  String? _phoneError;

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl, _lastNameCtrl, _emailCtrl,
      _passwordCtrl, _confirmPassCtrl,
      _phoneCtrl, _ageCtrl, _weightCtrl, _heightCtrl,
    ]) c.dispose();
    super.dispose();
  }

  // ── Validation ──────────────────────────────────────────────────────
  bool _validate() {
    bool valid = true;
    setState(() {
      _firstNameError = _firstNameCtrl.text.trim().isEmpty
          ? 'Vui lòng nhập tên' : null;
      _lastNameError  = _lastNameCtrl.text.trim().isEmpty
          ? 'Vui lòng nhập họ' : null;
      if (_firstNameError != null || _lastNameError != null) valid = false;

      final email = _emailCtrl.text.trim();
      if (email.isEmpty) {
        _emailError = 'Vui lòng nhập email';
        valid = false;
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        _emailError = 'Email không hợp lệ';
        valid = false;
      } else {
        _emailError = null;
      }

      if (_passwordCtrl.text.length < 6) {
        _passwordError = 'Mật khẩu phải ít nhất 6 ký tự';
        valid = false;
      } else {
        _passwordError = null;
      }

      if (_confirmPassCtrl.text != _passwordCtrl.text) {
        _confirmPassError = 'Mật khẩu xác nhận không khớp';
        valid = false;
      } else {
        _confirmPassError = null;
      }

      if (_phoneCtrl.text.trim().isEmpty) {
        _phoneError = 'Vui lòng nhập số điện thoại';
        valid = false;
      } else {
        _phoneError = null;
      }
    });
    return valid;
  }

  // ── Submit ──────────────────────────────────────────────────────────
  Future<void> _handleRegister() async {
    if (!_validate()) return;

    final vm = context.read<AuthViewModel>();
    final success = await vm.signUp(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender,
      height: double.tryParse(_heightCtrl.text) ?? 175,
      weight: double.tryParse(_weightCtrl.text) ?? 70,
    );

    if (!mounted) return;

    if (success) {
      pushScreen(context, const VerificationScreen());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Đăng ký thất bại'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────
            const _RegistrationAppBar(),

            // ── Step header ──────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ProgressStepHeader(step: 1, total: 2, label: 'Create Account'),
            ),

            const SizedBox(height: 24),

            // ── Scrollable form ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _RegistrationHeadline(),
                    const SizedBox(height: 24),

                    // First Name + Last Name
                    Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const FormFieldLabel('Họ'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _lastNameCtrl,
                            onChanged: (_) => setState(() => _lastNameError = null),
                            decoration: InputDecoration(
                              hintText: 'Nguyễn',
                              errorText: _lastNameError,
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const FormFieldLabel('Tên'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _firstNameCtrl,
                            onChanged: (_) => setState(() => _firstNameError = null),
                            decoration: InputDecoration(
                              hintText: 'An',
                              errorText: _firstNameError,
                            ),
                          ),
                        ]),
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // Email
                    const FormFieldLabel('Email'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() => _emailError = null),
                      decoration: InputDecoration(
                        hintText: 'example@email.com',
                        errorText: _emailError,
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password
                    const FormFieldLabel('Mật khẩu'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePass,
                      onChanged: (_) => setState(() => _passwordError = null),
                      decoration: InputDecoration(
                        hintText: 'Ít nhất 6 ký tự',
                        errorText: _passwordError,
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscurePass = !_obscurePass),
                          icon: Icon(_obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined, size: 20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password
                    const FormFieldLabel('Xác nhận mật khẩu'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPassCtrl,
                      obscureText: _obscureConfirm,
                      onChanged: (_) => setState(() => _confirmPassError = null),
                      decoration: InputDecoration(
                        hintText: 'Nhập lại mật khẩu',
                        errorText: _confirmPassError,
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          icon: Icon(_obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined, size: 20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Phone
                    const FormFieldLabel('Số điện thoại'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() => _phoneError = null),
                      decoration: InputDecoration(
                        hintText: '0912 345 678',
                        errorText: _phoneError,
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Age + Gender
                    _AgeGenderRow(
                      ageCtrl: _ageCtrl,
                      gender: _gender,
                      onGenderChanged: (v) => setState(() => _gender = v!),
                    ),

                    const SizedBox(height: 16),

                    // Weight + Height
                    _WeightHeightRow(
                      weightCtrl: _weightCtrl,
                      heightCtrl: _heightCtrl,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Register button ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(children: [
                if (isLoading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                ],
                GradientButton(
                  label: isLoading ? 'Đang đăng ký…' : 'Register',
                  onPressed: isLoading ? null : _handleRegister,
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Đã có tài khoản? ',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  GestureDetector(
                    onTap: () => pushScreen(context, const LoginScreen()),
                    child: const Text('Đăng nhập',
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF00BFA5),
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widget: app bar ──────────────────────────────────────────────────────

class _RegistrationAppBar extends StatelessWidget {
  const _RegistrationAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(children: const [
        AppBackButton(),
        Spacer(),
        Text('Registration', style: AppTextStyles.heading3),
        Spacer(),
        SizedBox(width: 32),
      ]),
    );
  }
}

// ─── Sub-widget: headline ─────────────────────────────────────────────────────

class _RegistrationHeadline extends StatelessWidget {
  const _RegistrationHeadline();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
      Text('Tạo tài khoản mới', style: AppTextStyles.heading2),
      SizedBox(height: 6),
      Text(
        'Nhập thông tin để cá nhân hóa hành trình sức khoẻ của bạn.',
        style: AppTextStyles.body,
      ),
    ]);
  }
}

// ─── Sub-widget: Age + Gender row ────────────────────────────────────────────

class _AgeGenderRow extends StatelessWidget {
  const _AgeGenderRow({
    required this.ageCtrl,
    required this.gender,
    required this.onGenderChanged,
  });

  final TextEditingController ageCtrl;
  final String gender;
  final ValueChanged<String?> onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const FormFieldLabel('Tuổi'),
          const SizedBox(height: 8),
          TextField(
            controller: ageCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(),
          ),
        ]),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const FormFieldLabel('Giới tính'),
          const SizedBox(height: 8),
          GenderDropdown(value: gender, onChanged: onGenderChanged),
        ]),
      ),
    ]);
  }
}

// ─── Sub-widget: Weight + Height row ─────────────────────────────────────────

class _WeightHeightRow extends StatelessWidget {
  const _WeightHeightRow({required this.weightCtrl, required this.heightCtrl});

  final TextEditingController weightCtrl;
  final TextEditingController heightCtrl;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const FormFieldLabel('Cân nặng (kg)'),
          const SizedBox(height: 8),
          UnitTextField(controller: weightCtrl, unit: 'KG'),
        ]),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const FormFieldLabel('Chiều cao (cm)'),
          const SizedBox(height: 8),
          UnitTextField(controller: heightCtrl, unit: 'CM'),
        ]),
      ),
    ]);
  }
}
