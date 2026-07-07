import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/presentation/home/home_screen.dart';
import 'package:waste_collection_management_system/presentation/admin/admin_screen.dart';
import 'package:waste_collection_management_system/presentation/enterprise/enterprise_screen.dart';
import 'package:waste_collection_management_system/presentation/register/register_screen.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';
import 'package:waste_collection_management_system/services/storage_service.dart';
import 'package:waste_collection_management_system/data/constants/app_roles.dart';

class RightPanelForm extends StatefulWidget {
  const RightPanelForm({super.key});

  @override
  State<RightPanelForm> createState() => _RightPanelFormState();
}

class _RightPanelFormState extends State<RightPanelForm> {
  static final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  void _handleLogin() async {
    if (_isLoading) return;
    _clearError();
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (mounted) {
          // Get profile to check role
          final storage = StorageService();
          final profile = await storage.getUserProfile();

          // Route based on role
          Widget nextScreen;
          if (profile != null && profile.roleId == AppRoles.admin) {
            nextScreen = const AdminScreen();
          } else if (profile != null && profile.roleId == AppRoles.enterprise) {
            nextScreen = const EnterpriseScreen();
          } else {
            nextScreen = const HomeScreen();
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => nextScreen),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder myBorder(Color color, {double width = 1.0}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.eco, color: Color(0xff10b981), size: 24),
                SizedBox(width: 12),
                Text('Waste Collection', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            const SizedBox(height: 48),
            const Text('Chào mừng trở lại', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5)),
            const SizedBox(height: 10),
            const Text('Đăng nhập để tiếp tục hành trình sống xanh của bạn', style: TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 40),
            const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) return 'Vui lòng nhập địa chỉ email hợp lệ';
                return null;
              },
              decoration: InputDecoration(
                hintText: 'name@example.com',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: const Color(0xfff9fafb),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                border: myBorder(Colors.grey[200]!),
                enabledBorder: myBorder(Colors.grey[200]!),
                focusedBorder: myBorder(const Color(0xff10b981), width: 2.0),
                errorBorder: myBorder(Colors.red),
                focusedErrorBorder: myBorder(Colors.red, width: 2.0),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mật khẩu', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text('Quên mật khẩu?', style: TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Nhập mật khẩu',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: const Color(0xfff9fafb),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ),
                border: myBorder(Colors.grey[200]!),
                enabledBorder: myBorder(Colors.grey[200]!),
                focusedBorder: myBorder(const Color(0xff10b981), width: 2.0),
                errorBorder: myBorder(Colors.red),
                focusedErrorBorder: myBorder(Colors.red, width: 2.0),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff10b981),
                  disabledBackgroundColor: const Color(0xff10b981).withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Đăng nhập', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xfffee2e2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xfffca5a5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Color(0xffdc2626), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Email hoặc mật khẩu không đúng',
                        style: TextStyle(color: Color(0xffdc2626), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Chưa có tài khoản?', style: TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  child: const Text('Đăng ký', style: TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
