import 'package:flutter/material.dart';
import '../../widgets/admin_drawer.dart';
import '../../widgets/custom_app_bar.dart';
import '../dashboard/admin_dashboard_page.dart';
import '../users/admin_users_page.dart';

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
    const Center(child: Text('Global Thresholds Page (Placeholder)')),
    const Center(child: Text('Settings Page (Placeholder)')),
  ];

  final List<String> _titles = [
    'Admin Dashboard',
    'User Management',
    'Global Thresholds',
    'Settings',
  ];

  void _onDrawerItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _titles[_currentIndex],
        onNotificationTapped: () {
          // Handle admin notifications
        },
        // In the admin sidebar layout, we might just let the default hamburger icon appear
        // or we could customize it further. If we want a hamburger menu on the left,
        // AppBar provides it automatically when a Drawer is present.
      ),
      drawer: AdminDrawer(
        currentIndex: _currentIndex,
        onItemSelected: _onDrawerItemTapped,
      ),
      body: _pages[_currentIndex],
    );
  }
}
