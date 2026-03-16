import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  DateTime? _selectedDob = DateTime(2000, 1, 1);
  final _weightCtrl = TextEditingController(text: '70');
  final _heightCtrl = TextEditingController(text: '175');
  String _gender = 'Nam';
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // Error messages
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPassError;
  String? _phoneError;
  String? _dobError;
  String? _weightError;
  String? _heightError;
  String? _formError;

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl,
      _lastNameCtrl,
      _emailCtrl,
      _passwordCtrl,
      _confirmPassCtrl,
      _phoneCtrl,
      _weightCtrl,
      _heightCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Validation ──────────────────────────────────────────────────────
  bool _validate() {
    bool valid = true;
    setState(() {
      _formError = null; // Clear overall form error on new attempt
      _firstNameError = _firstNameCtrl.text.trim().isEmpty
          ? 'Vui lòng nhập tên'
          : null;
      _lastNameError = _lastNameCtrl.text.trim().isEmpty
          ? 'Vui lòng nhập họ'
          : null;
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

      final phone = _phoneCtrl.text.trim();
      if (phone.isEmpty) {
        _phoneError = 'Vui lòng nhập số điện thoại';
        valid = false;
      } else if (!RegExp(r'^(03|05|07|08|09)\d{8}$').hasMatch(phone)) {
        _phoneError = 'Số điện thoại không hợp lệ (VD: 0912345678)';
        valid = false;
      } else {
        _phoneError = null;
      }

      // DOB / Age calculation
      if (_selectedDob == null) {
        _dobError = 'Vui lòng chọn ngày sinh';
        valid = false;
      } else {
        final age = _calculateAge(_selectedDob!);
        if (age < 0 || age > 100) {
          _dobError = 'Tuổi phải từ 0 đến 100';
          valid = false;
        } else {
          _dobError = null;
        }
      }

      // Weight validation
      final weight = double.tryParse(_weightCtrl.text);
      if (weight == null || weight <= 0 || weight > 500) {
        _weightError = 'Cân nặng không hợp lệ (0-500kg)';
        valid = false;
      } else {
        _weightError = null;
      }

      // Height validation
      final height = double.tryParse(_heightCtrl.text);
      if (height == null || height <= 0 || height > 300) {
        _heightError = 'Chiều cao không hợp lệ (0-300cm)';
        valid = false;
      } else {
        _heightError = null;
      }
    });
    return valid;
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  // ── Show Date Picker ───────────────────────────────────────────────
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF00BFA5),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
        _dobError = null;
      });
    }
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
      dob: _selectedDob!,
    );

    if (!mounted) return;

    if (success) {
      pushScreen(context, const VerificationScreen());
    } else {
      setState(() {
        _formError = vm.errorMessage ?? 'Đăng ký thất bại';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AuthBackground(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────────────
            const _RegistrationAppBar(),

            // ── Step header ──────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ProgressStepHeader(
                step: 1,
                total: 2,
                label: 'Tạo tài khoản',
              ),
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FormFieldLabel('Họ'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _lastNameCtrl,
                                onChanged: (_) =>
                                    setState(() => _lastNameError = null),
                                decoration: InputDecoration(
                                  hintText: 'Nguyễn',
                                  errorText: _lastNameError,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FormFieldLabel('Tên'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _firstNameCtrl,
                                onChanged: (_) =>
                                    setState(() => _firstNameError = null),
                                decoration: InputDecoration(
                                  hintText: 'An',
                                  errorText: _firstNameError,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

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
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
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
                      onChanged: (_) =>
                          setState(() => _confirmPassError = null),
                      decoration: InputDecoration(
                        hintText: 'Nhập lại mật khẩu',
                        errorText: _confirmPassError,
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
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

                    // DOB + Gender
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FormFieldLabel('Ngày sinh'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _selectDate(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _dobError != null
                                          ? Colors.red.shade400
                                          : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18,
                                        color: _selectedDob == null
                                            ? Colors.grey
                                            : Colors.black87,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _selectedDob == null
                                            ? 'Chọn ngày'
                                            : DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(_selectedDob!),
                                        style: TextStyle(
                                          color: _selectedDob == null
                                              ? Colors.grey
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_dobError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    left: 12,
                                  ),
                                  child: Text(
                                    _dobError!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FormFieldLabel('Giới tính'),
                              const SizedBox(height: 8),
                              GenderDropdown(
                                value: _gender,
                                onChanged: (v) => setState(() => _gender = v!),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Weight + Height
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FormFieldLabel('Cân nặng (kg)'),
                              const SizedBox(height: 8),
                              UnitTextField(
                                controller: _weightCtrl,
                                unit: 'KG',
                                onChanged: (_) =>
                                    setState(() => _weightError = null),
                              ),
                              if (_weightError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    left: 12,
                                  ),
                                  child: Text(
                                    _weightError!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FormFieldLabel('Chiều cao (cm)'),
                              const SizedBox(height: 8),
                              UnitTextField(
                                controller: _heightCtrl,
                                unit: 'CM',
                                onChanged: (_) =>
                                    setState(() => _heightError = null),
                              ),
                              if (_heightError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    left: 12,
                                  ),
                                  child: Text(
                                    _heightError!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Register button ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  // ── General Form Error ──────────────────────────────────
                  if (_formError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formError!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  GradientButton(
                    label: isLoading ? '' : 'Đăng ký',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _handleRegister,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Đã có tài khoản? ',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () => pushScreen(context, const LoginScreen()),
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF00BFA5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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

// ─── Sub-widget: app bar ──────────────────────────────────────────────────────

class _RegistrationAppBar extends StatelessWidget {
  const _RegistrationAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: const [
          AppBackButton(),
          Spacer(),
          Text('Đăng ký', style: AppTextStyles.heading3),
          Spacer(),
          SizedBox(width: 32),
        ],
      ),
    );
  }
}

// ─── Sub-widget: headline ─────────────────────────────────────────────────────

class _RegistrationHeadline extends StatelessWidget {
  const _RegistrationHeadline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tạo tài khoản mới', style: AppTextStyles.heading2),
        const SizedBox(height: 6),
        const Text(
          'Nhập thông tin để cá nhân hóa hành trình sức khoẻ của bạn.',
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}
