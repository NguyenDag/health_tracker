import 'package:flutter/material.dart';

enum NotificationType { alert, reminder }

class HealthNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime triggeredAt;
  final NotificationType type;
  final bool isRead;
  final String? badge;

  HealthNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.triggeredAt,
    required this.type,
    required this.isRead,
    this.badge,
  });

  factory HealthNotification.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] ?? 'reminder';

    return HealthNotification(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      triggeredAt: DateTime.parse(json['triggered_at']),
      type: typeString == 'alert'
          ? NotificationType.alert
          : NotificationType.reminder,
      isRead: json['is_read'] ?? false,
      badge: json['badge'],
    );
  }

  /// UI helpers
  IconData get icon =>
      type == NotificationType.alert
          ? Icons.warning_amber_rounded
          : Icons.notifications_none;

  Color get iconColor =>
      type == NotificationType.alert
          ? Colors.red
          : Colors.blue;

  String get time {
    return "${triggeredAt.hour.toString().padLeft(2, '0')}:${triggeredAt.minute.toString().padLeft(2, '0')}";
  }
}