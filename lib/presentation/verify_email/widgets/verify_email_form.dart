import 'dart:async';

import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';

class VerifyEmailForm extends StatefulWidget {
  final String email;

  const VerifyEmailForm({super.key, required this.email});

  @override
  State<VerifyEmailForm> createState() => _VerifyEmailFormState();
}

class _VerifyEmailFormState extends State<VerifyEmailForm> {
  final _authService = AuthService();
  final _otpController = TextEditingController();
  Timer? _timer;
  int _seconds = 300;
  bool _canResend = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _seconds = 300;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _seconds = 0;
            _canResend = true;
          });
        }
      } else if (mounted) {
        setState(() => _seconds--);
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Vui lòng nhập đủ 6 số OTP.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _authService.verifyOtp(widget.email, otp);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _authService.resendOtp();
      _startCountdown();
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco, color: Color(0xff10b981), size: 24),
              SizedBox(width: 12),
              Text(
                'Waste Collection',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Xác minh email',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhập mã OTP đã gửi đến ${widget.email}',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'OTP',
              border: OutlineInputBorder(),
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: _canResend
                ? TextButton(
                    onPressed: _isLoading ? null : _resendOtp,
                    child: const Text('Gửi lại OTP'),
                  )
                : Text(
                    'Gửi lại sau ${_formatTime(_seconds)}',
                    style: const TextStyle(color: Colors.black54),
                  ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _isLoading ? null : _verifyOtp,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Xác minh OTP'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại'),
            ),
          ),
        ],
      ),
    );
  }
}
