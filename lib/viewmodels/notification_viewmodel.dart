import '../data/implementations/repositories/mock_notification_repository.dart';
import '../data/interfaces/repositories/notification_repository.dart';
import '../domain/entities/health_notification.dart';

class NotificationViewModel {
  final NotificationRepository _repository =
  MockNotificationRepository();

  late final List<HealthNotification> notifications;

  NotificationViewModel() {
    notifications = _repository.getNotifications();
  }

  List<HealthNotification> get alerts =>
      notifications
          .where((n) => n.type == NotificationType.alert)
          .toList();

  List<HealthNotification> get reminders =>
      notifications
          .where((n) => n.type == NotificationType.reminder)
          .toList();
}