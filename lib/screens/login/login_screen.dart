import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/screens/login/widgets/left_panel_banner.dart';
import 'package:waste_collection_management_system/screens/login/widgets/right_panel_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // LayoutBuilder giống như một chiếc thước đo tự động chạy liên tục để đo chiều rộng màn hình
      body: LayoutBuilder(
        builder: (context, constraints) {
          // CHỖ HIỂN THỊ WEB ( MÀN HÌNH > 800px)
          if (constraints.maxWidth > 800) {
            return Row(
              children: [
                // phần banner bên trái chiếm 50%
                Expanded(
                  flex: 1, // chiếm 1 phần diện tích bằng nhau
                  child: Container(
                    color: const Color(0xffd2ebd9), // màu nền xanh nhạt
                    child: const Center(
                      child: SingleChildScrollView(
                        child: LeftPanelBanner(),
                      ),
                    ),
                  ),
                ),
                // phấn bên phải chiếm 50%
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white, // nen trang cho form dang nhap
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 64,
                        horizontal: 48,
                      ), //EdgeInsets.symmetric để căn giữa form
                      child: Center(child: RightPanelForm()),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // CHỖ HIỂN THỊ MOBILE ( MÀN HÌNH < 800px)
            return const Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                  child: Center(child: RightPanelForm()),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
