import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiService {
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
  );

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
      // Backend returned an error response
      final data = error.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Server error: ${error.response?.statusCode}';
    } else {
      // Something happened in setting up or sending the request
      return error.message ?? 'Unknown connection error';
    }
  }
}
