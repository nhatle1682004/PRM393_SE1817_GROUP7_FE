import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:waste_collection_management_system/data/models/user_profile_data.dart';
import 'package:waste_collection_management_system/presentation/profile/profile_contract.dart';
import 'package:waste_collection_management_system/presentation/profile/profile_presenter.dart';
import 'package:waste_collection_management_system/presentation/profile/change_password_screen.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';

class EnterpriseProfileView extends StatefulWidget {
  const EnterpriseProfileView({super.key});

  @override
  State<EnterpriseProfileView> createState() => _EnterpriseProfileViewState();
}

class _EnterpriseProfileViewState extends State<EnterpriseProfileView> implements ProfileView {
  late ProfilePresenter _presenter;
  UserProfileData? _profile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = ProfilePresenterImpl(this);
    _presenter.loadProfile();
  }

  @override
  void dispose() {
    _presenter.dispose();
    super.dispose();
  }

  @override
  void onProfileLoaded(UserProfileData profile) {
    if (mounted) {
      setState(() {
        _profile = profile;
      });
    }
  }

  @override
  void onLoadingStateChanged(bool isLoading) {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
      });
    }
  }

  @override
  void onError(String? error) {
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xffdc2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void onLogoutSuccess() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'NL';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xfffee2e2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber, color: Color(0xffdc2626), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Xóa tài khoản',
                style: TextStyle(
                  color: Color(0xff1e293b),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc chắn muốn xóa tài khoản?',
              style: TextStyle(
                color: Color(0xff1e293b),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Hành động này sẽ xóa vĩnh viễn tài khoản và tất cả dữ liệu của bạn. Không thể hoàn tác.',
              style: TextStyle(
                color: Color(0xff64748b),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Hủy bỏ',
              style: TextStyle(
                color: Color(0xff64748b),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              const storage = FlutterSecureStorage();
              await storage.deleteAll();
              onLogoutSuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffdc2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xff10b981),
        ),
      );
    }

    return _buildMainContent();
  }

  Widget _buildMainContent() {
    final isWide = MediaQuery.of(context).size.width > 600;
    final padding = isWide ? 32.0 : 16.0;
    const bgColor = Color(0xfffbfbfc);

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isWide ? 32 : 20),

            // Avatar Card
            Container(
              padding: EdgeInsets.all(isWide ? 32 : 20),
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
              child: isWide
                  ? _buildDesktopAvatarSection()
                  : _buildMobileAvatarSection(),
            ),
            SizedBox(height: isWide ? 24 : 16),

            // Personal Info Card
            Container(
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, isWide ? 24 : 16, isWide ? 24 : 16, 16),
                    child: Row(
                      children: [
                        Text(
                          'Thông tin cá nhân',
                          style: TextStyle(
                            fontSize: isWide ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff1e293b),
                          ),
                        ),
                        const Spacer(),
                        _buildEditButton(isWide),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xfff1f5f9)),
                  _buildFormRow('Họ', 'Hoàng', isWide),
                  _buildDivider(),
                  _buildFormRow('Tên', 'Lệ', isWide),
                  _buildDivider(),
                  _buildFormRow('Email', _profile?.email ?? 'lehoang712004@gmail.com', isWide),
                ],
              ),
            ),
            SizedBox(height: isWide ? 24 : 16),

            // Settings Cards
            if (isWide)
              Row(
                children: [
                  Expanded(child: _buildSettingCard(Icons.lock_outline, 'Đổi mật khẩu', 'Cập nhật mật khẩu mới', const Color(0xff10b981), _navigateToChangePassword)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSettingCard(Icons.delete_outline, 'Xóa tài khoản', 'Xóa vĩnh viễn tài khoản', const Color(0xffdc2626), _showDeleteAccountDialog)),
                ],
              )
            else
              Column(
                children: [
                  _buildSettingCard(Icons.lock_outline, 'Đổi mật khẩu', 'Cập nhật mật khẩu mới', const Color(0xff10b981), _navigateToChangePassword),
                  const SizedBox(height: 12),
                  _buildSettingCard(Icons.delete_outline, 'Xóa tài khoản', 'Xóa vĩnh viễn tài khoản', const Color(0xffdc2626), _showDeleteAccountDialog),
                ],
              ),
            SizedBox(height: isWide ? 32 : 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopAvatarSection() {
    return Row(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xff10b981),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xff10b981).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getInitials(_profile?.fullName ?? 'hoang nhat le'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _profile?.fullName ?? 'hoang nhat le',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0f172a),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xffe8f5f0),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: const Color(0xffbbf7d0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield, color: Color(0xff10b981), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Hiệp sĩ Môi trường',
                      style: TextStyle(
                        color: Color(0xff10b981),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildEditButton(true),
      ],
    );
  }

  Widget _buildMobileAvatarSection() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xff10b981),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xff10b981).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getInitials(_profile?.fullName ?? 'hoang nhat le'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _profile?.fullName ?? 'hoang nhat le',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff0f172a),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xffe8f5f0),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: const Color(0xffbbf7d0)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield, color: Color(0xff10b981), size: 14),
              SizedBox(width: 5),
              Text(
                'Hiệp sĩ Môi trường',
                style: TextStyle(
                  color: Color(0xff10b981),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildEditButton(false),
      ],
    );
  }

  Widget _buildEditButton(bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 18 : 14, vertical: isWide ? 10 : 8),
      decoration: BoxDecoration(
        color: const Color(0xff10b981),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff10b981).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_outlined, color: Colors.white, size: isWide ? 16 : 14),
          const SizedBox(width: 6),
          Text(
            'Chỉnh sửa',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isWide ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1e293b),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff94a3b8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color.withValues(alpha: 0.5),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormRow(String label, String value, bool isWide) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20, vertical: isWide ? 18 : 14),
      child: Row(
        children: [
          SizedBox(
            width: isWide ? 120 : 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xff94a3b8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xff1e293b),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 20,
      endIndent: 20,
      color: Color(0xfff1f5f9),
    );
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      ),
    );
  }
}
