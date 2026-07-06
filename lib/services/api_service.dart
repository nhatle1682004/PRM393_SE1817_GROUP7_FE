import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
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
    // Giả lập độ trễ mạng mất 1.5 giây giống như dang gọi API thật
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

  /// Upload multipart form data (for image uploads)
  static Future<Response> uploadMultipart(String endpoint, {
    File? imageFile,
    XFile? webImageFile,
    required double latitude,
    required double longitude,
    String? description,
    required List<int> wasteTypeIds,
  }) async {
    try {
      MultipartFile? multipartFile;

      if (kIsWeb && webImageFile != null) {
        final bytes = await webImageFile.readAsBytes();
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: webImageFile.name,
        );
      } else if (imageFile != null) {
        multipartFile = await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        );
      }

      if (multipartFile == null) throw "Hình ảnh không hợp lệ";

      final formData = FormData.fromMap({
        'Image': multipartFile,
        'Latitude': latitude,
        'Longitude': longitude,
        if (description != null && description.isNotEmpty) 'Description': description,
        'WasteTypeIds': wasteTypeIds,
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
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
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      // Thử đọc message từ nhiều dạng response
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      if (data is Map && data.containsKey('Message')) {
        return data['Message'];
      }

      // Với lỗi validation của FluentValidation, BE trả dạng dictionary errors
      if (data is Map && data.containsKey('errors')) {
        final errors = data['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstField = errors.keys.first;
          final firstError = errors[firstField];
          if (firstError is List && firstError.isNotEmpty) {
            return firstError[0].toString();
          }
        }
      }

      // Fallback: hiển thị status code rõ ràng
      if (statusCode == 400) return 'Yêu cầu không hợp lệ';
      if (statusCode == 401) return 'Không được xác thực';
      if (statusCode == 403) return 'Không có quyền truy cập';
      if (statusCode == 404) return 'Không tìm thấy';
      if (statusCode == 409) return 'Xung đột dữ liệu';
      if (statusCode != null) return 'Lỗi máy chủ ($statusCode)';
      return 'Server error';
    } else {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return 'Hết thời gian kết nối. Vui lòng thử lại.';
      }
      if (error.type == DioExceptionType.connectionError) {
        return 'Không thể kết nối máy chủ. Kiểm tra mạng.';
      }
      return error.message ?? 'Lỗi kết nối không xác định';
    }
  }
}