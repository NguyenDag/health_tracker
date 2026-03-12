import 'package:flutter/material.dart';
import 'package:health_tracker/views/user/logs/history_record_page.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../home/home_page.dart';
import '../notification/notification_history_screen.dart';
import '../stats/stats_page.dart';
import '../profile/profile_page.dart';
class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({super.key});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onNavigateToTab: _onItemTapped),
      const StatsPage(),
      const HistoryScreen(),
      const ProfilePage(),
    ];
  }

  final List<String> _titles = [
    'Health Dashboard',
    'Health Trends',
    'Record History',
    'Profile & Settings',
  ];

  void _onItemTapped(int index) {
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationHistoryScreen(),
            ),
          );
        },
        onAvatarTapped: () {
          // Navigate to profile or show account settings
        },
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
