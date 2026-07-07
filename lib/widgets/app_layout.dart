import 'package:flutter/material.dart';

class CitizenNotificationItem {
  final int notificationId;
  final String title;
  final String content;
  final bool isRead;
  final DateTime? createdAt;

  CitizenNotificationItem({
    required this.notificationId,
    required this.title,
    required this.content,
    required this.isRead,
    this.createdAt,
  });

  factory CitizenNotificationItem.fromJson(Map<String, dynamic> json) {
    return CitizenNotificationItem(
      notificationId: json['notificationId'] ?? json['id'] ?? 0,
      title: json['title'] ?? 'Thông báo',
      content: json['content'] ?? json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
    );
  }
}

class AppLayout extends StatefulWidget {
  final Widget child;
  final int currentTabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback? onLogout;
  final VoidCallback? onNotificationTap;
  final Future<List<CitizenNotificationItem>> Function()? onLoadNotifications;
  final Future<void> Function(List<int> ids)? onMarkAsRead;
  final Future<void> Function()? onMarkAllAsRead;
  final String? userName;
  final int points;

  const AppLayout({
    super.key,
    required this.child,
    required this.currentTabIndex,
    required this.onTabChanged,
    this.onLogout,
    this.onNotificationTap,
    this.onLoadNotifications,
    this.onMarkAsRead,
    this.onMarkAllAsRead,
    this.userName,
    this.points = 0,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  List<CitizenNotificationItem> _notifications = [];
  bool _isLoadingNotifications = false;
  bool _showNotificationPopup = false;
  bool _hasInitialized = false;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _notificationBellKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  
  // State để theo dõi các notification được tích chọn
  final Set<int> _selectedNotificationIds = {};

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  int get selectedCount => _selectedNotificationIds.length;

  @override
  Widget build(BuildContext context) {
    // Load notifications on first build to show badge
    if (!_hasInitialized) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadNotifications();
      });
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final userName = widget.userName ?? 'hoang nhat le';
    final initials = _getInitials(userName);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.eco, color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Waste Collection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _buildNotificationBell(),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Color(0xFF10B981), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '★ ${widget.points} Điểm',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildUserDropdown(context, userName, initials),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationBell() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _notificationBellKey,
        onTap: _toggleNotificationPopup,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF64748B),
                size: 24,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleNotificationPopup() async {
    if (_showNotificationPopup) {
      _hideNotificationPopup();
    } else {
      // Reset selection khi mở popup mới
      _selectedNotificationIds.clear();
      await _loadNotifications();
      _showNotificationPopupWithOverlay();
    }
  }

  void _showNotificationPopupWithOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _showNotificationPopup = true);
  }

  void _hideNotificationPopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _selectedNotificationIds.clear();
    setState(() => _showNotificationPopup = false);
  }

  Size _getNotificationBellSize() {
    final RenderBox? renderBox = _notificationBellKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.size;
    }
    return const Size(44, 44);
  }

  OverlayEntry _createOverlayEntry() {
    final size = _getNotificationBellSize();

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _hideNotificationPopup,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: 400,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 8),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                child: _NotificationPopupContent(
                  notifications: _notifications,
                  isLoading: _isLoadingNotifications,
                  selectedIds: _selectedNotificationIds,
                  onClose: _hideNotificationPopup,
                  onViewAll: () {
                    _hideNotificationPopup();
                    widget.onNotificationTap?.call();
                  },
                  onMarkAsRead: _handleMarkAsRead,
                  onMarkAllAsRead: _handleMarkAllAsRead,
                  onSelectionChanged: (id, selected) {
                    setState(() {
                      if (selected) {
                        _selectedNotificationIds.add(id);
                      } else {
                        _selectedNotificationIds.remove(id);
                      }
                    });
                  },
                  onToggleSelectAll: () {
                    setState(() {
                      if (_selectedNotificationIds.length == _notifications.length) {
                        _selectedNotificationIds.clear();
                      } else {
                        _selectedNotificationIds.addAll(
                          _notifications.map((n) => n.notificationId),
                        );
                      }
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadNotifications() async {
    if (widget.onLoadNotifications == null) return;

    setState(() => _isLoadingNotifications = true);
    try {
      final notifications = await widget.onLoadNotifications!();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoadingNotifications = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingNotifications = false);
      }
    }
  }

  Future<void> _handleMarkAsRead(List<int> ids) async {
    if (widget.onMarkAsRead != null && ids.isNotEmpty) {
      await widget.onMarkAsRead!(ids);
      await _loadNotifications();
    }
  }

  Future<void> _handleMarkAllAsRead() async {
    if (widget.onMarkAllAsRead != null) {
      await widget.onMarkAllAsRead!();
      await _loadNotifications();
    }
  }

  Widget _buildUserDropdown(BuildContext context, String userName, String initials) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF10B981),
              child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Text(userName, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B), size: 20),
          ],
        ),
      ),
      onSelected: (value) {
        if (value == 'logout') widget.onLogout?.call();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'profile', child: Text('Trang cá nhân')),
        const PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
      ],
    );
  }

  Widget _buildSidebar() {
    final menuItems = [
      _SidebarItem(Icons.home_outlined, Icons.home, 'Trang chủ', 0),
      _SidebarItem(Icons.add_circle_outline, Icons.add_circle, 'Tạo Báo cáo', 1),
      _SidebarItem(Icons.card_giftcard_outlined, Icons.card_giftcard, 'Phần thưởng', 2),
      _SidebarItem(Icons.history_outlined, Icons.history, 'Lịch sử', 3),
    ];

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          ...menuItems.map((item) => _buildSidebarItem(item)),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(_SidebarItem item) {
    final isActive = widget.currentTabIndex == item.index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => widget.onTabChanged(item.index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF10B981) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? Colors.white : const Color(0xFF64748B),
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                item.label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF475569),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  _SidebarItem(this.icon, this.activeIcon, this.label, this.index);
}

