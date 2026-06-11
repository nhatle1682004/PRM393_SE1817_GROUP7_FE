import 'package:flutter/material.dart';
import '../services/auth_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Tương đương useState formData
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Tương đương useState loading, error, showPassword
  bool _loading = false;
  String _error = '';
  bool _showPassword = false;

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  static const double _desktopBreakpoint = 900;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleChange() {
    if (_error.isNotEmpty) {
      setState(() => _error = '');
    }
  }

  Future<void> _handleSubmit() async {
    // validate() kiểm tra email/password trước khi gọi API — tránh request thừa.
    if (!_formKey.currentState!.validate()) return;

    // Bật loading + xóa lỗi cũ → UI hiện spinner, khóa nút (giống setLoading(true) React).
    setState(() {
      _loading = true;
      _error = '';
    });

    // -------------------------------------------------------------------------
    // GỌI API (Đang tạm comment vì chưa có API thật)
    /*
    try {
      final response = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful!')),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() => _error = err.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    */

    // Demo UI — mô phỏng loading khi chưa có API
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _loading = false;
      // Thông báo giả lập thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demo Login Successful!')),
      );
    });
    // -------------------------------------------------------------------------
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _desktopBreakpoint;

          if (isWide) {
            return Row(
              children: [
                Expanded(child: _buildLeftPanel()),
                Expanded(child: _buildRightPanel(isWide: true)),
              ],
            );
          }

          return _buildRightPanel(isWide: false);
        },
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade700,
            Colors.green.shade500,
            Colors.green.shade400,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEcoIcons(),
                const SizedBox(height: 32),
                const Text(
                  'Together for a Greener Future',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Join our community in making waste recycling simple, '
                  'rewarding, and impactful. Every action counts towards a '
                  'sustainable planet.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                _buildStatsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEcoIcons() {
    const icons = ['🍃', '♻️', '🌲'];
    return Row(
      children: icons
          .map(
            (icon) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 28)),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildStatsRow() {
    const stats = [
      ('50K+', 'Active Users'),
      ('120T', 'Waste Recycled'),
      ('98%', 'Satisfaction'),
    ];

    return Row(
      children: stats
          .map(
            (stat) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        stat.$1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat.$2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildRightPanel({required bool isWide}) {
    return Container(
      color: Colors.grey.shade50,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 48 : 24,
            vertical: 32,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBrand(),
                const SizedBox(height: 32),
                _buildWelcomeText(),
                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildErrorAlert(),
                ],
                const SizedBox(height: 24),
                _buildLoginForm(),
                const SizedBox(height: 24),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Text('🍃', style: TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 10),
        const Text(
          'EcoCollect',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return const Column(
      children: [
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sign in to your account to continue your eco journey',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildErrorAlert() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      onChanged: _handleChange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@example.com',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!_loading) _handleSubmit();
            },
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _showPassword = !_showPassword);
                },
                icon: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey.shade600,
                ),
                tooltip: _showPassword ? 'Hide password' : 'Show password',
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _loading ? null : _handleSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.green.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.black54),
        ),
        GestureDetector(
          // Chỉ hiển thị nút — chưa điều hướng (chưa có trang Register).
          onTap: () {},
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
