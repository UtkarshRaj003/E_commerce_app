import 'package:e_commerce_app/common/models/notification_model.dart';
import 'package:e_commerce_app/core/network/dio_client.dart';

class NotificationRepository {
  final DioClient dioClient;

  NotificationRepository(this.dioClient);

  Future<List<AppNotification>> getNotifications() async {
    final res = await dioClient.get('/notifications');
    return (res.data as List).map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<void> markRead(String id) async {
    await dioClient.put('/notifications/$id');
  }
}
