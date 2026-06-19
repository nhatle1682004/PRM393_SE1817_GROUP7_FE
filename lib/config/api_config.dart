class ApiConfig {
  ApiConfig._();

  /// URL gốc của Backend.
  /// Android emulator dùng `http://10.0.2.2:3000/api` thay vì localhost.
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // 1. AUTHENTICATION - api/auth

  /// Đăng nhập (email, password) -> trả về JWT
  static const String login = '/auth/login';

  /// Đăng ký tài khoản citizen
  static const String register = '/auth/register';

  /// Xác thực OTP
  static const String verifyOtp = '/auth/verify-otp';

  /// Đổi mật khẩu
  static const String changePassword = '/auth/change-password';

  /// Gửi OTP khi quên mật khẩu
  static const String forgotPassword = '/auth/forgot-password';

  /// Reset mật khẩu bằng OTP
  static const String resetPassword = '/auth/reset-password';

  // 2. USERS - api/users

  /// Lấy danh sách collector (Admin, Enterprise)
  static const String listCollectors = '/users/collectors';

  /// Danh sách tất cả user hoặc tạo user mới (Admin)
  static const String users = '/users';

  /// Chi tiết, cập nhật hoặc xóa user theo ID
  static String user(int id) => '/users/$id';

  /// Cập nhật trạng thái sẵn sàng (Collector)
  static const String userAvailability = '/users/me/availability';

  /// Vô hiệu hóa user (Admin)
  static String userDeactivate(int id) => '/users/$id/deactivate';

  /// Kích hoạt lại user (Admin)
  static String userActivate(int id) => '/users/$id/activate';

  /// Lấy hoặc cập nhật profile cá nhân (Yêu cầu JWT)
  static const String profile = '/users/me/profile';

  // 3. WASTE REPORTS - api/waste-reports

  /// Danh sách hoặc tạo báo cáo rác mới
  static const String wasteReports = '/waste-reports';

  /// Chi tiết hoặc cập nhật báo cáo rác
  static String reportDetails(int id) => '/waste-reports/$id';

  /// Hủy báo cáo rác (Citizen)
  static String cancelWasteReport(int id) => '/waste-reports/$id/cancel';

  /// Chấp nhận báo cáo rác (Enterprise) -> tạo collection request
  static String acceptWasteReport(int id) => '/waste-reports/$id/accept';

  /// Từ chối báo cáo rác (Enterprise)
  static String rejectWasteReport(int id) => '/waste-reports/$id/reject';

  // 4. COLLECTION REQUESTS - api/collection-requests
  /// Danh sách yêu cầu thu gom (Enterprise)
  static const String collectionRequests = '/collection-requests';

  /// Chi tiết yêu cầu thu gom
  static String collectionRequestDetails(int id) => '/collection-requests/$id';

  /// Tất cả yêu cầu trong hệ thống (Admin)
  static const String collectionRequestAll = '/collection-requests/all';

  /// Lịch sử phân công của một yêu cầu thu gom
  static String collectionAssignmentHistory(int id) => '/collection-requests/$id/assignments';

  // 5. ASSIGNMENTS - api/assignments
  /// Phân công collector mới (Enterprise)
  static const String assignments = '/assignments';

  /// Chi tiết hoặc phân công lại collector (Enterprise/Collector)
  static String assignmentDetails(int id) => '/assignments/$id';

  /// Hủy phân công (Enterprise)
  static String cancelAssignment(int id) => '/assignments/$id/cancel';

  /// Danh sách phân công của collector đang đăng nhập
  static const String myAssignments = '/assignments/my-assignments';

  // 6. COLLECTIONS (Quy trình thu gom) - api/collections

  /// Từ chối phân công kèm lý do (Collector)
  static String declineAssignment(int id) => '/collections/$id/decline';

  /// Bắt đầu quá trình thu gom - OnTheWay (Collector)
  static String startCollection(int id) => '/collections/$id/start';

  /// Đã đến nơi + ảnh trước thu gom (Collector)
  static String confirmArrival(int id) => '/collections/$id/arrived';

  /// Báo cáo sự cố trong quá trình thu gom (Collector)
  static String reportCollectionIssue(int id) => '/collections/$id/report-issue';

  /// Hoàn thành thu gom + ảnh sau thu gom (Collector)
  static String completeCollection(int id) => '/collections/$id/complete';

  // 7. WASTE TYPES - api/waste-types
  /// Danh sách hoặc tạo loại rác mới
  static const String wasteTypes = '/waste-types';

  /// Chi tiết, cập nhật hoặc xóa loại rác
  static String wasteTypeDetails(int id) => '/waste-types/$id';

  // 8. DISTRICTS
  /// Danh sách quận/huyện
  static const String districts = '/districts';

  // 9. DASHBOARD - api/dashboard

  /// Thống kê dashboard cho Admin
  static const String dashboardAdmin = '/dashboard/admin';

  // 10. NOTIFICATIONS

  /// Danh sách thông báo của user đang đăng nhập
  static const String notifications = '/notifications';

  /// Đánh dấu một thông báo đã đọc
  static String markNotificationRead(int id) => '/notifications/$id/read';

  /// Đánh dấu tất cả thông báo đã đọc
  static const String notificationsReadAll = '/notifications/read-all';

  // 11. REWARDS - api/rewards
  /// Danh mục voucher/phần thưởng
  static const String rewardsCatalog = '/rewards/catalog';

  /// Tổng điểm thưởng hiện có
  static const String rewardsBalance = '/rewards/balance';

  /// Lịch sử giao dịch điểm thưởng
  static const String rewardsHistory = '/rewards/history';

  /// Đổi điểm lấy voucher
  static const String rewardsRedeem = '/rewards/redeem';

  // 12. FEEDBACKS - api/feedbacks

  /// Gửi phản hồi mới hoặc lấy tất cả phản hồi (Admin)
  static const String feedbacks = '/feedbacks';

  /// Lấy danh sách phản hồi theo ID báo cáo rác
  static String feedbacksByReport(int reportId) => '/feedbacks/report/$reportId';

  /// Chi tiết phản hồi
  static String feedbackDetails(int id) => '/feedbacks/$id';

  /// Xử lý phản hồi (Resolve - Admin)
  static String feedbackResolve(int id) => '/feedbacks/$id/resolve';

  /// Từ chối phản hồi (Reject - Admin)
  static String feedbackReject(int id) => '/feedbacks/$id/reject';
}
