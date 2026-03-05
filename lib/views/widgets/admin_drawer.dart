import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class AdminDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;

  const AdminDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin Portal',
                  style: AppTextStyles.h2.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            index: 0,
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.people_outline,
            title: 'User Management',
            index: 1,
            context: context,
          ),
          _buildDrawerItem(
            icon: Icons.settings_applications_outlined,
            title: 'Global Thresholds',
            index: 2,
            context: context,
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            index: 3,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        title,
        style: AppTextStyles.subtitle.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primaryLight.withAlpha(50),
      onTap: () {
        onItemSelected(index);
        Navigator.pop(context); // Close the drawer
      },
    );
  }
}
