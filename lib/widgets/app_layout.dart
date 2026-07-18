import 'package:flutter/material.dart';
import 'app_layout_widgets.dart';

class CitizenNotificationItem {
  final int notificationId;
  final String title, content;
  final bool isRead;
  final DateTime? createdAt;
  CitizenNotificationItem({required this.notificationId, required this.title, required this.content, required this.isRead, this.createdAt});
  factory CitizenNotificationItem.fromJson(Map<String, dynamic> json) => CitizenNotificationItem(notificationId: json['notificationId'] ?? json['id'] ?? 0, title: json['title'] ?? 'Thông báo', content: json['content'] ?? json['message'] ?? '', isRead: json['isRead'] ?? false, createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null);
}

class AppLayout extends StatefulWidget {
  final Widget child;
  final int currentTabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback? onLogout, onNotificationTap;
  final Future<List<CitizenNotificationItem>> Function()? onLoadNotifications;
  final Future<void> Function(List<int> ids)? onMarkAsRead;
  final Future<void> Function()? onMarkAllAsRead;
  final String? userName;
  final int points;

  const AppLayout({super.key, required this.child, required this.currentTabIndex, required this.onTabChanged, this.onLogout, this.onNotificationTap, this.onLoadNotifications, this.onMarkAsRead, this.onMarkAllAsRead, this.userName, this.points = 0});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  List<CitizenNotificationItem> _notifications = [];
  bool _isLoading = false, _hasInit = false;
  final Set<int> _selectedIds = {};
  OverlayEntry? _overlay;
  final _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    if (!_hasInit) { _hasInit = true; WidgetsBinding.instance.addPostFrameCallback((_) => _load()); }
    return Scaffold(
      body: Column(children: [
        _buildHeader(),
        Expanded(child: Row(children: [_buildSidebar(), Expanded(child: widget.child)])),
      ]),
    );
  }

  Widget _buildHeader() => Container(
    height: 70, padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
    child: Row(children: [
      const Icon(Icons.eco, color: Colors.green), const SizedBox(width: 12), const Text('Waste Collection', style: TextStyle(fontWeight: FontWeight.bold)),
      const Spacer(),
      CompositedTransformTarget(link: _link, child: IconButton(icon: const Icon(Icons.notifications_none), onPressed: _togglePopup)),
      const SizedBox(width: 16),
      Text('★ ${widget.points} Điểm', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      const SizedBox(width: 16),
      _buildUserMenu(),
    ]),
  );

  Widget _buildUserMenu() => PopupMenuButton(
    child: CircleAvatar(radius: 16, child: Text(widget.userName?[0] ?? 'U')),
    onSelected: (v) { if (v == 'logout') widget.onLogout?.call(); },
    itemBuilder: (c) => [const PopupMenuItem(value: 'profile', child: Text('Hồ sơ')), const PopupMenuItem(value: 'logout', child: Text('Đăng xuất'))],
  );

  Widget _buildSidebar() => Container(width: 250, color: Colors.white, child: Column(children: [
    _item(Icons.home, 'Trang chủ', 0),
    _item(Icons.add_circle, 'Tạo Báo cáo', 1),
    _item(Icons.card_giftcard, 'Phần thưởng', 2),
    _item(Icons.history, 'Lịch sử', 3),
  ]));

  Widget _item(IconData i, String l, int idx) => ListTile(
    leading: Icon(i, color: widget.currentTabIndex == idx ? Colors.green : Colors.grey),
    title: Text(l, style: TextStyle(color: widget.currentTabIndex == idx ? Colors.green : Colors.black)),
    onTap: () => widget.onTabChanged(idx),
  );

  void _togglePopup() {
    if (_overlay != null) { _overlay!.remove(); _overlay = null; return; }
    _overlay = OverlayEntry(builder: (c) => Stack(children: [
      GestureDetector(onTap: _togglePopup, behavior: HitTestBehavior.opaque, child: Container(color: Colors.transparent)),
      Positioned(width: 400, child: CompositedTransformFollower(link: _link, offset: const Offset(-350, 50), child: Material(elevation: 8, borderRadius: BorderRadius.circular(16), child: NotificationPopupContent(notifications: _notifications, isLoading: _isLoading, selectedIds: _selectedIds, onClose: _togglePopup, onViewAll: () { _togglePopup(); widget.onNotificationTap?.call(); }, onMarkAsRead: (ids) async { await widget.onMarkAsRead?.call(ids); _load(); }, onMarkAllAsRead: () async { await widget.onMarkAllAsRead?.call(); _load(); }, onSelectionChanged: (id, s) => setState(() => s ? _selectedIds.add(id) : _selectedIds.remove(id)), onToggleSelectAll: () {})))),
    ]));
    Overlay.of(context).insert(_overlay!);
  }

  Future<void> _load() async {
    if (widget.onLoadNotifications == null) return;
    setState(() => _isLoading = true);
    try { final res = await widget.onLoadNotifications!(); if (mounted) setState(() { _notifications = res; _isLoading = false; }); }
    catch (_) { if (mounted) setState(() => _isLoading = false); }
  }
}
