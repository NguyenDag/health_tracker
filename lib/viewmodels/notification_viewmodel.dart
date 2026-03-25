import '../data/implementations/repositories/notification_repository.dart';
import '../domain/entities/health_notification.dart';

class NotificationViewModel {
  final NotificationRepository _repository =
  NotificationRepository();

  List<HealthNotification> notifications = [];

  Future<void> loadNotifications() async {
    notifications = await _repository.getNotifications();
  }

  List<HealthNotification> get alerts =>
      notifications
          .where((n) => n.type == NotificationType.alert)
          .toList();

  List<HealthNotification> get reminders =>
      notifications
          .where((n) => n.type == NotificationType.reminder)
          .toList();

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);

    final index = notifications.indexWhere((n) => n.id == id);

    if (index != -1) {
      notifications[index] = HealthNotification(
        id: notifications[index].id,
        title: notifications[index].title,
        body: notifications[index].body,
        triggeredAt: notifications[index].triggeredAt,
        type: notifications[index].type,
        badge: notifications[index].badge,
        isRead: true,
        userId: notifications[index].userId,
      );
    }
  }
}
