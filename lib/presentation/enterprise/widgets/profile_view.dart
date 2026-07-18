import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:waste_collection_management_system/data/models/user_profile_data.dart';
import 'package:waste_collection_management_system/presentation/profile/profile_contract.dart';
import 'package:waste_collection_management_system/presentation/profile/profile_presenter.dart';
import 'package:waste_collection_management_system/presentation/profile/change_password_screen.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'profile_widgets.dart';

class EnterpriseProfileView extends StatefulWidget {
  const EnterpriseProfileView({super.key});
  @override
  State<EnterpriseProfileView> createState() => _EnterpriseProfileViewState();
}

class _EnterpriseProfileViewState extends State<EnterpriseProfileView> implements ProfileView {
  late ProfilePresenter _presenter;
  UserProfileData? _profile;
  bool _isLoading = false, _isEditing = false;
  final _name = TextEditingController(), _phone = TextEditingController();

  @override
  void initState() { super.initState(); _presenter = ProfilePresenterImpl(this); _presenter.loadProfile(); }

  @override
  void onProfileLoaded(UserProfileData p) { if (mounted) setState(() { _profile = p; _name.text = p.fullName; _phone.text = p.phone ?? ''; _isEditing = false; }); }
  @override
  void onLoadingStateChanged(bool l) { if (mounted) setState(() => _isLoading = l); }
  @override
  void onError(String? e) {
    if (e != null && mounted) {
      CherryToast.error(
        title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
        description: Text(e),
        animationType: AnimationType.fromRight,
        autoDismiss: true,
      ).show(context);
    }
  }
  @override
  void onLogoutSuccess() => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginScreen()), (r) => false);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final isWide = MediaQuery.of(context).size.width > 600;
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      ProfileAvatarSection(name: _profile?.fullName ?? 'Enterprise', isWide: isWide),
      const SizedBox(height: 24),
      Card(child: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [const Text('Thông tin cá nhân', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), _editBtn()])),
        _row('Họ và tên', _name),
        _row('Số điện thoại', _phone),
        _row('Email', TextEditingController(text: _profile?.email), enabled: false),
      ])),
      const SizedBox(height: 24),
      SettingCard(icon: Icons.lock, title: 'Đổi mật khẩu', subtitle: 'Cập nhật bảo mật', color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ChangePasswordScreen()))),
      const SizedBox(height: 12),
      SettingCard(icon: Icons.delete, title: 'Xóa tài khoản', subtitle: 'Xóa vĩnh viễn', color: Colors.red, onTap: _confirmDelete),
    ]));
  }

  Widget _editBtn() => ElevatedButton(onPressed: () {
    if (_isEditing) {
      _presenter.updateProfile(_profile!.copyWith(fullName: _name.text, phone: _phone.text));
    } else {
      setState(() => _isEditing = true);
    }
  }, child: Text(_isEditing ? 'Lưu' : 'Sửa'));

  Widget _row(String l, TextEditingController c, {bool enabled = true}) => ListTile(title: Text(l, style: const TextStyle(fontSize: 12, color: Colors.grey)), subtitle: _isEditing && enabled ? TextField(controller: c) : Text(c.text));

  void _confirmDelete() async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Xóa tài khoản?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xóa'))]));
    if (ok == true) { await const FlutterSecureStorage().deleteAll(); onLogoutSuccess(); }
  }
}
