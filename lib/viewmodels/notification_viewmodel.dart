import 'package:flutter/material.dart';
import '../data/implementations/repositories/notification_repository.dart';
import '../domain/entities/health_notification.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<HealthNotification> _notifications = [];

  List<HealthNotification> get notifications => _notifications;

  HealthNotification? _pendingBanner;
  HealthNotification? get pendingBanner => _pendingBanner;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    final previous = List<HealthNotification>.from(_notifications);
    _notifications = await _repository.getNotifications();

    // 👇 Tìm thông báo mới chưa đọc để hiện banner
    final newUnread = _notifications.where((n) {
      final isNew = !previous.any((p) => p.id == n.id);
      return isNew && !n.isRead;
    }).toList();

    if (newUnread.isNotEmpty) {
      _pendingBanner = newUnread.first;
    }

    _isLoading = false;
    notifyListeners();
  }

  List<HealthNotification> get alerts =>
      _notifications
          .where((n) => n.type == NotificationType.alert)
          .toList();

  List<HealthNotification> get reminders =>
      _notifications
          .where((n) => n.type == NotificationType.reminder)
          .toList();

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);

    final index = _notifications.indexWhere((n) => n.id == id);

    if (index != -1) {
      _notifications[index] = HealthNotification(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        triggeredAt: _notifications[index].triggeredAt,
        type: _notifications[index].type,
        badge: _notifications[index].badge,
        isRead: true,
        userId: _notifications[index].userId,
      );
      notifyListeners();
    }
  }

  void clearBanner() { // 👈 thêm
    _pendingBanner = null;
    notifyListeners();
  }
}