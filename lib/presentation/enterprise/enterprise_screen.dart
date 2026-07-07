import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';
import 'package:waste_collection_management_system/services/storage_service.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/collectors_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/collection_requests_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/assignments_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/reports_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/feedbacks_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/notifications_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/profile_view.dart';

class EnterpriseScreen extends StatefulWidget {
  const EnterpriseScreen({super.key});

  @override
  State<EnterpriseScreen> createState() => _EnterpriseScreenState();
}

class _EnterpriseScreenState extends State<EnterpriseScreen> {
  int _currentIndex = 0;
  int? _pendingAssignmentReportId; // Lưu requestId cần phân công
  EnterpriseStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;
  UserProfile? _userProfile;
  List<EnterpriseNotification> _notifications = [];
  List<EnterpriseCollectionRequest> _collectionRequests = [];
  List<EnterpriseReport> _recentReports = [];

  final List<_EnterpriseMenuItem> _menuItems = [
    _EnterpriseMenuItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Trang tổng quan', 0),
    _EnterpriseMenuItem(Icons.local_shipping_outlined, Icons.local_shipping_rounded, 'Yêu cầu thu gom', 1),
    _EnterpriseMenuItem(Icons.badge_outlined, Icons.badge_rounded, 'Nhân viên', 2),
    _EnterpriseMenuItem(Icons.assignment_ind_outlined, Icons.assignment_ind_rounded, 'Phân công', 3),
    _EnterpriseMenuItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Báo cáo', 4),
    _EnterpriseMenuItem(Icons.forum_outlined, Icons.forum_rounded, 'Phản hồi', 5),
    _EnterpriseMenuItem(Icons.notifications_none_rounded, Icons.notifications_rounded, 'Thông báo', 6),
    _EnterpriseMenuItem(Icons.account_circle_outlined, Icons.account_circle_rounded, 'Hồ sơ', 7),
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadUserProfile();
    _loadNotifications();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final profile = await AuthService.getProfile();
    final districtId = profile?.managedDistrictId;
    try {
      final results = await Future.wait([
        EnterpriseApiService.getCollectionRequests(),
        districtId != null
          ? EnterpriseApiService.getReportsByDistrict(districtId)
          : EnterpriseApiService.getReports(),
      ]);
      
      final requests = results[0] as List<EnterpriseCollectionRequest>;
      final reports = results[1] as List<EnterpriseReport>;
      
      if (mounted) {
        setState(() {
          _collectionRequests = requests;
          _recentReports = reports.take(5).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadUserProfile() async {
    final profile = await AuthService.getProfile();
    if (mounted) setState(() => _userProfile = profile);
  }

  // Callback khi báo cáo được duyệt - chuyển sang trang phân công
  void _onReportAccepted(int requestId) {
    debugPrint('_onReportAccepted called with requestId: $requestId');
    setState(() {
      _pendingAssignmentReportId = requestId;
      _currentIndex = 3; // Chuyển sang tab Phân công
    });
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

  void _showNotificationDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileLayout = screenWidth < 768;

    if (isMobileLayout) {
      _showMobileNotificationSheet();
    } else {
      _showDesktopNotificationPopup();
    }
  }

  void _showDesktopNotificationPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      barrierDismissible: true,
      builder: (dialogContext) => _DesktopNotificationPopup(
        notifications: _notifications,
        onMarkAllRead: _markAllAsRead,
        onMarkSingleRead: _markSingleAsRead,
        onViewAll: () {
          Navigator.pop(context);
          _onMenuTap(6);
        },
      ),
    );
  }

  void _showMobileNotificationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _MobileNotificationSheet(
        notifications: _notifications,
        onMarkAllRead: _markAllAsRead,
        onMarkSingleRead: _markSingleAsRead,
        onViewAll: () {
          Navigator.pop(context);
          _onMenuTap(6);
        },
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    try {
      await EnterpriseApiService.markAllNotificationsRead();
      await _loadNotifications();
    } catch (_) {}
  }

  Future<void> _markSingleAsRead(int id) async {
    try {
      await EnterpriseApiService.markNotificationRead(id);
      await _loadNotifications();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      drawer: isMobile ? _buildDrawer() : null,
      body: SafeArea(
        child: Row(
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
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    final currentMenu = _menuItems[_currentIndex];
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
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
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Color(0xFF1E293B)),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          if (!isMobile) const SizedBox(width: 8),
          Text(
            currentMenu.label,
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          _buildHeaderActions(isMobile),
        ],
      ),
    );
  }

  Widget _buildHeaderActions(bool isMobile) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Row(
      children: [
        _buildNotificationBell(unreadCount),
        SizedBox(width: isMobile ? 8 : 16),
        _buildUserProfile(isMobile),
      ],
    );
  }

  Widget _buildUserProfile(bool isMobile) {
    final displayName = _userProfile?.fullName ?? 'Demo Enterprise';
    final initials = displayName.isNotEmpty
        ? displayName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : 'E';

    if (isMobile) {
      return PopupMenuButton<String>(
        offset: const Offset(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF10B981),
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
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
                  child: const Icon(Icons.person, color: Color(0xFF10B981), size: 18),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hồ sơ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('Thông tin cá nhân', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
          if (value == 'profile') _onMenuTap(7);
        },
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
        ],
      ),
    );
  }

  Widget _buildNotificationBell(int unreadCount) {
    return GestureDetector(
      onTap: () => _onMenuTap(6), // Chuyển trực tiếp sang tab Thông báo
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
    final userDisplayName = _userProfile?.fullName ?? 'Doanh nghiệp';
    final userEmail = _userProfile?.email ?? 'enterprise@example.com';
    final initials = userDisplayName.isNotEmpty
        ? userDisplayName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : 'E';

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    initials,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userDisplayName,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isActive = _currentIndex == index;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    leading: Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: isActive ? const Color(0xFF10B981) : const Color(0xFF64748B),
                      size: 24,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isActive ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    selected: isActive,
                    selectedTileColor: const Color(0xFFF0FDFA),
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
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 15),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                Navigator.pop(context);
                _handleLogout();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_currentIndex != 0) {
      return _buildOtherPages();
    }

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

    return _buildDashboard();
  }

