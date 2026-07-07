import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waste_collection_management_system/presentation/verify_email/verify_email_screen.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';

class RegisterPanelForm extends StatefulWidget {
  const RegisterPanelForm({super.key});

  @override
  State<RegisterPanelForm> createState() => _RegisterPanelFormState();
}

class _RegisterPanelFormState extends State<RegisterPanelForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder myBorder(Color color, {double width = 1.0}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
              const SizedBox(height: 24),
              const Text('Tạo tài khoản', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5)),
              const Text('Tham gia cộng đồng sống xanh', style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 24),

              // Full Name
              const Text('Họ và tên', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fullNameController,
                focusNode: _fullNameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                textCapitalization: TextCapitalization.words,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ÿ\s'.-]"))],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập họ và tên';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Nguyễn Văn A',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xfff9fafb),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: myBorder(Colors.grey[200]!),
                  enabledBorder: myBorder(Colors.grey[200]!),
                  focusedBorder: myBorder(const Color(0xff10b981), width: 2.0),
                  errorBorder: myBorder(Colors.red),
                  focusedErrorBorder: myBorder(Colors.red, width: 2.0),
                  errorStyle: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                keyboardType: TextInputType.emailAddress,
                textCapitalization: TextCapitalization.none,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) return 'Vui lòng nhập địa chỉ email hợp lệ';
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
                  errorStyle: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              const Text('Mật khẩu', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                  if (value.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
                  if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Mật khẩu phải có ít nhất một chữ hoa';
                  if (!RegExp(r'[a-z]').hasMatch(value)) return 'Mật khẩu phải có ít nhất một chữ thường';
                  if (!RegExp(r'[0-9]').hasMatch(value)) return 'Mật khẩu phải có ít nhất một chữ số';
                  if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) return 'Mật khẩu phải có ít nhất một ký tự đặc biệt';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xfff9fafb),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: myBorder(Colors.grey[200]!),
                  enabledBorder: myBorder(Colors.grey[200]!),
                  focusedBorder: myBorder(const Color(0xff10b981), width: 2.0),
                  errorBorder: myBorder(Colors.red),
                  focusedErrorBorder: myBorder(Colors.red, width: 2.0),
                  errorStyle: const TextStyle(fontSize: 12),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              const Text('Xác nhận mật khẩu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmController,
                focusNode: _confirmFocus,
                textInputAction: TextInputAction.done,
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
                  if (value != _passwordController.text) return 'Mật khẩu không khớp';
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Nhập lại mật khẩu',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xfff9fafb),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: myBorder(Colors.grey[200]!),
                  enabledBorder: myBorder(Colors.grey[200]!),
                  focusedBorder: myBorder(const Color(0xff10b981), width: 2.0),
                  errorBorder: myBorder(Colors.red),
                  focusedErrorBorder: myBorder(Colors.red, width: 2.0),
                  errorStyle: const TextStyle(fontSize: 12),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          _clearError();
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              await _authService.register(
                                _fullNameController.text.trim(),
                                _emailController.text.trim(),
                                _passwordController.text,
                                _confirmController.text,
                              );
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VerifyEmailScreen(
                                      email: _emailController.text.trim(),
                                    ),
                                  ),
                                );
                              }
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
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff10b981),
                    disabledBackgroundColor: const Color(0xff10b981).withValues(alpha: 0.7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Gửi mã OTP', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.send, size: 18, color: Colors.white),
                          ],
                        ),
                ),
              ),

              // API error banner
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản?', style: TextStyle(color: Colors.black54, fontSize: 14)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Đăng nhập', style: TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.bold)),
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