class _NotificationPopupContent extends StatelessWidget {
  final List<CitizenNotificationItem> notifications;
  final bool isLoading;
  final Set<int> selectedIds;
  final VoidCallback onClose;
  final VoidCallback onViewAll;
  final Future<void> Function(List<int> ids) onMarkAsRead;
  final Future<void> Function() onMarkAllAsRead;
  final void Function(int id, bool selected) onSelectionChanged;
  final VoidCallback onToggleSelectAll;

  const _NotificationPopupContent({
    required this.notifications,
    required this.isLoading,
    required this.selectedIds,
    required this.onClose,
    required this.onViewAll,
    required this.onMarkAsRead,
    required this.onMarkAllAsRead,
    required this.onSelectionChanged,
    required this.onToggleSelectAll,
  });

  int get _unreadCount => notifications.where((n) => !n.isRead).length;
  bool get _allSelected => selectedIds.length == notifications.length && notifications.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 520),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications, color: Color(0xFF10B981), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông báo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (_unreadCount > 0)
                      Text(
                        '$_unreadCount thông báo chưa đọc',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              // Nút đóng
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close, size: 18, color: Color(0xFF64748B)),
                  ),
                ),
              ),
            ],
          ),
          // Hàng chứa các nút hành động
          if (selectedIds.isNotEmpty || notifications.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // Checkbox chọn tất cả
                GestureDetector(
                  onTap: onToggleSelectAll,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _allSelected ? const Color(0xFF10B981).withValues(alpha: 0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _allSelected ? Icons.check_box : Icons.check_box_outline_blank,
                          size: 18,
                          color: _allSelected ? const Color(0xFF10B981) : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Chọn tất cả',
                          style: TextStyle(
                            fontSize: 12,
                            color: _allSelected ? const Color(0xFF10B981) : Colors.grey.shade600,
                            fontWeight: _allSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Nút đánh dấu đã đọc các mục đã chọn
                if (selectedIds.isNotEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      await onMarkAsRead(selectedIds.toList());
                    },
                    icon: const Icon(Icons.done, size: 16),
                    label: Text('Đọc (${selectedIds.length})'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                // Nút đọc tất cả
                if (_unreadCount > 0 && selectedIds.isEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      await onMarkAllAsRead();
                    },
                    icon: const Icon(Icons.done_all, size: 16),
                    label: const Text('Đọc tất cả'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF10B981)),
        ),
      );
    }

    if (notifications.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_off_outlined, size: 40, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              'Không có thông báo nào',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Các thông báo sẽ xuất hiện ở đây',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isSelected = selectedIds.contains(notification.notificationId);
              return _NotificationItemTile(
                notification: notification,
                isSelected: isSelected,
                onTap: () async {
                  if (!notification.isRead) {
                    await onMarkAsRead([notification.notificationId]);
                  }
                  onViewAll();
                },
                onSelectionChanged: (selected) {
                  onSelectionChanged(notification.notificationId, selected);
                },
                onMarkAsRead: () async {
                  await onMarkAsRead([notification.notificationId]);
                },
              );
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            border: Border(top: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onViewAll,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Xem tất cả thông báo',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Color(0xFF10B981), size: 18),
                    if (_unreadCount > 0) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_unreadCount mới',
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationItemTile extends StatelessWidget {
  final CitizenNotificationItem notification;
  final bool isSelected;
  final VoidCallback onTap;
  final void Function(bool selected) onSelectionChanged;
  final VoidCallback onMarkAsRead;

  const _NotificationItemTile({
    required this.notification,
    required this.isSelected,
    required this.onTap,
    required this.onSelectionChanged,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox để tích chọn
            GestureDetector(
              onTap: () => onSelectionChanged(!isSelected),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade400,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Icon thông báo
            _buildIcon(),
            const SizedBox(width: 12),
            // Nội dung thông báo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.content,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notification.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(notification.createdAt!),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    final content = notification.content.toLowerCase();
    final title = notification.title.toLowerCase();

    if (content.contains('report') || content.contains('báo cáo') || title.contains('báo cáo')) {
      icon = Icons.report_problem;
      color = const Color(0xFFF59E0B);
    } else if (content.contains('reward') || content.contains('điểm') || content.contains('quà')) {
      icon = Icons.card_giftcard;
      color = const Color(0xFF8B5CF6);
    } else if (content.contains('collection') || content.contains('thu gom')) {
      icon = Icons.local_shipping;
      color = const Color(0xFF3B82F6);
    } else if (content.contains('accept') || content.contains('chấp nhận')) {
      icon = Icons.check_circle;
      color = const Color(0xFF10B981);
    } else if (content.contains('reject') || content.contains('từ chối')) {
      icon = Icons.cancel;
      color = const Color(0xFFEF4444);
    } else {
      icon = Icons.notifications;
      color = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
