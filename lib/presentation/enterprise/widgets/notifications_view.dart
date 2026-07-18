import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';

class NotificationsView extends StatefulWidget {
  final VoidCallback? onRefreshParent;
  const NotificationsView({super.key, this.onRefreshParent});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<EnterpriseNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await EnterpriseApiService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
        // Đồng bộ lại với parent nếu cần
        widget.onRefreshParent?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(EnterpriseNotification notification) async {
    if (notification.isRead) return;

    // Cập nhật UI ngay lập tức (Optimistic UI)
    setState(() {
      final index = _notifications.indexWhere((n) => n.notificationId == notification.notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });

    try {
      await EnterpriseApiService.markNotificationRead(notification.notificationId);
      // Gọi parent để cập nhật số lượng thông báo trên chuông
      widget.onRefreshParent?.call();
    } catch (e) {
      // Nếu lỗi thì rollback lại trạng thái cũ
      _loadNotifications();
      if (mounted) {
        CherryToast.error(
          title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text('Không thể đánh dấu: ${e.toString()}'),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    }
  }

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0) return;

    // Tạm thời đánh dấu tất cả là đã đọc trong UI
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });

    try {
      await EnterpriseApiService.markAllNotificationsRead();
      widget.onRefreshParent?.call();
      if (mounted) {
        CherryToast.success(
          title: const Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
          description: const Text('Đã đánh dấu tất cả là đã đọc'),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    } catch (e) {
      _loadNotifications();
      if (mounted) {
        CherryToast.error(
          title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text('Lỗi: ${e.toString()}'),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    }
  }

  List<EnterpriseNotification> get _filteredNotifications {
    if (_showUnreadOnly) {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications;
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilterBar(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_filteredNotifications.length} thông báo',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          if (_unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_unreadCount chưa đọc',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Đọc tất cả'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          IconButton(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            color: const Color(0xFF64748B),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Tất cả'),
            selected: !_showUnreadOnly,
            onSelected: (selected) {
              setState(() {
                _showUnreadOnly = !selected;
              });
            },
            selectedColor: const Color(0xFF10B981).withValues(alpha: 0.15),
            checkmarkColor: const Color(0xFF10B981),
            labelStyle: TextStyle(
              color: !_showUnreadOnly ? const Color(0xFF10B981) : const Color(0xFF64748B),
              fontWeight: !_showUnreadOnly ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: !_showUnreadOnly ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Chưa đọc'),
            selected: _showUnreadOnly,
            onSelected: (selected) {
              setState(() {
                _showUnreadOnly = selected;
              });
            },
            selectedColor: const Color(0xFF10B981).withValues(alpha: 0.15),
            checkmarkColor: const Color(0xFF10B981),
            labelStyle: TextStyle(
              color: _showUnreadOnly ? const Color(0xFF10B981) : const Color(0xFF64748B),
              fontWeight: _showUnreadOnly ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: _showUnreadOnly ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return _buildNotificationsList();
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = _filteredNotifications[index];
        return _NotificationCard(
          notification: notification,
          onTap: () => _markAsRead(notification),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Đã xảy ra lỗi',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error ?? 'Không thể tải dữ liệu',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _showUnreadOnly ? Icons.notifications_off : Icons.notifications_outlined,
              size: 48,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _showUnreadOnly ? 'Không có thông báo chưa đọc' : 'Không có thông báo nào',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showUnreadOnly ? 'Tất cả thông báo đã được đọc' : 'Thông báo sẽ hiển thị tại đây',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final EnterpriseNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon();
    final color = _getColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead ? Colors.grey.shade200 : const Color(0xFF10B981).withValues(alpha: 0.3),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? 'Thông báo',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
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
                    const SizedBox(height: 6),
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(notification.createdAt!),
                            style: TextStyle(
                              fontSize: 12,
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
      ),
    );
  }

  IconData _getIcon() {
    final content = notification.content.toLowerCase();
    if (content.contains('report') || content.contains('báo cáo')) {
      return Icons.report_problem;
    } else if (content.contains('feedback') || content.contains('phản hồi')) {
      return Icons.feedback;
    } else if (content.contains('collector') || content.contains('nhân viên')) {
      return Icons.person;
    } else if (content.contains('collection') || content.contains('thu gom')) {
      return Icons.local_shipping;
    }
    return Icons.notifications;
  }

  Color _getColor() {
    final content = notification.content.toLowerCase();
    if (content.contains('report') || content.contains('báo cáo')) {
      return const Color(0xFFF59E0B);
    } else if (content.contains('feedback') || content.contains('phản hồi')) {
      return const Color(0xFFEC4899);
    } else if (content.contains('collector') || content.contains('nhân viên')) {
      return const Color(0xFF10B981);
    } else if (content.contains('collection') || content.contains('thu gom')) {
      return const Color(0xFF3B82F6);
    }
    return const Color(0xFF64748B);
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${date.day}/${date.month}/${date.year}';
  }
}
