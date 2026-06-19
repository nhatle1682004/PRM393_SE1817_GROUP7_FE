
class AuthService {
  /// Hàm đăng nhập
  /// Trả về dữ liệu từ server nếu thành công, ném ra lỗi nếu thất bại
  Future<Map<String, dynamic>> login(String email, String password) async {
    // -------------------------------------------------------------------------
    // VÍ DỤ CÁCH GỌI API THẬT (Bỏ comment khi có API)
    // -------------------------------------------------------------------------
    /*
    try {
      final response = await ApiService.post(
        ApiConfig.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      // Trả về dữ liệu (thường chứa token và thông tin user)
      return response.data;
    } catch (e) {
      // Lỗi đã được xử lý ở ApiService (trả về String thông báo lỗi)
      rethrow;
    }
    */

    // Hiện tại chưa có API, trả về Map trống hoặc ném lỗi để tránh lỗi compile
    throw 'API chưa sẵn sàng. Hãy cấu hình backend trước.';
  }
}
