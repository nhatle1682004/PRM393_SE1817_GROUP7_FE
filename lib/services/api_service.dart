import 'package:dio/dio.dart';
import '../config/api_config.dart';
// 🛠️ THÊM: Import file quản lý lưu trữ token của bạn vào đây
import '../services/storage_service.dart';

class ApiService {
  // Khởi tạo StorageService để xử lý đọc/ghi token
  static final StorageService _storageService = StorageService();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
    // 🛠️ THÊM INTERCEPTOR: Tự động chạy mỗi khi có request gửi đi
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Đọc token đã lưu dưới máy điện thoại lên
        String? token = await _storageService.getToken();

        if (token != null) {
          // Tự động đính kèm token chuẩn Bearer cho tất cả request gửi lên .NET
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Xử lý lỗi tập trung khi token hết hạn (mã lỗi 401 Unauthorized từ .NET)
        if (e.response?.statusCode == 401) {
          print("🚨 Token hết hạn hoặc không hợp lệ!");
          // Bạn có thể xử lý xóa token cũ và đá người dùng ra màn Login ở đây
        }
        return handler.next(e);
      },
    ),
  );

  // 🕵️ HÀM ĐĂNG NHẬP GIẢ LẬP (MOCK LOGIN) KHI CHƯA CÓ BACKEND .NET
  static Future<bool> mockLogin(String email, String password) async {
    // Giả lập độ trễ mạng mất 1.5 giây giống như đang gọi API thật
    await Future.delayed(const Duration(milliseconds: 1500));

    // Điều kiện giả lập đăng nhập thành công đơn giản (chỉ cần nhập text)
    if (email.isNotEmpty && password.length >= 6) {
      // Tự sinh ra 1 chuỗi JWT giả để test tính năng lưu trữ
      String mockJwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.MockTokenChoGiaoDienUI2026.xxxx";

      // Lưu ngầm token giả lập xuống kho bảo mật an toàn
      await _storageService.saveToken(mockJwtToken);
      return true;
    }
    return false;
  }

  static Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> post(String endpoint, {dynamic body}) async {
    try {
      final response = await _dio.post(endpoint, data: body);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> put(String endpoint, {dynamic body}) async {
    try {
      final response = await _dio.put(endpoint, data: body);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Server error: ${error.response?.statusCode}';
    } else {
      return error.message ?? 'Unknown connection error';
    }
  }
}