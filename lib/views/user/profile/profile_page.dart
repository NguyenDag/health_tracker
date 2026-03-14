import 'package:flutter/material.dart';
import 'package:health_tracker/views/user/threshold/threshold_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../admin/main/admin_main_layout_page.dart';
import '../../auth/login_page.dart';
import '../notification/notification_history_screen.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';

import 'package:provider/provider.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../domain/entities/user_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, child) {
        final user = authVM.currentUser;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildModernProfileHeader(user),
              const SizedBox(height: 24),
              _buildHealthSummaryCard(user),
              const SizedBox(height: 32),
              _buildSectionHeader('TÀI KHOẢN'),
              _buildAccountGroup(context),
              const SizedBox(height: 24),
              _buildSectionHeader('HỖ TRỢ & PHÁP LÝ'),
              _buildSupportGroup(),
              const SizedBox(height: 40),
              _buildLogoutButton(context, authVM),
              const SizedBox(height: 80), // Fab space
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernProfileHeader(UserProfile? user) {
    final displayName = (user?.fullName != null && user!.fullName.trim().isNotEmpty) ? user.fullName : 'Guest User';
    final initials = (user?.firstName != null && user!.firstName!.isNotEmpty) 
        ? user.firstName![0].toUpperCase() 
        : (displayName != 'Guest User' ? displayName[0].toUpperCase() : '?');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withAlpha(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4),
                  ],
                ),
                child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user?.phone ?? 'Chưa cập nhật số điện thoại',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withAlpha(200)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  user?.role.toUpperCase() ?? 'USER',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSummaryCard(UserProfile? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Chiều cao', '${user?.height ?? '--'}', 'cm'),
          Container(width: 1, height: 40, color: Colors.grey.withAlpha(40)),
          _buildSummaryItem('Cân nặng', '${user?.weight ?? '--'}', 'kg'),
          Container(width: 1, height: 40, color: Colors.grey.withAlpha(40)),
          _buildSummaryItem('Độ tuổi', '${_calculateAge(user?.dob)}', 'tuổi'),
        ],
      ),
    );
  }

  int _calculateAge(DateTime? dob) {
    if (dob == null) return 0;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  Widget _buildSummaryItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
              TextSpan(
                text: ' $unit',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyles.label.copyWith(
            letterSpacing: 1.5,
            color: AppColors.textPrimary.withAlpha(150),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountGroup(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            Icons.person_outline_rounded,
            'Chỉnh sửa hồ sơ',
            AppColors.primary,
            AppColors.primary.withAlpha(20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
          ),
          _buildDivider(),
          _buildListTile(
            Icons.lock_reset_rounded,
            'Đổi mật khẩu',
            Colors.orange,
            Colors.orange.withAlpha(20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            ),
          ),
          _buildDivider(),
          _buildListTile(
            Icons.monitor_heart_outlined,
            'Ngưỡng sức khỏe',
            Colors.redAccent,
            Colors.redAccent.withAlpha(20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ThresholdsScreen()),
            ),
          ),
          _buildDivider(),
          _buildListTile(
            Icons.notifications_active_outlined,
            'Cài đặt thông báo',
            Colors.blue,
            Colors.blue.withAlpha(20),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportGroup() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            Icons.verified_user_outlined,
            'Chính sách bảo mật',
            Colors.teal,
            Colors.teal.withAlpha(20),
          ),
          _buildDivider(),
          _buildListTile(
            Icons.help_outline_rounded,
            'Trung tâm trợ giúp',
            Colors.indigo,
            Colors.indigo.withAlpha(20),
          ),
          _buildDivider(),
          _buildListTile(
            Icons.info_outline_rounded,
            'Phiên bản ứng dụng',
            Colors.grey,
            Colors.grey.withAlpha(20),
            subtitle: 'v2.5.0 (Build 301)',
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 64, endIndent: 20, color: Colors.grey.withAlpha(30));
  }

  Widget _buildListTile(
    IconData icon,
    String title,
    Color iconColor,
    Color bgColor, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.subtitle.copyWith(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.bodySmall.copyWith(fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
    );
  }

  Widget _buildAdminSwitchButton(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withAlpha(50)),
          ),
          child: TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminMainLayoutPage()),
            ),
            icon: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.primary),
            label: const Text(
              'Chuyển sang chế độ Admin',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthViewModel authVM) {
    return Column(
      children: [
        _buildAdminSwitchButton(context),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => _showLogoutDialog(context, authVM),
            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
            label: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.redAccent.withAlpha(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authVM.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
