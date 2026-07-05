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
  Timer? _timer;
  int _startSeconds = 300;
  bool _canResend = false;
  bool _isLoading = false;
  String? _errorMessage;
  final AuthService _authService = AuthService();

  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _startSeconds = 300;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startSeconds == 0) {
        setState(() {
          _timer?.cancel();
          _canResend = true;
        });
      } else {
        setState(() => _startSeconds--);
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  String _getOtpCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _verifyOtp() async {
    final otp = _getOtpCode();
    if (otp.length != 6) return;

    _clearError();
    setState(() => _isLoading = true);

    try {
      await _authService.verifyOtp(widget.email, otp);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      _clearOtpFields();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    _clearError();
    setState(() => _isLoading = true);

    try {
      await _authService.resendOtp();
      _startCountdown();
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

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder otpBorder(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: 1.5),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
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
          const SizedBox(height: 32),
          const Text('Xác minh email', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5)),
          const Text('Nhập mã OTP đã gửi đến email của bạn', style: TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xfff0fdf4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffbbf7d0)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.mark_email_read_outlined, color: Color(0xff10b981), size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mã OTP đã được gửi đến:', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      SizedBox(height: 2),
                      Text(
                        'email@example.com',
                        style: TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Nhập mã OTP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 52,
                height: 56,
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (value) {
                    if (value.length == 1 && index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    }
                    if (value.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                  },
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  maxLength: 1,
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xfff9fafb),
                    contentPadding: EdgeInsets.zero,
                    border: otpBorder(Colors.grey[200]!),
                    enabledBorder: otpBorder(Colors.grey[200]!),
                    focusedBorder: otpBorder(const Color(0xff10b981)),
                    disabledBorder: otpBorder(Colors.grey[200]!),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Không nhận được mã? ', style: TextStyle(color: Colors.black54, fontSize: 14)),
              Text(
                'Gửi lại sau $_startSeconds giây',
                style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff10b981),
                disabledBackgroundColor: const Color(0xff10b981).withOpacity(0.7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Xác minh OTP', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.bolt, size: 18, color: Colors.white),
                      ],
                    ),
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
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xffdc2626), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xffdc2626), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[200]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 18, color: Colors.black54),
                  SizedBox(width: 8),
                  Text('Quay lại', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
