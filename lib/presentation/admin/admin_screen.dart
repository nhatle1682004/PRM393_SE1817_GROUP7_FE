import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'package:waste_collection_management_system/data/models/admin_stats.dart';
import 'package:waste_collection_management_system/services/admin_api_service.dart';
import 'package:waste_collection_management_system/presentation/admin/widgets/dashboard_view.dart';
import 'package:waste_collection_management_system/presentation/admin/widgets/users_view.dart';
import 'package:waste_collection_management_system/presentation/admin/widgets/waste_reports_view.dart';
import 'package:waste_collection_management_system/presentation/admin/widgets/collection_requests_view.dart';
import 'package:waste_collection_management_system/presentation/admin/widgets/feedbacks_view.dart';
import 'package:waste_collection_management_system/presentation/admin/widgets/notifications_view.dart';
import 'package:waste_collection_management_system/presentation/admin/widgets/rewards_view.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;
  AdminStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;
  int? _unreadNotifications;

  final List<_AdminMenuItem> _menuItems = [
    _AdminMenuItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard', 0),
    _AdminMenuItem(Icons.people_outline, Icons.people, 'Người dùng', 1),
    _AdminMenuItem(Icons.report_problem_outlined, Icons.report_problem, 'Báo cáo rác', 2),
    _AdminMenuItem(Icons.local_shipping_outlined, Icons.local_shipping, 'Yêu cầu thu gom', 3),
    _AdminMenuItem(Icons.feedback_outlined, Icons.feedback, 'Phản hồi', 4),
    _AdminMenuItem(Icons.notifications_outlined, Icons.notifications, 'Thông báo', 5),
    _AdminMenuItem(Icons.card_giftcard_outlined, Icons.card_giftcard, 'Phần thưởng', 6),
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stats = await AdminApiService.getAdminDashboard();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
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
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          Icon(currentMenu.activeIcon, color: const Color(0xFF10B981), size: 28),
          const SizedBox(width: 12),
          Text(
            currentMenu.label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const Spacer(),
          _buildHeaderActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        if (_stats != null) ...[
          _buildStatChip(
            icon: Icons.people,
            value: _stats!.totalUsers.toString(),
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            icon: Icons.report,
            value: _stats!.totalReports.toString(),
            color: const Color(0xFF10B981),
          ),
          const SizedBox(width: 12),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: Color(0xFF10B981), size: 16),
              const SizedBox(width: 6),
              const Text(
                'Quản trị viên',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        PopupMenuButton<String>(
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF10B981),
                  child: Icon(Icons.person, color: Colors.white, size: 16),
                ),
                SizedBox(width: 10),
                Text('Admin', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B), size: 20),
              ],
            ),
          ),
          onSelected: (value) {
            if (value == 'logout') _handleLogout();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'profile', child: Text('Hồ sơ')),
            const PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip({required IconData icon, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200, width: 1)),
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
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco, color: Color(0xFF10B981), size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waste Collection',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                Text(
                  'Hệ thống quản lý',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(_AdminMenuItem item) {
    final isActive = _currentIndex == item.index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onMenuTap(item.index),
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
                Icon(Icons.logout, color: Color(0xFFDC2626), size: 22),
                SizedBox(width: 14),
                Text(
                  'Đăng xuất',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
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
            decoration: const BoxDecoration(color: Color(0xFF10B981)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Waste Collection',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const Text(
                  'Hệ thống quản lý',
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
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    leading: Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: isActive ? const Color(0xFF10B981) : const Color(0xFF64748B),
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color: isActive ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
            leading: const Icon(Icons.logout, color: Color(0xFFDC2626)),
            title: const Text('Đăng xuất', style: TextStyle(color: Color(0xFFDC2626))),
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
            CircularProgressIndicator(color: Color(0xFF10B981)),
            SizedBox(height: 16),
            Text('Đang tải dữ liệu...'),
          ],
        ),
      );
    }

    if (_errorMessage != null && _stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    switch (_currentIndex) {
      case 0:
        return DashboardView(stats: _stats, onRefresh: _loadStats);
      case 1:
        return UsersView(onRefresh: _loadStats);
      case 2:
        return WasteReportsView();
      case 3:
        return CollectionRequestsView();
      case 4:
        return FeedbacksView();
      case 5:
        return NotificationsView();
      case 6:
        return RewardsView();
      default:
        return DashboardView(stats: _stats, onRefresh: _loadStats);
    }
  }
}

class _AdminMenuItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  _AdminMenuItem(this.icon, this.activeIcon, this.label, this.index);
}
