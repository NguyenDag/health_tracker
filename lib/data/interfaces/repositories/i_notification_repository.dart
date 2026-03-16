import '../../../domain/entities/health_notification.dart';

abstract class INotificationRepository {
  Future<List<HealthNotification>> getNotifications ();
  Future<void> markAsRead(String id);
}