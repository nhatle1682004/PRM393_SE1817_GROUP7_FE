import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final int currentTabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback? onLogout;
  final String? userName;
  final int points;

  const AppLayout({
    super.key,
    required this.child,
    required this.currentTabIndex,
    required this.onTabChanged,
    this.onLogout,
    this.userName,
    this.points = 0,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final userName = this.userName ?? 'hoang nhat le';
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
          // Logo in header
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
          // Actions
          Row(
            children: [
              // Notification Bell
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, color: Color(0xFF64748B)),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 16),
              // Points Badge
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
                      '★ $points Điểm',
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
              // User Profile Dropdown
              _buildUserDropdown(context, userName, initials),
            ],
          ),
        ],
      ),
    );
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
        if (value == 'logout') onLogout?.call();
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
    final isActive = currentTabIndex == item.index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onTabChanged(item.index),
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
