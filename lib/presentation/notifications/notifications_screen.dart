import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/notification_item.dart';
import 'package:waste_collection_management_system/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  bool _loading = true;
  List<NotificationItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _service.getNotifications();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          TextButton(
            onPressed: () async {
              await _service.markAllAsRead();
              await _load();
            },
            child: const Text('Đọc tất cả'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _items
                  .map(
                    (item) => ListTile(
                      leading: Icon(
                        item.isRead
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                      ),
                      title: Text(
                        item.title.isEmpty ? 'Thông báo' : item.title,
                      ),
                      subtitle: Text(item.message),
                      trailing: item.isRead
                          ? null
                          : TextButton(
                              onPressed: () async {
                                await _service.markAsRead(item.notificationId);
                                await _load();
                              },
                              child: const Text('Đọc'),
                            ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
