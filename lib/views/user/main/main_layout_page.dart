import 'package:flutter/material.dart';
import 'package:health_tracker/views/user/logs/history_record_page.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../viewmodels/notification_viewmodel.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../home/home_page.dart';
import '../notification/notification_history_screen.dart';
import '../notification/widgets/notification_banner.dart';
import '../stats/stats_page.dart';
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
  OverlayEntry? _overlayEntry;

  final List<String> _titles = [
    'Health Dashboard',
    'Health Trends',
    'Record History',
    'Profile & Settings',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<NotificationViewModel>().loadNotifications();
      // 👇 Hiện banner sau khi load lần đầu
      if (mounted) _checkAndShowBanner();
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void _checkAndShowBanner() {
    final notifVM = context.read<NotificationViewModel>();
    if (notifVM.pendingBanner != null) {
      _showBanner(notifVM.pendingBanner!);
      notifVM.clearBanner();
    }
  }

  void _showBanner(notification) {
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: NotificationBanner(
          notification: notification,
          onDismiss: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
          onTap: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
            _openNotifications();
          },
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _onItemTapped(int index, {HealthType? type}) {
    setState(() {
      _currentIndex = index;
      if (index == 1) _statsType = type;
    });
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationHistoryScreen(),
      ),
    );
    if (context.mounted) {
      await context.read<NotificationViewModel>().loadNotifications();
      // 👇 Hiện banner nếu có thông báo mới sau khi quay về
      if (mounted) _checkAndShowBanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👇 Lắng nghe pendingBanner thay đổi real-time
    final notifVM = context.watch<NotificationViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (notifVM.pendingBanner != null && mounted) {
        _showBanner(notifVM.pendingBanner!);
        notifVM.clearBanner();
      }
    });

    _pages = [
      HomePage(onNavigateToTab: _onItemTapped),
      StatsPage(initialType: _statsType),
      const HistoryScreen(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: _titles[_currentIndex],
        onNotificationTapped: _openNotifications,
        unreadCount: notifVM.unreadCount,
        onAvatarTapped: () {},
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}