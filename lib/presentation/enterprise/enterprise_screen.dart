import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/collectors_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/collection_requests_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/reports_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/feedbacks_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/notifications_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/profile_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/enterprise_dashboard_widgets.dart';
import 'enterprise_contract.dart';
import 'enterprise_presenter.dart';

class EnterpriseScreen extends StatefulWidget {
  const EnterpriseScreen({super.key});

  @override
  State<EnterpriseScreen> createState() => _EnterpriseScreenState();
}

class _EnterpriseScreenState extends State<EnterpriseScreen> implements EnterpriseView {
  late EnterprisePresenter _presenter;
  int _currentIndex = 0;
  EnterpriseStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;
  UserProfile? _userProfile;
  List<EnterpriseNotification> _notifications = [];
  List<EnterpriseCollectionRequest> _collectionRequests = [];
  List<EnterpriseReport> _recentReports = [];

  final List<_EnterpriseMenuItem> _menuItems = [
    _EnterpriseMenuItem(Icons.grid_view_outlined, Icons.grid_view_rounded, 'Trang tổng quan', 0),
    _EnterpriseMenuItem(Icons.pending_actions_rounded, Icons.pending_actions_rounded, 'Tiến độ xử lý', 1),
    _EnterpriseMenuItem(Icons.badge_outlined, Icons.badge_rounded, 'Nhân viên', 2),
    _EnterpriseMenuItem(Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Báo cáo', 3),
    _EnterpriseMenuItem(Icons.forum_outlined, Icons.forum_rounded, 'Phản hồi', 4),
    _EnterpriseMenuItem(Icons.notifications_none_rounded, Icons.notifications_rounded, 'Thông báo', 5),
    _EnterpriseMenuItem(Icons.account_circle_outlined, Icons.account_circle_rounded, 'Hồ sơ', 6),
  ];

  @override
  void initState() {
    super.initState();
    _presenter = EnterprisePresenterImpl(this);
    _loadAll();
  }

  void _loadAll() {
    _presenter.loadStats();
    _presenter.loadUserProfile();
    _presenter.loadNotifications();
    _presenter.loadDashboardData();
  }

  @override
  void onLoadingStateChanged(bool isLoading) => setState(() => _isLoading = isLoading);
  @override
  void onStatsLoaded(EnterpriseStats stats) => setState(() => _stats = stats);
  @override
  void onUserProfileLoaded(UserProfile? profile) => setState(() => _userProfile = profile);
  @override
  void onNotificationsLoaded(List<EnterpriseNotification> n) => setState(() => _notifications = n);
  @override
  void onDashboardDataLoaded(List<EnterpriseCollectionRequest> r, List<EnterpriseReport> rr) => setState(() { _collectionRequests = r; _recentReports = rr; });
  @override
  void onTabUpdated(int index) => setState(() => _currentIndex = index);
  @override
  void onPendingAssignmentSet(int? requestId) {} // Logic handled in presenter
  @override
  void onError(String? message) => setState(() => _errorMessage = message);
  @override
  void navigateToLogin() => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (r) => false);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      drawer: isMobile ? _buildDrawer() : null,
      body: SafeArea(
        child: Row(children: [
          if (!isMobile) _buildSidebar(),
          Expanded(child: Column(children: [_buildHeader(isMobile), Expanded(child: _buildContent())])),
        ]),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    final currentMenu = _menuItems[_currentIndex];
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        if (isMobile) Builder(builder: (c) => IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => Scaffold.of(c).openDrawer())),
        Text(currentMenu.label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Spacer(),
        _buildNotificationBell(unreadCount),
        const SizedBox(width: 12),
        _buildUserProfileHeader(isMobile),
      ]),
    );
  }

  Widget _buildUserProfileHeader(bool isMobile) {
    final name = _userProfile?.fullName ?? 'Enterprise';
    if (isMobile) return IconButton(icon: const Icon(Icons.account_circle), onPressed: () => _presenter.setTab(6));
    return Row(children: [
      CircleAvatar(radius: 16, child: Text(name.isNotEmpty ? name[0] : 'E')),
      const SizedBox(width: 8),
      Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _buildNotificationBell(int unreadCount) {
    return InkWell(
      onTap: () => _presenter.setTab(5),
      child: Stack(clipBehavior: Clip.none, children: [
        const Icon(Icons.notifications_none, size: 26),
        if (unreadCount > 0) Positioned(right: -2, top: -2, child: CircleAvatar(radius: 8, backgroundColor: Colors.red, child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10)))),
      ]),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(children: [
        const Padding(padding: EdgeInsets.all(24), child: Text('WASTE MGMT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF10B981)))),
        Expanded(child: ListView(children: _menuItems.map((item) => ListTile(
          leading: Icon(_currentIndex == item.index ? item.activeIcon : item.icon, color: _currentIndex == item.index ? const Color(0xFF10B981) : Colors.grey),
          title: Text(item.label, style: TextStyle(color: _currentIndex == item.index ? const Color(0xFF10B981) : Colors.black)),
          selected: _currentIndex == item.index,
          onTap: () => _presenter.setTab(item.index),
        )).toList())),
        ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)), onTap: _presenter.handleLogout),
      ]),
    );
  }

  Widget _buildDrawer() => Drawer(child: _buildSidebar());

  Widget _buildContent() {
    if (_currentIndex != 0) return _buildOtherPages();
    if (_isLoading && _stats == null) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    return _buildDashboard();
  }

  Widget _buildOtherPages() => RefreshIndicator(
    onRefresh: () async => _loadAll(),
    child: switch (_currentIndex) {
      1 => const CollectionRequestsView(),
      2 => const CollectorsView(),
      3 => ReportsView(onReportAccepted: (id) => _presenter.setPendingAssignment(id)),
      4 => const FeedbacksView(),
      5 => NotificationsView(onRefreshParent: _presenter.loadNotifications),
      6 => const EnterpriseProfileView(),
      _ => const SizedBox.shrink(),
    },
  );

  Widget _buildDashboard() => RefreshIndicator(
    onRefresh: () async => _loadAll(),
    child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: LayoutBuilder(builder: (c, cs) {
      final wide = cs.maxWidth > 900;
      return Column(children: [
        if (wide) Row(children: [
          Expanded(flex: 2, child: EnterpriseDoughnutChart(collectionRequests: _collectionRequests)),
          const SizedBox(width: 20),
          Expanded(flex: 3, child: EnterpriseStatsGrid(stats: _stats, onTabChange: _presenter.setTab)),
        ]) else Column(children: [
          EnterpriseDoughnutChart(collectionRequests: _collectionRequests),
          const SizedBox(height: 20),
          EnterpriseStatsGrid(stats: _stats, onTabChange: _presenter.setTab),
        ]),
        const SizedBox(height: 20),
        if (wide) Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 3, child: RecentCollectionsList(requests: _collectionRequests, onViewAll: () => _presenter.setTab(1))),
          const SizedBox(width: 20),
          Expanded(flex: 2, child: RecentReportsList(reports: _recentReports, onViewAll: () => _presenter.setTab(3))),
        ]) else Column(children: [
          RecentCollectionsList(requests: _collectionRequests, onViewAll: () => _presenter.setTab(1)),
          const SizedBox(height: 20),
          RecentReportsList(reports: _recentReports, onViewAll: () => _presenter.setTab(3)),
        ]),
      ]);
    })),
  );
}

class _EnterpriseMenuItem {
  final IconData icon, activeIcon;
  final String label;
  final int index;
  _EnterpriseMenuItem(this.icon, this.activeIcon, this.label, this.index);
}
