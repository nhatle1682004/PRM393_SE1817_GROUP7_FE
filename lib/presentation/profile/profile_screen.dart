import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:waste_collection_management_system/data/models/user_profile_data.dart';
import 'package:waste_collection_management_system/presentation/profile/profile_contract.dart';
import 'package:waste_collection_management_system/presentation/profile/profile_presenter.dart';
import 'package:waste_collection_management_system/presentation/profile/change_password_screen.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> implements ProfileView {
  late ProfilePresenter _presenter;
  UserProfileData? _profile;
  bool _isLoading = false;

  @override
  void initState() { super.initState(); _presenter = ProfilePresenterImpl(this); _presenter.loadProfile(); }

  @override
  void onProfileLoaded(UserProfileData p) => setState(() => _profile = p);
  @override
  void onLoadingStateChanged(bool l) => setState(() => _isLoading = l);
  @override
  void onError(String? e) {}
  @override
  void onLogoutSuccess() => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (r) => false);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Cài đặt tài khoản', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 32),
      ProfileAvatarCard(name: _profile?.fullName ?? 'User', initials: _profile?.fullName[0] ?? 'U', onEdit: _showEdit),
      const SizedBox(height: 24),
      Card(child: Column(children: [
        InfoRow(label: 'Họ tên', value: _profile?.fullName ?? 'N/A'),
        const Divider(),
        InfoRow(label: 'Email', value: _profile?.email ?? 'N/A'),
        const Divider(),
        InfoRow(label: 'SĐT', value: _profile?.phone ?? 'N/A'),
      ])),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ChangePasswordScreen())), child: const Text('Đổi mật khẩu'))),
        const SizedBox(width: 16),
        Expanded(child: OutlinedButton(onPressed: _showDelete, style: OutlinedButton.styleFrom(foregroundColor: Colors.red), child: const Text('Xóa tài khoản'))),
      ]),
    ]));
  }

  void _showEdit() {} // Simplified
  void _showDelete() async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Xóa?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xóa'))]));
    if (ok == true) { await const FlutterSecureStorage().deleteAll(); onLogoutSuccess(); }
  }
}
