import '../../../domain/entities/health_notification.dart';
import '../../interfaces/repositories/inotification_repository.dart';
import '../api/api_sample.dart';

class NotificationRepository implements INotificationRepository {
  final ApiSample _api = ApiSample();

  @override
  Future<List<HealthNotification>> getNotifications() async{
    
    final data = await _api.getNotifications();
    print("data: $data");
    return data.map((e) {
      return HealthNotification.fromJson(e);
    }).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    await _api.markNotificationAsRead(id);
  }
}