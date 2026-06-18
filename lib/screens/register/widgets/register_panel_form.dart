import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/screens/verify_email/verify_email_screen.dart';

class RegisterPanelForm extends StatefulWidget {
  const RegisterPanelForm({super.key});

  @override
  State<RegisterPanelForm> createState() => _RegisterPanelFormState();
}

class _RegisterPanelFormState extends State<RegisterPanelForm> {
  static final _formKey = GlobalKey<FormState>();
  // Bộ điều khiển để lấy dữ liệu mật khẩu phục vụ cho việc so sánh ở ô Confirm Password
  static final _passwordController = TextEditingController();

  // 👁️ BIẾN TRẠNG THÁI: Quản lý ẩn/hiện độc lập cho từng ô
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    // hàm tạo viền nhanh
    OutlineInputBorder myBorder(Color color, {double width = 1.0}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 420), // giới hạn chiều rộng của form
      child: Form(
        key: _formKey, // Bọc ngoài bằng Form và truyền chìa khóa quản lý vào đây
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(), // bàn phím hiện lên sẽ tự động đẩy form len
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // căn thẳng hàng lề bên trái
            children: [
              // khối 1: logo
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      //BoxDecoration để tạo nền cho icon
                      color: const Color(0xff10b981),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.eco, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'EcoCollect',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  )
                ],
              ),
              const SizedBox(height: 24),
              // khối 2: tiêu đề
              const Text(
                'Create an account',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5),//letterSpacing: -0.5 để tạo khoảng cách chữ
              ),
              const Text(
                'Join our eco-friendly community',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              // khối 3: form đăng ký
              const Text(
                'Full Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextFormField(
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                }, // 🛠️ CHỖ SỬA: Thêm dấu phẩy ở đây để hết lỗi cú pháp
                decoration: InputDecoration(
                  hintText: 'John Doe',
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
              const SizedBox(height: 16),
              // khối 4: ô nhập email
              const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              TextFormField(
                // 🛠️ ĐỔI THÀNH THÀNH: TextFormField để thực hiện validation
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  // Biểu thức chính quy kiểm tra định dạng email hợp lệ
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
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
              const SizedBox(height: 16),
              // khối 5: ô nhập mật khẩu
              const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              TextFormField(
                // 🛠️ ĐỔI THÀNH: TextFormField để thực hiện validation
                controller: _passwordController, // Gắn bộ điều khiển lưu giá trị mật khẩu
                obscureText: _obscurePassword, // Đấu nối biến trạng thái vào đây
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  // 2. 🛠️ KIỂM TRA CHỮ THƯỜNG [a-z]
                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                    return 'Password must contain at least one lowercase letter';
                  }
                  // 3. 🛠️ KIỂM TRA SỐ [0-9]
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Password must contain at least one number';
                  }
                  // 4. 🛠️ KIỂM TRA KÝ TỰ ĐẶC BIỆT
                  // RegExp này tìm bất kỳ ký tự nào KHÔNG PHẢI là chữ cái hay chữ số
                  if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) {
                    return 'Password must contain at least one special character';
                  }
                  return null; // Vượt qua tất cả => Hợp lệ!
                },
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xfff9fafb),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  // 🛠️ ĐÃ ĐỔI THÀNH: IconButton để bấm tương tác bật/tắt mắt được
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

              const SizedBox(height: 16),
              // khối 6: nút nhập lại mật khẩu
              const Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                obscureText: _obscureConfirmPassword, // Đấu nối biến trạng thái vào đây
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Confirm your password',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xfff9fafb),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  // 🛠️ ĐÃ ĐỔI THÀNH: IconButton để bấm tương tác bật/tắt mắt được
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
              const SizedBox(height: 24),
              // khối 7 nút bấm gửi mã OTP
              SizedBox(
                width: double.infinity, // Chiếm toàn bộ chiều ngang của form
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Kiểm tra xem toàn bộ form nhập đúng hết điều kiện chưa
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VerifyEmailScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff10b981), // Xanh lục bảo chuẩn thương hiệu
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Căn giữa cả chữ và icon bên trong nút
                    children: [
                      Text(
                        'Send OTP',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8), // Tạo một khoảng cách nhỏ 8px giữa chữ và icon
                      Icon(Icons.send, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // khối 8: dòng đã có tài khoản
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?', style: TextStyle(color: Colors.black54, fontSize: 14)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    // Khi chạm vào chữ "Sign In", nhấc đĩa Register ra khỏi chồng đĩa -> Trở về trang Đăng nhập cũ ngay!
                    onTap: () => Navigator.pop(context), // pop để trở về trang trước đó
                    child: const Text('Sign In', style: TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}