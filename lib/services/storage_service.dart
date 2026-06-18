import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  // Khởi tạo bộ lưu trữ bảo mật của hệ thống
  final _storage = const FlutterSecureStorage();

  // Từ khóa cố định để định danh dữ liệu trong máy
  static const _tokenKey = 'access_token';
  static const _userKey = 'username'; // 🛠️ THÊM: Từ khóa định danh cho tên người dùng

  // ================= TỪ KHÓA TOKEN =================

  // Hàm ghi Token vào bộ nhớ máy
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Hàm đọc Token từ bộ nhớ máy ra để xem
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // ================= TỪ KHÓA USERNAME =================

  // 🛠️ THÊM: Hàm lưu tên người dùng tạm thời khi bấm Login giả lập
  Future<void> saveUsername(String name) async {
    await _storage.write(key: _userKey, value: name);
  }

  // 🛠️ THÊM: Hàm đọc tên người dùng lên để hiển thị động lên thanh Header
  Future<String?> getUsername() async {
    return await _storage.read(key: _userKey);
  }

  // ================= ĐĂNG XUẤT =================

  // Hàm xóa Token và Tên khi Đăng xuất (Được nâng cấp để xóa sạch cả hai)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey); // 🛠️ THÊM: Xóa luôn tên khi Log out
  }
}