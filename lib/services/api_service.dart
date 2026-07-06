import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/services/storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static final StorageService _storageService = StorageService();

  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await _storageService.getToken();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              handler.next(options);
            },
            onError: (error, handler) async {
              final isLoginApi = error.requestOptions.path.contains(
                '/auth/login',
              );
              if (error.response?.statusCode == 401 && !isLoginApi) {
                await _storageService.clear();
              }
              handler.next(error);
            },
          ),
        );

  static String buildFileUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final root = ApiConfig.baseUrl.replaceFirst('/api', '');
    return '$root${path.startsWith('/') ? '' : '/'}$path';
  }

  static Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response<dynamic>> post(
    String endpoint, {
    dynamic body,
    Options? options,
  }) async {
    try {
      return await _dio.post(endpoint, data: body, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response<dynamic>> put(
    String endpoint, {
    dynamic body,
    Options? options,
  }) async {
    try {
      return await _dio.put(endpoint, data: body, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response<dynamic>> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response<dynamic>> multipart(
    String endpoint, {
    String method = 'POST',
    required Map<String, dynamic> fields,
    Map<String, File?> files = const {},
    Map<String, XFile?> webFiles = const {},
  }) async {
    try {
      final map = <String, dynamic>{...fields};
      for (final entry in files.entries) {
        final file = entry.value;
        if (file != null) {
          map[entry.key] = await MultipartFile.fromFile(
            file.path,
            filename: file.path.split(Platform.pathSeparator).last,
          );
        }
      }
      for (final entry in webFiles.entries) {
        final file = entry.value;
        if (file != null) {
          map[entry.key] = MultipartFile.fromBytes(
            await file.readAsBytes(),
            filename: file.name,
          );
        }
      }

      final formData = FormData.fromMap(map, ListFormat.multiCompatible);
      final options = Options(headers: {'Content-Type': 'multipart/form-data'});
      return method.toUpperCase() == 'PUT'
          ? await _dio.put(endpoint, data: formData, options: options)
          : await _dio.post(endpoint, data: formData, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static Future<Response<dynamic>> uploadMultipart(
    String endpoint, {
    File? imageFile,
    XFile? webImageFile,
    required double latitude,
    required double longitude,
    String? description,
    required List<int> wasteTypeIds,
  }) {
    return multipart(
      endpoint,
      fields: {
        'Latitude': latitude,
        'Longitude': longitude,
        'Description': description ?? '',
        'WasteTypeIds': wasteTypeIds,
      },
      files: {'Image': kIsWeb ? null : imageFile},
      webFiles: {'Image': kIsWeb ? webImageFile : null},
    );
  }

  static ApiException _handleError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (data is Map) {
      final directMessage =
          data['message'] ?? data['Message'] ?? data['title'] ?? data['Title'];
      if (directMessage != null)
        return ApiException(directMessage.toString(), statusCode: statusCode);

      final errors = data['errors'] ?? data['Errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty)
          return ApiException(first.first.toString(), statusCode: statusCode);
        return ApiException(first.toString(), statusCode: statusCode);
      }
    }

    switch (statusCode) {
      case 400:
        return ApiException('Yêu cầu không hợp lệ', statusCode: statusCode);
      case 401:
        return ApiException('Không được xác thực', statusCode: statusCode);
      case 403:
        return ApiException('Không có quyền truy cập', statusCode: statusCode);
      case 404:
        return ApiException('Không tìm thấy dữ liệu', statusCode: statusCode);
      case 409:
        return ApiException('Dữ liệu bị xung đột', statusCode: statusCode);
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const ApiException('Hết thời gian kết nối. Vui lòng thử lại.');
    }
    if (error.type == DioExceptionType.connectionError) {
      return const ApiException(
        'Không thể kết nối máy chủ. Kiểm tra backend/gateway.',
      );
    }
    return ApiException(
      error.message ?? 'Lỗi kết nối không xác định',
      statusCode: statusCode,
    );
  }
}
