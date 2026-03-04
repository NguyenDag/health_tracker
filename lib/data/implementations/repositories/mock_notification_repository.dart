import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/health_notification.dart';
import '../../interfaces/repositories/notification_repository.dart';class MockNotificationRepository implements NotificationRepository {
  @override
  List<HealthNotification> getNotifications() {
    return [
      /// ================= ALERTS =================
      HealthNotification(
        icon: Icons.favorite,
        iconColor: AppColors.error,
        title: "High Blood Pressure Alert",
        subtitle:
        "Your recent reading of 150/95 mmHg is above your safe range.",
        time: "10 mins ago",
        type: NotificationType.alert,
        badge: "High Priority",
      ),
      HealthNotification(
        icon: Icons.monitor_heart,
        iconColor: AppColors.error,
        title: "Abnormal Heart Rate",
        subtitle:
        "Heart rate detected at 120 bpm while resting.",
        time: "1 hr ago",
        type: NotificationType.alert,
        badge: "Urgent",
      ),
      HealthNotification(
        icon: Icons.air,
        iconColor: AppColors.error,
        title: "Low Oxygen Level",
        subtitle:
        "SpO2 dropped below 92%. Please check immediately.",
        time: "3 hrs ago",
        type: NotificationType.alert,
        badge: "Warning",
      ),

      /// ================= REMINDERS =================
      HealthNotification(
        icon: Icons.monitor_weight,
        iconColor: AppColors.primary,
        title: "Time to Weigh Yourself",
        subtitle:
        "It has been 3 days since your last weight check.",
        time: "5 hrs ago",
        type: NotificationType.reminder,
      ),
      HealthNotification(
        icon: Icons.water_drop,
        iconColor: AppColors.primary,
        title: "Hydration Reminder",
        subtitle:
        "Drink at least 1.5–2 liters of water daily.",
        time: "Today",
        type: NotificationType.reminder,
      ),
      HealthNotification(
        icon: Icons.directions_walk,
        iconColor: AppColors.primary,
        title: "Daily Activity Goal",
        subtitle:
        "You are 2,000 steps away from today’s target.",
        time: "Yesterday",
        type: NotificationType.reminder,
      ),
      HealthNotification(
        icon: Icons.lightbulb,
        iconColor: AppColors.primary,
        title: "Health Tip",
        subtitle:
        "Reducing sodium intake can help lower blood pressure.",
        time: "Yesterday",
        type: NotificationType.reminder,
      ),
      HealthNotification(
        icon: Icons.bedtime,
        iconColor: AppColors.primary,
        title: "Sleep Reminder",
        subtitle:
        "Aim for 7–8 hours of sleep for better heart health.",
        time: "2 days ago",
        type: NotificationType.reminder,
      ),
    ];
  }
}