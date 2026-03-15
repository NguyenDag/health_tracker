import 'package:flutter/material.dart';
import 'package:health_tracker/views/user/logs/history_record_page.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../home/home_page.dart';
import '../notification/notification_history_screen.dart';
import '../stats/stats_page.dart';
import '../logs/logs_page.dart';
import '../profile/profile_page.dart';
import '../../../domain/enums/health_type.dart';

class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({super.key});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  int _currentIndex = 0;
  HealthType? _statsType;
  late List<Widget> _pages;

  final List<String> _titles = [
    'Health Dashboard',
    'Health Trends',
    'Record History',
    'Profile & Settings',
  ];

  void _onItemTapped(int index, {HealthType? type}) {
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        _statsType = type;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      HomePage(onNavigateToTab: _onItemTapped),
      StatsPage(initialType: _statsType),
      const HistoryScreen(),
      const ProfilePage(),
    ];
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
