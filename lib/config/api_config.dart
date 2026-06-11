class ApiConfig {
  ApiConfig._();

  /// URL gốc BE.
  /// Android emulator dùng `http://10.0.2.2:3000/api` thay vì localhost.
  static const String baseUrl = 'http://localhost:3000/api';

  static const String login = '/auth/login';
}
