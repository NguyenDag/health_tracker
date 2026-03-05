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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Text("Notification History",
              style: AppTextStyles.h2),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: "All"),
              Tab(text: "Alerts"),
              Tab(text: "Reminders"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(viewModel.notifications),
            _buildList(viewModel.alerts),
            _buildList(viewModel.reminders),
          ],
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
        return NotificationTile(
          icon: n.icon,
          iconColor: n.iconColor,
          title: n.title,
          subtitle: n.subtitle,
          time: n.time,
          badge: n.badge,
        );
      },
    );
  }
}