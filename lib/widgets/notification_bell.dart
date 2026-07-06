import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/services/notification_service.dart';

class NotificationBell extends StatefulWidget {
  final VoidCallback onTap;

  const NotificationBell({super.key, required this.onTap});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _service = NotificationService();
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _service.getNotifications();
      if (mounted)
        setState(() => _unread = items.where((n) => !n.isRead).length);
    } catch (_) {
      // Notification badge must not break role shells.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: widget.onTap,
          icon: const Icon(Icons.notifications_outlined),
        ),
        if (_unread > 0)
          Positioned(
            right: 6,
            top: 8,
            child: Badge(label: Text(_unread > 99 ? '99+' : '$_unread')),
          ),
      ],
    );
  }
}
