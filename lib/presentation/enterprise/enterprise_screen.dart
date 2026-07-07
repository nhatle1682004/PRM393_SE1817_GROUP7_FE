import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/dashboard_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/collectors_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/collection_requests_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/assignments_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/reports_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/feedbacks_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/notifications_view.dart';

class EnterpriseScreen extends StatefulWidget {
  const EnterpriseScreen({super.key});

  @override
  State<EnterpriseScreen> createState() => _EnterpriseScreenState();
}

class _EnterpriseScreenState extends State<EnterpriseScreen> {
  int _currentIndex = 0;
  EnterpriseStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;
  UserProfile? _userProfile;
  List<EnterpriseNotification> _notifications = [];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _showNotificationPopup = false;

  final List<_EnterpriseMenuItem> _menuItems = [
    _EnterpriseMenuItem(Icons.dashboard_outlined, Icons.dashboard, 'Trang tổng quan', 0),
    _EnterpriseMenuItem(Icons.local_shipping_outlined, Icons.local_shipping, 'Yêu cầu thu gom', 1),
    _EnterpriseMenuItem(Icons.people_outline, Icons.people, 'Nhân viên', 2),
    _EnterpriseMenuItem(Icons.assignment_outlined, Icons.assignment, 'Phân công', 3),
    _EnterpriseMenuItem(Icons.report_outlined, Icons.report, 'Báo cáo', 4),
    _EnterpriseMenuItem(Icons.feedback_outlined, Icons.feedback, 'Phản hồi', 5),
    _EnterpriseMenuItem(Icons.notifications_outlined, Icons.notifications, 'Thông báo', 6),
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await AuthService.getProfile();
    if (mounted) setState(() => _userProfile = profile);
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stats = await EnterpriseApiService.getEnterpriseDashboard();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await EnterpriseApiService.getNotifications();
      if (mounted) {
        setState(() => _notifications = notifications);
      }
    } catch (_) {}
  }

  Future<void> _handleLogout() async {
    final authService = AuthService();
    await authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _onMenuTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _toggleNotificationPopup() async {
    if (_showNotificationPopup) {
      _hideNotificationPopup();
    } else {
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
    setState(() => _showNotificationPopup = false);
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _hideNotificationPopup,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: 380,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 8),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                child: _NotificationPopupContent(
                  notifications: _notifications,
                  onClose: _hideNotificationPopup,
                  onViewAll: () {
                    _hideNotificationPopup();
                    _onMenuTap(6);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      drawer: isMobile ? _buildDrawer() : null,
      body: Row(
        children: [
          if (!isMobile) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(isMobile),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    final currentMenu = _menuItems[_currentIndex];

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(currentMenu.activeIcon, color: const Color(0xFF10B981), size: 22),
          ),
          const SizedBox(width: 14),
          Text(
            currentMenu.label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          _buildHeaderActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Row(
      children: [
        if (_stats != null) ...[
          _buildStatBadge(
            icon: Icons.people_alt_outlined,
            value: _stats!.totalCollectors.toString(),
            label: 'Nhân viên',
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(width: 10),
          _buildStatBadge(
            icon: Icons.local_shipping_outlined,
            value: _stats!.totalCollections.toString(),
            label: 'Yêu cầu',
            color: const Color(0xFF10B981),
          ),
          const SizedBox(width: 10),
          _buildStatBadge(
            icon: Icons.report_problem_outlined,
            value: _stats!.pendingReports.toString(),
            label: 'Chờ duyệt',
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 16),
        ],
        _buildNotificationBell(unreadCount),
        const SizedBox(width: 16),
        _buildUserProfile(),
      ],
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    final displayName = _userProfile?.fullName ?? 'Enterprise';
    final initials = displayName.isNotEmpty
        ? displayName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : 'E';

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF10B981),
              child: Text(
                initials,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              displayName,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF64748B)),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business, color: Color(0xFF10B981), size: 18),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enterprise', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('Doanh nghiệp', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Đăng xuất', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') _handleLogout();
      },
    );
  }

  Widget _buildNotificationBell(int unreadCount) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleNotificationPopup,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, color: Color(0xFF64748B), size: 22),
              if (unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _menuItems.map((item) => _buildSidebarItem(item)).toList(),
            ),
          ),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EcoWaste',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Quản lý doanh nghiệp',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(_EnterpriseMenuItem item) {
    final isActive = _currentIndex == item.index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onMenuTap(item.index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF10B981) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive
                  ? [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF475569),
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _handleLogout,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.logout, color: Color(0xFFEF4444), size: 22),
                SizedBox(width: 14),
                Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 14),
                const Text(
                  'EcoWaste',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'Quản lý doanh nghiệp',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isActive = _currentIndex == index;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF10B981) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive ? Colors.white : const Color(0xFF64748B),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isActive ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    selected: isActive,
                    selectedTileColor: const Color(0xFFDCFCE7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () {
                      Navigator.pop(context);
                      _onMenuTap(index);
                    },
                  ),
                );
              },
            ),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
            ),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              _handleLogout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _stats == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF10B981), strokeWidth: 3),
            SizedBox(height: 20),
            Text(
              'Đang tải dữ liệu...',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _stats == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Không thể tải dữ liệu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadStats,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadStats();
        await _loadNotifications();
      },
      color: const Color(0xFF10B981),
      child: switch (_currentIndex) {
        0 => DashboardView(stats: _stats, onRefresh: _loadStats),
        1 => const CollectionRequestsView(),
        2 => const CollectorsView(),
        3 => const AssignmentsView(),
        4 => const ReportsView(),
        5 => const FeedbacksView(),
        6 => const NotificationsView(),
        _ => DashboardView(stats: _stats, onRefresh: _loadStats),
      },
    );
  }
}

