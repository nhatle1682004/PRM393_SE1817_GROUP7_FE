import 'dart:async'; // 🛠️ THÊM: Thư viện để sử dụng Timer đếm ngược
import 'package:flutter/material.dart';

class VerifyEmailForm extends StatefulWidget {
  const VerifyEmailForm({super.key});

  @override
  State<VerifyEmailForm> createState() => _VerifyEmailFormState();
}

class _VerifyEmailFormState extends State<VerifyEmailForm> {
  // Biến quản lý bộ đếm thời gian
  Timer? _timer;
  int _startSeconds = 300; // 🛠️ ĐÃ SỬA: Đổi từ 60s thành 300s (Tương đương 5 phút)
  bool _canResend = false; // Trạng thái cho phép bấm nút gửi lại mã

  @override
  void initState() {
    super.initState();
    _startCountdown(); // Tự động chạy đếm ngược khi vừa vào màn hình
  }

  // Hàm khởi chạy bộ đếm ngược
  void _startCountdown() {
    setState(() {
      _startSeconds = 300; // 🛠️ ĐÃ SỬA: Reset về lại 5 phút khi bấm gửi lại mã
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startSeconds == 0) {
        setState(() {
          _timer?.cancel();
          _canResend = true; // Kích hoạt nút bấm gửi lại khi về 0
        });
      } else {
        setState(() {
          _startSeconds--;
        });
      }
    });
  }

  // Hàm định dạng số giây thành chuỗi mm:ss (Ví dụ: 05:00, 04:59)
  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hủy bộ đếm khi thoát màn hình để tránh rò rỉ bộ nhớ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hàm tạo viền ô nhập OTP nhanh
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
          // 1. LOGO ECOCOLLECT SMALL
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xff10b981),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'EcoCollect',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 2. TIÊU ĐỀ CHÍNH
          const Text(
            'Verify Email',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5),
          ),
          const Text(
            'Enter the OTP sent to your email',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 24),

          // 3. THÈ THÔNG BÁO GỘP THÔNG MINH
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xfff0fdf4), // Màu xanh lá siêu nhẹ pastel
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
                      const Text(
                        'An OTP has been sent to:',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hoangnhatledx2@gmail.com',
                        style: TextStyle(color: const Color(0xff10b981), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 4. CHUỖI Ô NHẬP OTP RỜI (6 Ô vuông cao cấp)
          const Text(
            'Enter OTP Code',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 52,
                height: 56,
                child: TextField(
                  onChanged: (value) {
                    if (value.length == 1 && index < 5) {
                      FocusScope.of(context).nextFocus(); // Tự động nhảy sang ô phải khi gõ xong
                    }
                    if (value.isEmpty && index > 0) {
                      FocusScope.of(context).previousFocus(); // Tự động lùi sang trái khi bấm xóa
                    }
                  },
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  maxLength: 1,
                  decoration: InputDecoration(
                    counterText: "", // Giấu dòng đếm ký tự
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

          // 🛠️ THÊM: KHỐI DÒNG CHỮ ĐẾM NGƯỢC & NÚT GỬI LẠI MÃ (RESEND OTP)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Didn't receive the code? ",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              _canResend
                  ? GestureDetector(
                onTap: () {
                  // Gọi logic gửi lại OTP của Backend ở đây
                  _startCountdown(); // Khởi động lại bộ đếm từ đầu (5 phút)
                },
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: Color(0xff10b981),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              )
                  : Text(
                'Resend in ${_formatTime(_startSeconds)}', // Sẽ hiển thị dạng 05:00 -> 00:00
                style: const TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 5. NÚT XÁC THỰC (Verify OTP)
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verify OTP',
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.bolt, size: 18, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 6. NÚT QUAY LẠI (Go Back) viền mảnh tinh tế
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context), // Quay lại trang Register trước đó
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[200]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 18, color: Colors.black54),
                  SizedBox(width: 8),
                  Text(
                    'Go Back',
                    style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}