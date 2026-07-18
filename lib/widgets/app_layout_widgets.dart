import 'package:flutter/material.dart';
import 'app_layout.dart';

class NotificationPopupContent extends StatelessWidget {
  final List<CitizenNotificationItem> notifications;
  final bool isLoading;
  final Set<int> selectedIds;
  final VoidCallback onClose, onViewAll, onToggleSelectAll;
  final Future<void> Function(List<int> ids) onMarkAsRead;
  final Future<void> Function() onMarkAllAsRead;
  final void Function(int id, bool selected) onSelectionChanged;

  const NotificationPopupContent({super.key, required this.notifications, required this.isLoading, required this.selectedIds, required this.onClose, required this.onViewAll, required this.onMarkAsRead, required this.onMarkAllAsRead, required this.onSelectionChanged, required this.onToggleSelectAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, constraints: const BoxConstraints(maxHeight: 520),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildHeader(),
        if (isLoading) const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())
        else if (notifications.isEmpty) const Padding(padding: EdgeInsets.all(40), child: Text('Không có thông báo'))
        else Expanded(child: ListView.builder(itemCount: notifications.length, itemBuilder: (c, i) => _tile(notifications[i]))),
        _buildFooter(),
      ]),
    );
  }

  Widget _buildHeader() => Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))), child: Row(children: [
    const Text('Thông báo', style: TextStyle(fontWeight: FontWeight.bold)),
    const Spacer(),
    IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onClose),
  ]));

  Widget _tile(CitizenNotificationItem n) => ListTile(
    leading: Checkbox(value: selectedIds.contains(n.notificationId), onChanged: (v) => onSelectionChanged(n.notificationId, v!)),
    title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 14)),
    subtitle: Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
    onTap: () { if (!n.isRead) onMarkAsRead([n.notificationId]); onViewAll(); },
  );

  Widget _buildFooter() => InkWell(onTap: onViewAll, child: Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))), child: const Center(child: Text('Xem tất cả', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)))));
}
