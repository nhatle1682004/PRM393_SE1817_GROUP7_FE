import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/locale_scope.dart';
import 'package:waste_collection_management_system/screens/home/widgets/language_toggle.dart';
import 'package:waste_collection_management_system/screens/verify_email/verify_email_screen.dart';

class RegisterPanelForm extends StatefulWidget {
  const RegisterPanelForm({super.key});

  @override
  State<RegisterPanelForm> createState() => _RegisterPanelFormState();
}

class _RegisterPanelFormState extends State<RegisterPanelForm> {
  static final _formKey = GlobalKey<FormState>();
  static final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final locale = LocaleScope.of(context);

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
              const SizedBox(height: 24),
              Text(locale.tr('create_account'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5)),
              Text(locale.tr('join_community'), style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 24),
              Text(locale.tr('full_name'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              TextFormField(
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return locale.tr('err_name_required');
                  return null;
                },
                decoration: InputDecoration(
                  hintText: locale.tr('name_hint'),
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
              Text(locale.tr('email'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              TextFormField(
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return locale.tr('err_email_required');
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) return locale.tr('err_email_invalid');
                  return null;
                },
                decoration: InputDecoration(
                  hintText: locale.tr('email_hint'),
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
              Text(locale.tr('password'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) return locale.tr('err_password_required');
                  if (value.length < 8) return locale.tr('err_password_min_length');
                  if (!RegExp(r'[a-z]').hasMatch(value)) return locale.tr('err_password_lowercase');
                  if (!RegExp(r'[0-9]').hasMatch(value)) return locale.tr('err_password_number');
                  if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) return locale.tr('err_password_special');
                  return null;
                },
                decoration: InputDecoration(
                  hintText: locale.tr('password_hint'),
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xfff9fafb),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey[400], size: 20),
                  ),
                  border: myBorder(Colors.grey[200]!),
                  enabledBorder: myBorder(Colors.grey[200]!),
                  focusedBorder: myBorder(const Color(0xff10b981), width: 2.0),
                  errorBorder: myBorder(Colors.red),
                  focusedErrorBorder: myBorder(Colors.red, width: 2.0),
                ),
              ),
              const SizedBox(height: 16),
              Text(locale.tr('confirm_password'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextFormField(
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) return locale.tr('err_confirm_required');
                  if (value != _passwordController.text) return locale.tr('err_password_mismatch');
                  return null;
                },
                decoration: InputDecoration(
                  hintText: locale.tr('confirm_password_hint'),
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xfff9fafb),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey[400], size: 20),
                  ),
                  border: myBorder(Colors.grey[200]!),
                  enabledBorder: myBorder(Colors.grey[200]!),
                  focusedBorder: myBorder(const Color(0xff10b981), width: 2.0),
                  errorBorder: myBorder(Colors.red),
                  focusedErrorBorder: myBorder(Colors.red, width: 2.0),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const VerifyEmailScreen()));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff10b981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(locale.tr('send_otp'), style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const Icon(Icons.send, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(locale.tr('already_have_account'), style: const TextStyle(color: Colors.black54, fontSize: 14)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(locale.tr('sign_in'), style: const TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.bold)),
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
