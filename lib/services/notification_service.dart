import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/notification_item.dart';
import 'package:waste_collection_management_system/services/api_service.dart';

class NotificationService {
  Future<List<NotificationItem>> getNotifications() async {
    final response = await ApiService.get(ApiConfig.notifications);
    if (response.data is List) {
      return (response.data as List)
          .map(
            (item) => NotificationItem.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }
    return const [];
  }

  Future<void> markAsRead(int id) async =>
      ApiService.put(ApiConfig.markNotificationRead(id));
  Future<void> markAllAsRead() async =>
      ApiService.put(ApiConfig.notificationsReadAll);
}
