import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

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

    try {
      await EnterpriseApiService.markNotificationRead(notification.notificationId);
      _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await EnterpriseApiService.markAllNotificationsRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đánh dấu tất cả là đã đọc'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _loadNotifications();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
      padding: const EdgeInsets.all(16),
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
                color: const Color(0xFFEF4444),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            selectedColor: const Color(0xFF10B981).withOpacity(0.2),
            checkmarkColor: const Color(0xFF10B981),
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
            selectedColor: const Color(0xFF10B981).withOpacity(0.2),
            checkmarkColor: const Color(0xFF10B981),
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
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(_error ?? 'Lỗi không xác định'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNotifications,
            child: const Text('Thử lại'),
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
          Icon(
            _showUnreadOnly ? Icons.notifications_off : Icons.notifications_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _showUnreadOnly ? 'Không có thông báo chưa đọc' : 'Không có thông báo nào',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
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
          color: notification.isRead ? Colors.grey.shade200 : const Color(0xFF10B981).withOpacity(0.3),
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
                  color: color.withOpacity(0.1),
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
