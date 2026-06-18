import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/screens/register/register_screen.dart';
import 'package:waste_collection_management_system/screens/home/home_screen.dart';
// 🛠️ THÊM BƯỚC 1: Import file ApiService của bạn vào đây
import 'package:waste_collection_management_system/services/api_service.dart';

// 🛠️ ĐÃ SỬA: Chuyển sang StatefulWidget để quản lý trạng thái ẩn/hiện mắt và Loading nút bấm
class RightPanelForm extends StatefulWidget {
  const RightPanelForm({super.key});

  @override
  State<RightPanelForm> createState() => _RightPanelFormState();
}

class _RightPanelFormState extends State<RightPanelForm> {
  static final _formKey = GlobalKey<FormState>();

  // 🛠️ THÊM BƯỚC 2: Bộ điều khiển thu thập dữ liệu từ các ô nhập liệu
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Biến quản lý ẩn/hiện mật khẩu và hiệu ứng xoay xoay khi bấm nút
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi thoát màn hình để tránh rò rỉ (memory leak)
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  Tạo hàm tạo viền nhanh để code ngắn gọn, dễ nhìn
    OutlineInputBorder myBorder(Color color, {double width = 1.0}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Form(
        key: _formKey, // Bọc ngoài bằng Form và truyền chìa khóa quản lý vào đây để hết lỗi đỏ
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, // căn chỉnh về phía bên trái
          children: [
            // 1. khung chứa logo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    //  Đổi nền icon thành màu xanh lục
                    color: const Color(0xff10b981),
                    borderRadius: BorderRadius.circular(10), // bo góc icon
                  ),
                  // Đổi màu icon chiếc lá thành màu trắng tương phản nổi bật trên nền xanh
                  child: const Icon(Icons.eco, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12), // khoảng cách giữa logo và text
                const Text(
                  'EcoCollect',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48), // khoảng cách giữa logo và form
            const Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sign in to your account to continue your eco journey',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 40), // khoảng cách giữa tiêu đề và form
            // 2. form đăng nhập
            const Text(
              'Email',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController, // 🛠️ ĐẤU NỐI: Bộ điều khiển lấy chữ ô Email
              //nhận chữ từ bàn phím
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              decoration: InputDecoration(
                // trang trí cho textfield
                hintText: 'name@example.com',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: const Color(0xfff9fafb),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                border: myBorder(Colors.grey[200]!),
                enabledBorder: myBorder(
                  Colors.grey[200]!,
                ), // enabledBorder để giữ nguyên viền khi không focus
                focusedBorder: myBorder(const Color(0xff10b981), width: 2.0),
                errorBorder: myBorder(Colors.red),
                focusedErrorBorder: myBorder(Colors.red, width: 2.0),
              ),
            ),
            const SizedBox(height: 24),
            // 3. ô nhập mật khẩu và liên kết "Quên mật khẩu"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Password',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton( // textButton để kích hoạt sự kiện click
                  onPressed: () {},
                  //  Đặt lề nút sát viền phải cho thẳng hàng
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 4. ô nhập mật khẩu
            TextFormField(
              controller: _passwordController, // 🛠️ ĐẤU NỐI: Bộ điều khiển lấy chữ ô Password
              obscureText: _obscurePassword, // ẩn mật khẩu khi nhập dựa theo biến trạng thái
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: const Color(0xfff9fafb),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                // 🛠️ ĐÃ SỬA: Đổi sang IconButton để bắt được sự kiện Click bật/tắt con mắt
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
            // 5. nút đăng nhập
            SizedBox(
              width: double.infinity, // nút đăng nhập chiếm toàn bộ chiều rộng của form
              height: 52,
              child: ElevatedButton(
                // Nếu đang trong quá trình gọi API chờ kết quả thì vô hiệu hóa nút bấm tạm thời
                onPressed: _isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true; // Bật trạng thái xoay xoay loading
                    });

                    // 🛠️ THÊM BƯỚC 3: Gọi hàm đăng nhập giả lập từ tầng ApiService của bạn
                    bool isSuccess = await ApiService.mockLogin(
                      _emailController.text.trim(),
                      _passwordController.text,
                    );

                    setState(() {
                      _isLoading = false; // Tắt trạng thái loading khi có kết quả
                    });

                    if (isSuccess) {
                      // Nếu dữ liệu điền hợp lệ -> Tiến hành gọi API Đăng nhập lên .NET Web API ở đây (Hiện tại đang chạy Mock lưu Token giả lập)
                      print("🎉 ĐĂNG NHẬP GIẢ LẬP THÀNH CÔNG VÀ ĐÃ LƯU TOKEN XUỐNG MÁY!");

                      // Thêm lệnh chuyển màn hình vào Dashboard/Home tại đây sau này:
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      }
                    } else {
                      print("❌ Đăng nhập thất bại.");
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff10b981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                // hiển thị vòng xoay nếu đang load, ngược lại hiện text 'Log In' bình thường
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text('Log In', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 28), // 🛠️ NOTE ĐÃ SỬA: Tăng khoảng cách lên 28 cho thoáng mắt
            // 6. dòng Sign Up dưới cùng
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?", style: TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(width: 6),
                GestureDetector( // GestureDetector để kích hoạt sự kiện click
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen())
                    );
                  },
                  child: const Text('Sign Up',
                    style: TextStyle(color: const Color(0xff10b981), fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}