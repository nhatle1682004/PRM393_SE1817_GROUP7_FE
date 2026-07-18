import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/config/api_config.dart';

class CitizenNotification {
  final int notificationId;
  final String title;
  final String content;
  final bool isRead;
  final DateTime? createdAt;
  final String? type;

  CitizenNotification({
    required this.notificationId,
    required this.title,
    required this.content,
    required this.isRead,
    this.createdAt,
    this.type,
  });

  factory CitizenNotification.fromJson(Map<String, dynamic> json) {
    return CitizenNotification(
      notificationId: json['notificationId'] ?? json['id'] ?? 0,
      title: json['title'] ?? 'Thông báo',
      content: json['content'] ?? json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'].toString()) 
          : null,
      type: json['type'],
    );
  }
}

class CitizenNotificationScreen extends StatefulWidget {
  const CitizenNotificationScreen({super.key});

  @override
  State<CitizenNotificationScreen> createState() => _CitizenNotificationScreenState();
}

class _CitizenNotificationScreenState extends State<CitizenNotificationScreen> {
  List<CitizenNotification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get(ApiConfig.notifications);
      final data = response.data;

      if (data is List) {
        _notifications = data
            .map((e) => CitizenNotification.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markAsRead(CitizenNotification notification) async {
    if (notification.isRead) return;

    try {
      await ApiService.put(ApiConfig.markNotificationRead(notification.notificationId));
      _loadNotifications();
    } catch (e) {
      if (mounted) {
        CherryToast.error(
          title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text('Lỗi: $e'),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await ApiService.put(ApiConfig.notificationsReadAll);
      _loadNotifications();
      if (mounted) {
        CherryToast.success(
          title: const Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
          description: const Text('Đã đánh dấu tất cả thông báo là đã đọc'),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        CherryToast.error(
          title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text('Lỗi: $e'),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    }
  }

  void _showConfirmMarkAllReadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.done_all, color: Color(0xFF10B981), size: 28),
            SizedBox(width: 12),
            Text('Đánh dấu đã đọc'),
          ],
        ),
        content: const Text('Bạn có muốn đánh dấu tất cả thông báo là đã đọc không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _markAllAsRead();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Container(
      color: const Color(0xFFF4F6F8),
      child: Column(
        children: [
          _buildHeader(unreadCount),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader(int unreadCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notifications, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông báo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      unreadCount > 0 ? '$unreadCount thông báo chưa đọc' : 'Tất cả đã được đọc',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (unreadCount > 0)
                TextButton.icon(
                  onPressed: () => _showConfirmMarkAllReadDialog(context),
                  icon: const Icon(Icons.done_all, color: Colors.white, size: 18),
                  label: const Text('Đọc tất cả', style: TextStyle(color: Colors.white)),
                ),
            ],
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

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Không thể tải thông báo', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadNotifications,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Chưa có thông báo nào', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: const Color(0xFF10B981),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) => _buildNotificationCard(_notifications[index]),
      ),
    );
  }

  Widget _buildNotificationCard(CitizenNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead ? Colors.transparent : const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _markAsRead(notification),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(notification),
                const SizedBox(width: 14),
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
                                fontSize: 15,
                                fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
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
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            notification.createdAt != null 
                                ? _formatTime(notification.createdAt!) 
                                : '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(CitizenNotification notification) {
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
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
