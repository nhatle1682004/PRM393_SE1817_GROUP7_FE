import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/screens/home/widgets/reate_report_screen.dart';
import 'widgets/header_section.dart';
import 'widgets/stats_card.dart';
import '../../../config/languages.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Khai báo biến trạng thái ngôn ngữ (Mặc định ban đầu là tiếng Anh)
  bool _isVietnamese = false;

  // 🛠️ THÊM: Biến trạng thái quản lý Tab hiện tại (0 = Home Dashboard, 1 = Create Report,...)
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 📐 Đo chiều rộng màn hình hiện tại của thiết bị
    double screenWidth = MediaQuery.of(context).size.width;

    // Kiểm tra xem có phải là màn hình Mobile hay không (thường nhỏ hơn 768px)
    bool isMobile = screenWidth < 768;

    // Lấy bộ từ điển ngôn ngữ tương ứng
    var text = _isVietnamese ? Languages.vi : Languages.en;

    return Scaffold(
      // Màu xám Slate tạo độ tương phản cực tốt giúp nổi bật các hộp nội dung màu trắng
      backgroundColor: const Color(0xfff1f5f9),
      body: Column(
        children: [
          // 1. Khối Header trên cùng
          HeaderSection(
            isVietnamese: _isVietnamese,
            currentTabIndex: _currentTabIndex, // 🛠️ ĐÃ SỬA: Truyền tab hiện tại sang Header
            onLanguageChanged: () {
              setState(() {
                _isVietnamese = !_isVietnamese; // Đảo trạng thái qua lại giữa Anh <-> Việt
              });
            },
            onTabChanged: (index) {
              setState(() {
                _currentTabIndex = index; // 🛠️ ĐÃ SỬA: Cập nhật vị trí tab khi bấm để hoán đổi UI bên dưới
              });
            },
          ),

          // 2. KHỐI NỘI DUNG CHÍNH (Tự động thay đổi theo Tab)
          Expanded(
            child: _currentTabIndex == 1
                ? CreateReportScreen(text: text) // 🚀 TAB 1: Bật trang Tạo báo cáo rác thải
                : _buildDashboardHome(isMobile, text), // ĐỒNG THỜI GIỮ TAB 0 HOẶC KHÁC: Trang Dashboard chính cũ
          ),
        ],
      ),
    );
  }

  // --- 📦 Widget con: Tách khối giao diện Dashboard Home cũ ra riêng cho code sạch sẽ ---
  Widget _buildDashboardHome(bool isMobile, Map<String, String> text) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24), // Thu nhỏ lề nếu là mobile
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= KHỐI 1: 3 Ô ĐẾM SỐ LIỆU ĐÃ ĐƯỢC CHUYỂN SANG CHỮ ĐỘNG =================
          isMobile
              ? Column(
            children: [
              StatsCard(
                title: text['total_points']!, value: '0',
                subtitle: text['points_subtitle']!,
                icon: Icons.eco_outlined, iconBgColor: const Color(0xfff0fdf4), iconColor: const Color(0xff10b981),
              ),
              const SizedBox(height: 12),
              StatsCard(
                title: text['reports_submitted']!, value: '0',
                subtitle: text['reports_subtitle']!,
                icon: Icons.assignment_outlined, iconBgColor: const Color(0xfffef3c7), iconColor: Colors.amber,
              ),
              const SizedBox(height: 12),
              StatsCard(
                title: text['reward_events']!, value: '0',
                subtitle: text['events_subtitle']!,
                icon: Icons.emoji_events_outlined, iconBgColor: const Color(0xfffee2e2), iconColor: Colors.redAccent,
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: text['total_points']!, value: '0',
                  subtitle: text['points_subtitle']!,
                  icon: Icons.eco_outlined, iconBgColor: const Color(0xfff0fdf4), iconColor: const Color(0xff10b981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: text['reports_submitted']!, value: '0',
                  subtitle: text['reports_subtitle']!,
                  icon: Icons.assignment_outlined, iconBgColor: const Color(0xfffef3c7), iconColor: Colors.amber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: text['reward_events']!, value: '0',
                  subtitle: text['events_subtitle']!,
                  icon: Icons.emoji_events_outlined, iconBgColor: const Color(0xfffee2e2), iconColor: Colors.redAccent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ================= KHỐI 2: KHỐI BẢO CÁO VÀ HOẠT ĐỘNG CHỮ ĐỘNG =================
          isMobile
              ? Column(
            children: [
              _buildActiveRequests(text['active_requests']!, text['no_active_reports']!),
              const SizedBox(height: 24),
              _buildRecentActivity(text['recent_activity']!, text['no_activity_yet']!),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cột trái chiếm 7 phần diện tích
              Expanded(flex: 7, child: _buildActiveRequests(text['active_requests']!, text['no_active_reports']!)),
              const SizedBox(width: 16),
              // Cột phải chiếm 3 phần diện tích
              Expanded(flex: 3, child: _buildRecentActivity(text['recent_activity']!, text['no_activity_yet']!)),
            ],
          ),
        ],
      ),
    );
  }

  // --- Widget con: Khối hiển thị Active Requests ---
  Widget _buildActiveRequests(String title, String content) {
    return _buildSectionBox(
      title: title,
      child: Container(
        height: 160,
        alignment: Alignment.topLeft, // Đẩy chữ lên góc trên bên trái giống hệt ảnh mẫu
        child: Text(
          content,
          style: const TextStyle(color: Color(0xff475569), fontSize: 15),
        ),
      ),
    );
  }

  // --- Widget con: Khối hiển thị Recent Reward Activity ---
  Widget _buildRecentActivity(String title, String content) {
    return _buildSectionBox(
      title: title,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xfff0fdf4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xffbbf7d0)),
        ),
        child: Center(
          child: Text(
            content,
            style: const TextStyle(color: Color(0xff10b981), fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  // --- Hàm hỗ trợ vẽ khung hộp màu trắng bo góc nâng cao độ tương phản ---
  Widget _buildSectionBox({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xffe2e8f0)), // Viền xám định hình hộp
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}