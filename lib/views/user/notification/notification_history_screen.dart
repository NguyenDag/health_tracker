import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:health_tracker/views/user/notification/widgets/notification_tile.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/health_notification.dart';
import '../../../viewmodels/notification_viewmodel.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<NotificationViewModel>().loadNotifications()
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NotificationViewModel>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Lịch Sử Thông Báo", style: AppTextStyles.h2),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Tất Cả"),
              Tab(text: "Cảnh Báo"),
              Tab(text: "Nhắc Nhở"),
            ],
          ),
        ),
        body: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _buildList(context, viewModel.notifications),
            _buildList(context, viewModel.alerts),
            _buildList(context, viewModel.reminders),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<HealthNotification> items) {
    final viewModel = context.read<NotificationViewModel>();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final n = items[index];

        return NotificationTile(
          icon: n.icon,
          iconColor: n.iconColor,
          title: n.title,
          subtitle: n.body,
          time: n.time,
          badge: n.badge,
          isRead: n.isRead,
          isFirst: index == 0,
          isLast: index == items.length - 1,
          onTap: () async {
            if (!n.isRead) {
              await viewModel.markAsRead(n.id);
            }
          },
        );
      },
    );
  }
}