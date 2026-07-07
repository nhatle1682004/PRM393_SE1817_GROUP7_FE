import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';
import 'package:waste_collection_management_system/services/storage_service.dart';

class HeaderSection extends StatefulWidget implements PreferredSizeWidget {
  final int currentTabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback? onLogout;
  final String? userName;
  final int points;

  const HeaderSection({
    super.key,
    required this.currentTabIndex,
    required this.onTabChanged,
    this.onLogout,
    this.userName,
    this.points = 0,
  });

  @override
  State<HeaderSection> createState() => _HeaderSectionState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

class _HeaderSectionState extends State<HeaderSection> {
  final StorageService _storageService = StorageService();
  String? _savedName;
  String _avatarLetters = '--';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profile = await _storageService.getUserProfile();
    if (!mounted) return;
    setState(() {
      if (profile != null && profile.fullName.isNotEmpty) {
        _savedName = profile.fullName;
        _avatarLetters = profile.fullName.substring(0, profile.fullName.length >= 2 ? 2 : 1).toUpperCase();
      } else {
        _savedName = widget.userName;
        if (_savedName != null && _savedName!.isNotEmpty) {
          _avatarLetters = _savedName!.substring(0, _savedName!.length >= 2 ? 2 : 1).toUpperCase();
        } else {
          _avatarLetters = 'G';
        }
      }
      _loaded = true;
    });
  }

  String _displayName() {
    if (!_loaded) return 'Đang tải...';
    if (_savedName == null || _savedName!.isEmpty) return 'Khách';
    return _savedName!;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    final displayName = _displayName();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: const Color(0xffe2e8f0), width: 1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0f172a).withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 20),
          child: Row(
            children: [
              // 1. Logo & App Name
              Flexible(
                flex: isMobile ? 0 : 1,
                child: _buildLogo(isMobile),
              ),

              if (!isMobile) const SizedBox(width: 20),

              // 2. Navigation
              if (!isMobile)
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _navButton('Trang chủ', index: 0),
                        _navButton('Tạo báo cáo', index: 1),
                        _navButton('Phần thưởng', index: 2),
                        _navButton('Lịch sử', index: 3),
                      ],
                    ),
                  ),
                )
              else ...[
                Builder(
                  builder: (context) => IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    icon: const Icon(Icons.menu, color: Color(0xff475569), size: 22),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ],

              const Spacer(),

              // 3. Actions & Profile
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMobile) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Color(0xff64748b), size: 20),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    _buildPointsBadge(),
                  ],
                  const SizedBox(width: 8),
                  _buildProfile(isMobile, displayName),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: const Color(0xffdcfce7), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.eco, color: Color(0xff10b981), size: 20),
        ),
        if (!isMobile) ...[
          const SizedBox(width: 8),
          const Flexible(
            child: Text(
              'Waste Collection',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xff0f172a)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPointsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xfff0fdf4), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xffbbf7d0))),
      child: Text('${widget.points} điểm', style: const TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.w700, fontSize: 11)),
    );
  }

  Widget _buildProfile(bool isMobile, String displayName) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: isMobile
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xff10b981),
                  child: Text(_avatarLetters, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            )
          : _buildProfileDropdown(displayName),
    );
  }

  Widget _buildProfileDropdown(String displayName) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      color: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xff10b981),
            child: Text(_avatarLetters, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80),
            child: Text(displayName, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xff334155), fontWeight: FontWeight.w600, fontSize: 11)),
          ),
          const Icon(Icons.arrow_drop_down, color: Color(0xff64748b), size: 18),
        ],
      ),
      onSelected: (value) {
        if (value == 'profile') {
          widget.onTabChanged(4);
        } else if (value == 'logout') {
          _showLogoutConfirmDialog();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'profile',
          height: 44,
          child: const Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: Color(0xff64748b)),
              SizedBox(width: 12),
              Text('Trang cá nhân', style: TextStyle(fontSize: 13, color: Color(0xff1e293b), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          height: 44,
          child: const Row(
            children: [
              Icon(Icons.logout, size: 18, color: Color(0xffdc2626)),
              SizedBox(width: 12),
              Text('Đăng xuất', style: TextStyle(fontSize: 13, color: Color(0xffdc2626), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authService = AuthService();
              await authService.logout();
              if (widget.onLogout != null) {
                widget.onLogout!();
              } else {
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffdc2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _navButton(String label, {required int index}) {
    bool isActive = widget.currentTabIndex == index;
    return InkWell(
      onTap: () => widget.onTabChanged(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xfff0fdf4) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xff10b981) : const Color(0xff64748b),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
