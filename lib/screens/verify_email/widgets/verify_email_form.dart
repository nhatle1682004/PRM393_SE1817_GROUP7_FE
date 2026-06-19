import 'dart:async';
import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/locale_scope.dart';
import 'package:waste_collection_management_system/screens/home/widgets/language_toggle.dart';

class VerifyEmailForm extends StatefulWidget {
  const VerifyEmailForm({super.key});

  @override
  State<VerifyEmailForm> createState() => _VerifyEmailFormState();
}

class _VerifyEmailFormState extends State<VerifyEmailForm> {
  Timer? _timer;
  int _startSeconds = 300;
  bool _canResend = false;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = LocaleScope.of(context);

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
          const Align(alignment: Alignment.centerRight, child: LanguageToggle()),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xff10b981), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.eco, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(locale.tr('app_name'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 32),
          Text(locale.tr('verify_email'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5)),
          Text(locale.tr('verify_email_subtitle'), style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xfff0fdf4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffbbf7d0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.mark_email_read_outlined, color: Color(0xff10b981), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(locale.tr('otp_sent_to'), style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 2),
                      const Text(
                        'Hoangnhatledx2@gmail.com',
                        style: TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(locale.tr('enter_otp_code'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 52,
                height: 56,
                child: TextField(
                  onChanged: (value) {
                    if (value.length == 1 && index < 5) FocusScope.of(context).nextFocus();
                    if (value.isEmpty && index > 0) FocusScope.of(context).previousFocus();
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
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(locale.tr('didnt_receive'), style: const TextStyle(color: Colors.black54, fontSize: 14)),
              _canResend
                  ? GestureDetector(
                onTap: _startCountdown,
                child: Text(locale.tr('resend_otp'), style: const TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.bold, fontSize: 14)),
              )
                  : Text(
                locale.tr('resend_in', params: {'time': _formatTime(_startSeconds)}),
                style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff10b981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(locale.tr('verify_otp'), style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.bolt, size: 18, color: Colors.white),
                ],
              ),
            ),
          ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back, size: 18, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text(locale.tr('go_back'), style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
