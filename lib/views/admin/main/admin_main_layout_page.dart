import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../dashboard/admin_dashboard_page.dart';
import '../users/admin_users_page.dart';
import '../thresholds/admin_thresholds_page.dart';
import '../ai_config/admin_ai_config_page.dart';

class AdminMainLayoutPage extends StatefulWidget {
  const AdminMainLayoutPage({super.key});

  @override
  State<AdminMainLayoutPage> createState() => _AdminMainLayoutPageState();
}

class _AdminMainLayoutPageState extends State<AdminMainLayoutPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const AdminUsersPage(),
    const SizedBox.shrink(), // index 2: navigated via push
  ];

  final List<String> _titles = [
    'Admin Dashboard',
    'User Management',
  ];

  // Sidebar indices:
  //   0 = Dashboard, 1 = User Management, 2 = Config Threshold (push), 3 = AI Config (push)
  void _onDrawerItemTapped(int index) {
    Navigator.pop(context); // close drawer
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminThresholdsPage()));
      return;
    }
    if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAiConfigPage()));
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(_titles[_currentIndex], style: AppTextStyles.h3),
        centerTitle: true,
      ),
      drawer: _AdminSideBar(
        currentIndex: _currentIndex,
        onItemTapped: _onDrawerItemTapped,
      ),
      body: _pages[_currentIndex],
    );
  }
}

class _AdminSideBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onItemTapped;

  const _AdminSideBar({
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text('Admin Portal', style: AppTextStyles.h3.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text('admin@healthtracker.com',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildItem(
              context,
              index: 0,
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
            ),
            _buildItem(
              context,
              index: 1,
              icon: Icons.people_outline,
              label: 'User Management',
            ),
            _buildItem(
              context,
              index: 2,
              icon: Icons.tune_outlined,
              label: 'Config Threshold',
            ),
            _buildItem(
              context,
              index: 3,
              icon: Icons.smart_toy_outlined,
              label: 'AI Config',
            ),
            const Spacer(),
            const Divider(height: 1),
            _buildLogoutItem(context),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, {required int index, required IconData icon, required String label}) {
    final isSelected = currentIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        label,
        style: AppTextStyles.subtitle.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primaryLight.withAlpha(60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: () => onItemTapped(index),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: AppColors.error, size: 22),
      title: Text('Logout', style: AppTextStyles.subtitle.copyWith(color: AppColors.error)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        Navigator.pop(context); // close drawer
        // TODO: implement logout logic
      },
    );
  }
}
