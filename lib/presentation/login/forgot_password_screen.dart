import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/presentation/login/widgets/left_panel_banner.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      color: const Color(0xffd2ebd9),
                      child: const Center(
                        child: SingleChildScrollView(child: LeftPanelBanner()),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: _ForgotPasswordForm()),
                    ),
                  ),
                ],
              );
            }

            return const SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Center(child: _ForgotPasswordForm()),
            );
          },
        ),
      ),
    );
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  const _ForgotPasswordForm();

  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _message;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearMessages() {
    setState(() {
      _message = null;
      _errorMessage = null;
    });
  }

  Future<void> _sendOtp() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    _clearMessages();
    setState(() => _isLoading = true);
    try {
      await _authService.forgotPassword(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _message = 'Mã OTP đã được gửi đến email của bạn.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;

    _clearMessages();
    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(
        _emailController.text.trim(),
        _otpController.text.trim(),
        _passwordController.text,
        _confirmPasswordController.text,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công.')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, {double width = 1.0}) {
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
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Quay lại',
                ),
                const SizedBox(width: 8),
                const Icon(Icons.eco, color: Color(0xff10b981), size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Waste Collection',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Quên mật khẩu',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập email để nhận mã OTP và đặt lại mật khẩu.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            const Text(
              'Email',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              enabled: !_otpSent,
              keyboardType: TextInputType.emailAddress,
              textInputAction: _otpSent
                  ? TextInputAction.next
                  : TextInputAction.done,
              onFieldSubmitted: (_) => _otpSent ? null : _sendOtp(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập email';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return 'Vui lòng nhập địa chỉ email hợp lệ';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'name@example.com',
                filled: true,
                fillColor: const Color(0xfff9fafb),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                border: border(Colors.grey[200]!),
                enabledBorder: border(Colors.grey[200]!),
                disabledBorder: border(Colors.grey[200]!),
                focusedBorder: border(const Color(0xff10b981), width: 2.0),
                errorBorder: border(Colors.red),
                focusedErrorBorder: border(Colors.red, width: 2.0),
              ),
            ),
            if (_otpSent) ...[
              const SizedBox(height: 16),
              const Text(
                'Mã OTP',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mã OTP';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Nhập mã OTP',
                  filled: true,
                  fillColor: const Color(0xfff9fafb),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  border: border(Colors.grey[200]!),
                  enabledBorder: border(Colors.grey[200]!),
                  focusedBorder: border(const Color(0xff10b981), width: 2.0),
                  errorBorder: border(Colors.red),
                  focusedErrorBorder: border(Colors.red, width: 2.0),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mật khẩu mới',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                validator: _validatePassword,
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu mới',
                  filled: true,
                  fillColor: const Color(0xfff9fafb),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  border: border(Colors.grey[200]!),
                  enabledBorder: border(Colors.grey[200]!),
                  focusedBorder: border(const Color(0xff10b981), width: 2.0),
                  errorBorder: border(Colors.red),
                  focusedErrorBorder: border(Colors.red, width: 2.0),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Xác nhận mật khẩu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _resetPassword(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  if (value != _passwordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Nhập lại mật khẩu mới',
                  filled: true,
                  fillColor: const Color(0xfff9fafb),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  border: border(Colors.grey[200]!),
                  enabledBorder: border(Colors.grey[200]!),
                  focusedBorder: border(const Color(0xff10b981), width: 2.0),
                  errorBorder: border(Colors.red),
                  focusedErrorBorder: border(Colors.red, width: 2.0),
                ),
              ),
            ],
            if (_message != null) ...[
              const SizedBox(height: 16),
              _StatusBanner(
                message: _message!,
                color: const Color(0xff047857),
                backgroundColor: const Color(0xffd1fae5),
                borderColor: const Color(0xff6ee7b7),
                icon: Icons.check_circle_outline,
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              _StatusBanner(
                message: _errorMessage!,
                color: const Color(0xffdc2626),
                backgroundColor: const Color(0xfffee2e2),
                borderColor: const Color(0xfffca5a5),
                icon: Icons.error_outline,
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_otpSent ? _resetPassword : _sendOtp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff10b981),
                  disabledBackgroundColor: const Color(
                    0xff10b981,
                  ).withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _otpSent ? 'Đổi mật khẩu' : 'Gửi mã OTP',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (_otpSent) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: const Text(
                    'Gửi lại mã OTP',
                    style: TextStyle(color: Color(0xff10b981)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất một chữ hoa';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất một chữ thường';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất một chữ số';
    }
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) {
      return 'Mật khẩu phải có ít nhất một ký tự đặc biệt';
    }
    return null;
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
  });

  final String message;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
