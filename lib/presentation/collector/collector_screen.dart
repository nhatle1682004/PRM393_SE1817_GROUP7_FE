import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';
import 'package:waste_collection_management_system/services/storage_service.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'package:waste_collection_management_system/presentation/collector/widgets/my_tasks_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/notifications_view.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/profile_view.dart';

class CollectorScreen extends StatefulWidget {
  const CollectorScreen({super.key});

  @override
  State<CollectorScreen> createState() => _CollectorScreenState();
}

class _CollectorScreenState extends State<CollectorScreen> {
  int _currentIndex = 0;
  UserProfile? _userProfile;

  final List<_CollectorMenuItem> _menuItems = [
    _CollectorMenuItem(Icons.assignment_outlined, Icons.assignment_rounded, 'Công việc', 0),
    _CollectorMenuItem(Icons.history_outlined, Icons.history_rounded, 'Lịch sử', 1),
    _CollectorMenuItem(Icons.notifications_none_rounded, Icons.notifications_rounded, 'Thông báo', 2),
    _CollectorMenuItem(Icons.account_circle_outlined, Icons.account_circle_rounded, 'Hồ sơ', 3),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await AuthService.getProfile();
    if (mounted) setState(() => _userProfile = profile);
  }

  Future<void> _handleLogout() async {
    await AuthService().logout();
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
      backgroundColor: const Color(0xFFF8FAFC),
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
          const SizedBox(width: 8),
          Text(
            currentMenu.label,
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          _buildUserProfileHeader(isMobile),
        ],
      ),
    );
  }

  Widget _buildUserProfileHeader(bool isMobile) {
    final displayName = _userProfile?.fullName ?? 'Collector';
    final initials = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C';

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
            radius: 14,
            backgroundColor: const Color(0xFF10B981),
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 10),
            Text(
              displayName,
              style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ],
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
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco, color: Color(0xFF10B981), size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waste Collection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Nhân viên thu gom',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(_CollectorMenuItem item) {
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
                  ? [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
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
    final userDisplayName = _userProfile?.fullName ?? 'Nhân viên';
    final userEmail = _userProfile?.email ?? 'collector@example.com';
    final initials = userDisplayName.isNotEmpty ? userDisplayName[0].toUpperCase() : 'C';

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
    switch (_currentIndex) {
      case 0:
        return const MyTasksView();
      case 1:
        return const Center(child: Text('Lịch sử thu gom (Đang phát triển)'));
      case 2:
        return NotificationsView(onRefreshParent: () {});
      case 3:
        return const EnterpriseProfileView();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _CollectorMenuItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  _CollectorMenuItem(this.icon, this.activeIcon, this.label, this.index);
}
