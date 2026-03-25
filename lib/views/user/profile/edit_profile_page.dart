import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../viewmodels/auth_viewmodel.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  DateTime? _dob;
  String _gender = 'male';

  // --- Validation error messages ---
  String? _firstNameError;
  String? _lastNameError;
  String? _phoneError;
  String? _heightError;
  String? _weightError;
  String? _dobError;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().currentUser;
    if (user != null) {
      _firstNameCtrl.text = user.firstName ?? '';
      _lastNameCtrl.text = user.lastName ?? '';
      _phoneCtrl.text = user.phone ?? '';
      _heightCtrl.text = user.height?.toString() ?? '';
      _weightCtrl.text = user.weight?.toString() ?? '';
      _dob = user.dob;
      _gender = user.gender ?? 'male';
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
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

  bool _validate() {
    bool valid = true;
    setState(() {
      // First name
      _firstNameError = _firstNameCtrl.text.trim().isEmpty
          ? 'Vui lòng nhập tên'
          : null;
      if (_firstNameError != null) valid = false;

      // Last name
      _lastNameError = _lastNameCtrl.text.trim().isEmpty
          ? 'Vui lòng nhập họ'
          : null;
      if (_lastNameError != null) valid = false;

      // Phone
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

      // DOB / Age
      if (_dob == null) {
        _dobError = 'Vui lòng chọn ngày sinh';
        valid = false;
      } else {
        final age = _calculateAge(_dob!);
        if (age < 0 || age > 100) {
          _dobError = 'Tuổi phải từ 0 đến 100';
          valid = false;
        } else {
          _dobError = null;
        }
      }

      // Weight
      final weight = double.tryParse(_weightCtrl.text);
      if (weight == null || weight <= 0 || weight > 500) {
        _weightError = 'Cân nặng không hợp lệ (0-500kg)';
        valid = false;
      } else {
        _weightError = null;
      }

      // Height
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1995),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dob) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_validate()) return;

    final authVM = context.read<AuthViewModel>();
    final user = authVM.currentUser;
    if (user == null) return;

    final updatedUser = user.copyWith(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender,
      height: double.tryParse(_heightCtrl.text),
      weight: double.tryParse(_weightCtrl.text),
      dob: _dob,
    );

    final success = await authVM.updateProfile(updatedUser);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVM.errorMessage ?? 'Cập nhật thất bại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Chỉnh sửa hồ sơ', style: AppTextStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : const Text('Lưu thay đổi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildProfileAvatar(context),
            const SizedBox(height: 32),
            _buildSection(
              'Thông tin cá nhân',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField('Họ', _lastNameCtrl,
                          errorText: _lastNameError),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField('Tên', _firstNameCtrl,
                          errorText: _firstNameError),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDateField('Ngày sinh', _dob, errorText: _dobError),
                const SizedBox(height: 20),
                _buildGenderField(),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Liên hệ & Chỉ số',
              children: [
                _buildTextField(
                  'Số điện thoại',
                  _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  errorText: _phoneError,
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Chiều cao (cm)',
                        _heightCtrl,
                        keyboardType: TextInputType.number,
                        errorText: _heightError,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        'Cân nặng (kg)',
                        _weightCtrl,
                        keyboardType: TextInputType.number,
                        errorText: _weightError,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, {required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textPrimary.withAlpha(150),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final initials =
    (user?.firstName != null && user!.firstName!.isNotEmpty)
        ? user.firstName![0].toUpperCase()
        : '?';

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration:
          const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              initials,
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4)
            ],
          ),
          child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 18),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        TextInputType? keyboardType,
        String? errorText,
      }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? AppColors.error : Colors.grey.withAlpha(80),
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
              ),
            ),
            errorText: errorText,
            errorStyle: const TextStyle(fontSize: 11, color: AppColors.error),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, {String? errorText}) {
    final hasError = errorText != null;
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  date != null
                      ? DateFormat('dd/MM/yyyy').format(date)
                      : 'Chọn ngày sinh',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: date != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
              height: 1,
              color: hasError ? AppColors.error : Colors.grey.withAlpha(80)),
          if (hasError) ...[
            const SizedBox(height: 4),
            Text(
              errorText,
              style: const TextStyle(fontSize: 11, color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới tính',
          style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildGenderOption('Nam', 'male'),
            const SizedBox(width: 24),
            _buildGenderOption('Nữ', 'female'),
            const SizedBox(width: 24),
            _buildGenderOption('Khác', 'other'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, String value) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : Colors.grey.withAlpha(50),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 6,
              backgroundColor:
              isSelected ? AppColors.primary : Colors.transparent,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
                fontSize: 14,
                fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400),
          ),
        ],
      ),
    );
  }
}