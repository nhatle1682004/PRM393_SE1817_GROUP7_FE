import 'package:flutter/material.dart';
import 'widgets/verify_email_form.dart'; // Chỉ giữ lại import cái Form thôi nhé

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, // Nền trắng tinh khôi toàn màn hình
      body: Center(
        // SingleChildScrollView giúp an toàn khi bàn phím điện thoại đẩy lên hoặc màn hình bị thu nhỏ
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24), // Cách đều các cạnh màn hình
          child: VerifyEmailForm(), // Gọi form OTP ra nằm chính giữa màn hình luôn
        ),
      ),
    );
  }
}