class _EnterpriseMenuItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  _EnterpriseMenuItem(this.icon, this.activeIcon, this.label, this.index);
}

class _NotificationPopupContent extends StatelessWidget {
  final List<EnterpriseNotification> notifications;
  final VoidCallback onClose;
  final VoidCallback onViewAll;

  const _NotificationPopupContent({
    required this.notifications,
    required this.onClose,
    required this.onViewAll,
  });

  int get _unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      constraints: const BoxConstraints(maxHeight: 480),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications, color: Color(0xFF10B981), size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông báo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
              if (_unreadCount > 0)
                Text('$_unreadCount thông báo chưa đọc', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
          const Spacer(),
          if (_unreadCount > 0)
            TextButton(
              onPressed: () async {
                await EnterpriseApiService.markAllNotificationsRead();
              },
              child: const Text('Đọc tất cả', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.close, size: 16, color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(Icons.notifications_off_outlined, size: 36, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          const Text('Không có thông báo nào', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text('Các thông báo sẽ xuất hiện ở đây', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.take(5).length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(notification: notification, onTap: () { onClose(); onViewAll(); });
            },
          ),
        ),
        if (notifications.length > 5)
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
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Xem tất cả thông báo', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w600, fontSize: 14)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Color(0xFF10B981), size: 16),
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

class _NotificationTile extends StatelessWidget {
  final EnterpriseNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = notification.content.toLowerCase();
    IconData icon;
    Color color;

    if (content.contains('report') || content.contains('báo cáo')) {
      icon = Icons.report_problem;
      color = const Color(0xFFF59E0B);
    } else if (content.contains('feedback') || content.contains('phản hồi')) {
      icon = Icons.feedback;
      color = const Color(0xFFEC4899);
    } else if (content.contains('collector') || content.contains('nhân viên')) {
      icon = Icons.person;
      color = const Color(0xFF10B981);
    } else if (content.contains('collection') || content.contains('thu gom')) {
      icon = Icons.local_shipping;
      color = const Color(0xFF3B82F6);
    } else {
      icon = Icons.notifications;
      color = const Color(0xFF64748B);
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
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
                            fontSize: 14,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
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
                          decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.content,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notification.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(_formatTime(notification.createdAt!), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
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

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
    if (difference.inHours < 24) return '${difference.inHours} giờ trước';
    if (difference.inDays < 7) return '${difference.inDays} ngày trước';
    return '${date.day}/${date.month}/${date.year}';
  }
}
