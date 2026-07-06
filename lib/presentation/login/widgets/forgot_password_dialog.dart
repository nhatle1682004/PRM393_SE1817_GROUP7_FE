import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _otp = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_email.text.trim().isEmpty) {
      _setMessage('Vui lòng nhập email.', true);
      return;
    }
    await _run(() async {
      await _auth.forgotPassword(_email.text.trim());
      setState(() => _otpSent = true);
      _setMessage('Nếu email hợp lệ, OTP reset mật khẩu đã được gửi.', false);
    });
  }

  Future<void> _resetPassword() async {
    if (_otp.text.trim().isEmpty ||
        _newPassword.text.isEmpty ||
        _confirmPassword.text.isEmpty) {
      _setMessage('Vui lòng nhập OTP và mật khẩu mới.', true);
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      _setMessage('Mật khẩu xác nhận không khớp.', true);
      return;
    }
    await _run(() async {
      await _auth.resetPassword(
        _email.text.trim(),
        _otp.text.trim(),
        _newPassword.text,
        _confirmPassword.text,
      );
      if (mounted) Navigator.pop(context, true);
    });
  }

  Future<void> _run(Future<void> Function() task) async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await task();
    } catch (e) {
      _setMessage(e.toString(), true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setMessage(String message, bool isError) {
    setState(() {
      _message = message;
      _isError = isError;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_otpSent ? 'Reset mật khẩu' : 'Quên mật khẩu'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _email,
              enabled: !_otpSent,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            if (_otpSent) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _otp,
                decoration: const InputDecoration(labelText: 'OTP'),
              ),
              TextField(
                controller: _newPassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
              ),
              TextField(
                controller: _confirmPassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                ),
              ),
            ],
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(
                _message!,
                style: TextStyle(color: _isError ? Colors.red : Colors.green),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
        FilledButton(
          onPressed: _loading ? null : (_otpSent ? _resetPassword : _sendOtp),
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_otpSent ? 'Reset' : 'Gửi OTP'),
        ),
      ],
    );
  }
}
