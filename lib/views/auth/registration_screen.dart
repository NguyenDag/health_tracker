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
        _phoneError = 'Số điện thoại không hợp lệ';
        valid = false;
      } else {
        _phoneError = null;
      }

      // DOB validation
      if (_selectedDob == null) {
        _dobError = 'Vui lòng chọn ngày sinh';
        valid = false;
      } else {
        final now = DateTime.now();
        if (_selectedDob!.isAfter(now)) {
          _dobError = 'Ngày sinh không được chọn trong tương lai';
          valid = false;
        } else {
          final age = _calculateAge(_selectedDob!);
          if (age > 120) {
            _dobError = 'Tuổi không hợp lệ (tối đa 120)';
            valid = false;
          } else {
            _dobError = null;
          }
        }
      }

      // Weight validation
      final weight = double.tryParse(_weightCtrl.text);
      if (weight == null || weight <= 0) {
        _weightError = 'Cân nặng phải là số dương';
        valid = false;
      } else if (weight > 500) {
        _weightError = 'Cân nặng không được vượt quá 500kg';
        valid = false;
      } else {
        _weightError = null;
      }

      // Height validation
      final height = double.tryParse(_heightCtrl.text);
      if (height == null || height <= 0) {
        _heightError = 'Chiều cao phải là số dương';
        valid = false;
      } else if (height > 300) {
        _heightError = 'Chiều cao không được vượt quá 300cm';
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
      pushScreen(
        context,
        VerificationScreen(email: _emailCtrl.text.trim()),
      );
    } else {
      setState(() {
        final error = vm.errorMessage ?? 'Đăng ký thất bại';
        if (error.contains('đã được đăng ký')) {
          _emailError = error;
        } else {
          _formError = error;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AuthBackground(
        child: CustomScrollView(
          slivers: [
            // ── Top Section ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                children: const [
                  _RegistrationAppBar(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: ProgressStepHeader(
                      step: 1,
                      total: 2,
                      label: 'Tạo tài khoản',
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),

            // ── Form Section ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _RegistrationHeadline(),
                    const SizedBox(height: 24),

                    // First Name + Last Name
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                decoration: _buildInputDecoration(
                                  hint: 'Nguyễn',
                                  error: _lastNameError,
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
                                decoration: _buildInputDecoration(
                                  hint: 'An',
                                  error: _firstNameError,
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
                      decoration: _buildInputDecoration(
                        hint: 'example@email.com',
                        error: _emailError,
                        prefix: Icons.email_outlined,
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
                      decoration: _buildInputDecoration(
                        hint: 'Ít nhất 6 ký tự',
                        error: _passwordError,
                        prefix: Icons.lock_outline,
                        suffix: IconButton(
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: const Color(0xFF00BFA5),
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
                      decoration: _buildInputDecoration(
                        hint: 'Nhập lại mật khẩu',
                        error: _confirmPassError,
                        prefix: Icons.lock_outline,
                        suffix: IconButton(
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: const Color(0xFF00BFA5),
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
                      decoration: _buildInputDecoration(
                        hint: '0912 345 678',
                        error: _phoneError,
                        prefix: Icons.phone_outlined,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // DOB + Gender
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                    color: const Color(0xFFF7F9FC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _dobError != null
                                          ? Colors.red.shade400
                                          : const Color(0xFFE8ECF4),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18,
                                        color: _selectedDob == null
                                            ? Colors.grey
                                            : const Color(0xFF00BFA5),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _selectedDob == null
                                              ? 'Chọn ngày'
                                              : DateFormat(
                                                  'dd/MM/yyyy',
                                                ).format(_selectedDob!),
                                          style: TextStyle(
                                            color: _selectedDob == null
                                                ? Colors.grey
                                                : Colors.black87,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // ── Register button Section ────────────────────────────────
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                    const SizedBox(height: 24),
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
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    String? error,
    IconData? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      errorText: error,
      prefixIcon: prefix != null
          ? Icon(prefix, size: 20, color: Colors.grey)
          : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8ECF4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00BFA5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
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
