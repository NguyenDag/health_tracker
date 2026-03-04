import 'package:flutter/material.dart';

enum NotificationType { alert, reminder }

class HealthNotification {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final NotificationType type;
  final String? badge;

  HealthNotification({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
    this.badge,
  });
}