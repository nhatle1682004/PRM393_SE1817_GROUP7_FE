import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/locale_scope.dart';
import 'package:waste_collection_management_system/screens/home/home_screen.dart';
import 'package:waste_collection_management_system/screens/register/register_screen.dart';
import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/widgets/language_toggle.dart';

class RightPanelForm extends StatefulWidget {
  const RightPanelForm({super.key});

  @override
  State<RightPanelForm> createState() => _RightPanelFormState();
}

class _RightPanelFormState extends State<RightPanelForm> {
  static final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(alignment: Alignment.centerRight, child: const LanguageToggle()),
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
            const SizedBox(height: 48),
            Text(locale.tr('welcome_back'), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.5)),
            const SizedBox(height: 10),
            Text(locale.tr('sign_in_subtitle'), style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 40),
            Text(locale.tr('email'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(locale.tr('password'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text(locale.tr('forgot_password'), style: const TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) return locale.tr('err_password_required');
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
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          bool isSuccess = await ApiService.mockLogin(
                            _emailController.text.trim(),
                            _passwordController.text,
                          );
                          setState(() => _isLoading = false);
                          if (isSuccess && mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff10b981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(locale.tr('log_in'), style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(locale.tr('no_account'), style: const TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  child: Text(locale.tr('sign_up'), style: const TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