  Widget _buildOtherPages() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadStats();
        await _loadNotifications();
      },
      color: const Color(0xFF10B981),
      child: switch (_currentIndex) {
        1 => const CollectionRequestsView(),
        2 => const CollectorsView(),
        3 => AssignmentsView(
          pendingRequestId: _pendingAssignmentReportId,
          onAssignmentComplete: () {
            setState(() {
              _currentIndex = 4; // Quay về trang Báo cáo
              _pendingAssignmentReportId = null; // Clear pending
            });
          },
        ),
        4 => ReportsView(onReportAccepted: _onReportAccepted),
        5 => const FeedbacksView(),
        6 => NotificationsView(onRefreshParent: _loadNotifications),
        7 => const EnterpriseProfileView(),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final isMedium = constraints.maxWidth > 600;

        return RefreshIndicator(
          onRefresh: () async {
            await _loadStats();
            await _loadNotifications();
          },
          color: const Color(0xFF10B981),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isWide ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Analytics Section
                if (isWide)
                  _buildDesktopAnalyticsRow()
                else if (isMedium)
                  _buildMediumAnalyticsRow()
                else
                  _buildMobileAnalyticsColumn(),
                const SizedBox(height: 24),

                // Lists Section
                if (isWide)
                  _buildDesktopListsRow()
                else
                  _buildMobileListsColumn(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopAnalyticsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildDoughnutChart(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: _buildStatsGrid(),
        ),
      ],
    );
  }

  Widget _buildMediumAnalyticsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildDoughnutChart(),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildStatsGrid(),
        ),
      ],
    );
  }

  Widget _buildMobileAnalyticsColumn() {
    return Column(
      children: [
        _buildDoughnutChart(),
        const SizedBox(height: 16),
        _buildStatsGrid(),
      ],
    );
  }

  Widget _buildDoughnutChart() {
    int hoanThanh = 0;
    int dangXuLy = 0;
    int choXuLy = 0;

    for (var req in _collectionRequests) {
      final status = (req.status ?? '').toLowerCase();
      if (status.contains('completed') || status.contains('hoàn thành') || status == 'completed') {
        hoanThanh++;
      } else if (status.contains('in_progress') || status.contains('đang xử lý') || status == 'inprogress' || status == 'in_progress') {
        dangXuLy++;
      } else {
        choXuLy++;
      }
    }

    final tongCong = hoanThanh + dangXuLy + choXuLy;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Tổng quan thu gom',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 50,
                    sections: tongCong > 0
                        ? [
                            PieChartSectionData(
                              value: hoanThanh.toDouble(),
                              color: const Color(0xFF10B981),
                              showTitle: false,
                              radius: 14,
                            ),
                            PieChartSectionData(
                              value: dangXuLy.toDouble(),
                              color: const Color(0xFF3B82F6),
                              showTitle: false,
                              radius: 14,
                            ),
                            PieChartSectionData(
                              value: choXuLy.toDouble(),
                              color: const Color(0xFFF59E0B),
                              showTitle: false,
                              radius: 14,
                            ),
                          ]
                        : [
                            PieChartSectionData(
                              value: 100,
                              color: const Color(0xFFE2E8F0),
                              showTitle: false,
                              radius: 14,
                            ),
                          ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$tongCong',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Text(
                      'Tổng cộng',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Hoàn thành', const Color(0xFF10B981)),
              _buildLegendItem('Đang xử lý', const Color(0xFF3B82F6)),
              _buildLegendItem('Chờ xử lý', const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 300;

        if (isNarrow) {
          return Column(
            children: [
              _buildStatCard(
                icon: Icons.people_alt_outlined,
                value: (_stats?.totalCollectors ?? 0).toString(),
                label: 'Nhân viên',
                color: const Color(0xFF3B82F6),
                onTap: () => _onMenuTap(2),
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.local_shipping_outlined,
                value: (_stats?.totalCollections ?? 0).toString(),
                label: 'Yêu cầu',
                color: const Color(0xFF10B981),
                onTap: () => _onMenuTap(1),
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.pending_actions_outlined,
                value: (_stats?.pendingReports ?? 0).toString(),
                label: 'Chờ duyệt',
                color: const Color(0xFFF59E0B),
                onTap: () => _onMenuTap(4),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_alt_outlined,
                value: (_stats?.totalCollectors ?? 0).toString(),
                label: 'Nhân viên',
                color: const Color(0xFF3B82F6),
                onTap: () => _onMenuTap(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_shipping_outlined,
                value: (_stats?.totalCollections ?? 0).toString(),
                label: 'Yêu cầu',
                color: const Color(0xFF10B981),
                onTap: () => _onMenuTap(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.pending_actions_outlined,
                value: (_stats?.pendingReports ?? 0).toString(),
                label: 'Chờ duyệt',
                color: const Color(0xFFF59E0B),
                onTap: () => _onMenuTap(4),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: color.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopListsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildRecentCollections(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: _buildRecentReports(),
        ),
      ],
    );
  }

  Widget _buildMobileListsColumn() {
    return Column(
      children: [
        _buildRecentCollections(),
        const SizedBox(height: 16),
        _buildRecentReports(),
      ],
    );
  }

  Widget _buildRecentCollections() {
    final sortedRequests = List<EnterpriseCollectionRequest>.from(_collectionRequests)
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
    final recentItems = sortedRequests.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              const Text(
                'Thu gom gần đây',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _onMenuTap(1),
                child: const Text('Xem tất cả', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentItems.isEmpty)
            _buildEmptyListState('Chưa có yêu cầu thu gom nào')
          else
            ...recentItems.map((req) => _buildCollectionItemFromRequest(req)),
        ],
      ),
    );
  }

  Widget _buildCollectionItemFromRequest(EnterpriseCollectionRequest req) {
    final status = (req.status ?? '').toLowerCase();
    String statusText;
    Color statusColor;

    if (status.contains('completed') || status == 'completed') {
      statusText = 'Hoàn thành';
      statusColor = const Color(0xFF10B981);
    } else if (status.contains('in_progress') || status.contains('inprogress') || status == 'in_progress') {
      statusText = 'Đang xử lý';
      statusColor = const Color(0xFF3B82F6);
    } else {
      statusText = 'Chờ xử lý';
      statusColor = const Color(0xFFF59E0B);
    }

    final timeAgo = req.createdAt != null ? _formatTime(req.createdAt!) : '';
    final address = req.reportDescription ?? 'Không có địa chỉ';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_shipping, color: Color(0xFF10B981), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(timeAgo, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReports() {
    final sortedReports = List<EnterpriseReport>.from(_recentReports)
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
    final recentItems = sortedReports.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              const Text(
                'Báo cáo gần đây',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _onMenuTap(4),
                child: const Text('Xem tất cả', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentItems.isEmpty)
            _buildEmptyListState('Chưa có báo cáo nào')
          else
            ...recentItems.map((report) => _buildReportItemFromData(report)),
        ],
      ),
    );
  }

  Widget _buildReportItemFromData(EnterpriseReport report) {
    final status = (report.status ?? '').toLowerCase();
    String statusText;
    Color statusColor;

    if (status.contains('approved') || status.contains('accepted') || status.contains('đã duyệt') || status.contains('collected')) {
      statusText = 'Đã duyệt';
      statusColor = const Color(0xFF10B981);
    } else if (status.contains('rejected') || status.contains('đã từ chối')) {
      statusText = 'Đã từ chối';
      statusColor = const Color(0xFFEF4444);
    } else {
      statusText = 'Chờ duyệt';
      statusColor = Colors.orange;
    }

    final timeAgo = report.createdAt != null ? _formatTime(report.createdAt!) : '';
    final title = report.description ?? 'Báo cáo rác thải';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.report_problem, color: Color(0xFFF59E0B), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Từ: ${report.submittedByName}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                Text(
                  timeAgo,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyListState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 36, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
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

class _EnterpriseMenuItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  _EnterpriseMenuItem(this.icon, this.activeIcon, this.label, this.index);
}

// Desktop Notification Popup
class _DesktopNotificationPopup extends StatelessWidget {
  final List<EnterpriseNotification> notifications;
  final VoidCallback onMarkAllRead;
  final Function(int) onMarkSingleRead;
  final VoidCallback onViewAll;

  const _DesktopNotificationPopup({
    required this.notifications,
    required this.onMarkAllRead,
    required this.onMarkSingleRead,
    required this.onViewAll,
  });

  int get _unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Container(color: Colors.transparent),
        ),
        Positioned(
          top: 72,
          right: 24,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: Container(
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
                  _buildHeader(context),
                  Flexible(
                    child: notifications.isEmpty
                        ? _buildEmptyState()
                        : _buildNotificationList(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
              onPressed: onMarkAllRead,
              child: const Text('Đọc tất cả', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pop(context),
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

  Widget _buildNotificationList(BuildContext context) {
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
              return _NotificationTile(
                notification: notification,
                onTap: () {
                  if (!notification.isRead) {
                    onMarkSingleRead(notification.notificationId);
                  }
                  Navigator.pop(context);
                  onViewAll();
                },
              );
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
                onTap: () {
                  Navigator.pop(context);
                  onViewAll();
                },
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

// Mobile Notification Bottom Sheet
class _MobileNotificationSheet extends StatelessWidget {
  final List<EnterpriseNotification> notifications;
  final VoidCallback onMarkAllRead;
  final Function(int) onMarkSingleRead;
  final VoidCallback onViewAll;

  const _MobileNotificationSheet({
    required this.notifications,
    required this.onMarkAllRead,
    required this.onMarkSingleRead,
    required this.onViewAll,
  });

  int get _unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildHeader(context),
          Expanded(
            child: notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
              if (_unreadCount > 0)
                Text('$_unreadCount thông báo chưa đọc', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
          const Spacer(),
          if (_unreadCount > 0)
            TextButton(
              onPressed: onMarkAllRead,
              child: const Text('Đọc tất cả', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
            ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Color(0xFF64748B)),
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

  Widget _buildNotificationList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationTile(
          notification: notification,
          onTap: () {
            if (!notification.isRead) {
              onMarkSingleRead(notification.notificationId);
            }
            Navigator.pop(context);
            onViewAll();
          },
        );
      },
    );
  }
}

// Shared Notification Tile Widget
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
