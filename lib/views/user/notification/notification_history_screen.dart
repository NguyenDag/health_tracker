import 'package:flutter/material.dart';
import 'package:health_tracker/views/user/notification/widgets/notification_tile.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/health_notification.dart';
import '../../../viewmodels/notification_viewmodel.dart';

class NotificationHistoryScreen extends StatelessWidget {
  NotificationHistoryScreen({super.key});

  final NotificationViewModel viewModel = NotificationViewModel();

  @override
  Widget build(BuildContext context) {
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
        body: FutureBuilder(
          future: viewModel.loadNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                _buildList(viewModel.notifications),
                _buildList(viewModel.alerts),
                _buildList(viewModel.reminders),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<HealthNotification> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final n = items[index];
        print("isRead ${n.isRead}");

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