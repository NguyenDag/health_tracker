import 'package:flutter/material.dart';
import 'package:health_tracker/views/user/threshold/threshold_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../admin/main/admin_main_layout_page.dart';
import '../notification/notification_history_screen.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 32),
          _buildSectionHeader('ACCOUNT'),
          _buildAccountGroup(context),
          const SizedBox(height: 24),
          _buildSectionHeader('SUPPORT & LEGAL'),
          _buildSupportGroup(),
          const SizedBox(height: 32),
          _buildAdminSwitchButton(context),
          const SizedBox(height: 12),
          _buildLogoutButton(),
          const SizedBox(height: 80), // Fab space
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, size: 40, color: AppColors.primary),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('John Doe', style: AppTextStyles.h1),
        const SizedBox(height: 4),
        Text('+1 (555) 012-3456', style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyles.label.copyWith(letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildAccountGroup(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Column(
        children: [
          _buildListTile(
            Icons.person_outline,
            'Edit Profile',
            Colors.blue,
            Colors.blue[50]!,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
          ),
          const Divider(height: 1, indent: 64, endIndent: 16),
          _buildListTile(
            Icons.lock_outline,
            'Change Password',
            Colors.purple,
            Colors.purple[50]!,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            ),
          ),
          const Divider(height: 1, indent: 64, endIndent: 16),
          _buildListTile(
            Icons.watch_outlined,
            'Connected Devices',
            Colors.indigo,
            Colors.indigo[50]!,
            subtitle: 'Smartwatch, Scale',
          ),
          _buildListTile(
            Icons.monitor_heart_outlined,
            'Health Thresholds',
            Colors.redAccent,
            Colors.redAccent.withAlpha(40),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ThresholdsScreen()),
            ),
          ),
          const Divider(height: 1, indent: 64, endIndent: 16),
          _buildListTile(
            Icons.notifications_none_outlined,
            'Notification Preferences',
            Colors.orange,
            Colors.orange[50]!,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportGroup() {
    return Card(
      color: Colors.white,
      child: Column(
        children: [
          _buildListTile(
            Icons.shield_outlined,
            'Privacy Policy',
            AppColors.primary,
            AppColors.primaryLight.withAlpha(50),
          ),
          const Divider(height: 1, indent: 64, endIndent: 16),
          _buildListTile(
            Icons.info_outline,
            'App Version',
            Colors.grey[700]!,
            Colors.grey[200]!,
            subtitle: 'v2.4.1 (Build 204)',
          ),
        ],
      ),
    );
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
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.bodySmall)
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    );
  }

  Widget _buildAdminSwitchButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminMainLayoutPage()),
        ),
        icon: const Icon(
          Icons.admin_panel_settings_outlined,
          color: Colors.white,
        ),
        label: const Text(
          'Switch to Admin View',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.red.withAlpha(50)),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
