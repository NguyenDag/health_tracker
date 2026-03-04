import '../../../domain/entities/health_notification.dart';

abstract class NotificationRepository {
  List<HealthNotification> getNotifications();
}