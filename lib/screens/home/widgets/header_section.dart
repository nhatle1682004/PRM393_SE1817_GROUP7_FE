import 'package:flutter/material.dart';
import '../../../services/storage_service.dart';
import '../../../config/languages.dart'; // Import từ điển

class HeaderSection extends StatefulWidget {
  final bool isVietnamese;
  final VoidCallback onLanguageChanged; // Hàm thông báo cho HomeScreen biết để dịch chữ
  final int currentTabIndex;            // Theo dõi tab nào đang active
  final ValueChanged<int> onTabChanged;

  const HeaderSection({
    super.key,
    required this.isVietnamese,
    required this.onLanguageChanged, // 🛠️ ĐÃ SỬA: Thêm dấu phẩy bị thiếu ở đây
    required this.currentTabIndex,
    required this.onTabChanged,
  });

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  final StorageService _storageService = StorageService();
  String _userName = "Loading...";
  String _avatarLetters = "--";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? savedName = await _storageService.getUsername();
    if (savedName != null && savedName.isNotEmpty) {
      setState(() {
        _userName = savedName;
        _avatarLetters = savedName.substring(0, savedName.length >= 2 ? 2 : 1).toUpperCase();
      });
    } else {
      setState(() {
        _userName = "Guest";
        _avatarLetters = "G";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    // Chọn bộ từ điển tương ứng dựa vào biến truyền vào
    var text = widget.isVietnamese ? Languages.vi : Languages.en;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: const Color(0xffe2e8f0), width: 1)),
        boxShadow: [BoxShadow(color: const Color(0xff0f172a).withOpacity(0.02), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // 1. LOGO
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xffdcfce7), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.eco, color: Color(0xff10b981), size: 24),
          ),
          const SizedBox(width: 10),
          const Text('EcoCollect', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xff0f172a), letterSpacing: -0.5)),
          const SizedBox(width: 32),

          // 2. NAV TABS
          if (!isMobile)
            Row(
              children: [
                // 🛠️ ĐÃ SỬA: Thay thế `isActive: true` bằng chỉ mục `index` chuẩn để chuyển tiếp trang động
                _navButton(text['home']!, index: 0),
                _navButton(text['create_report']!, index: 1),
                _navButton(text['rewards']!, index: 2),
                _navButton(text['history']!, index: 3),
              ],
            )
          else
            IconButton(icon: const Icon(Icons.menu, color: Color(0xff475569)), onPressed: () {}),

          const Spacer(),

          // 🌐 3. NÚT CHUYỂN ĐỔI NGÔN NGỮ (VI / EN)
          TextButton(
            onPressed: widget.onLanguageChanged,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xfff1f5f9),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(
              widget.isVietnamese ? "🇻🇳 Tiếng Việt" : "🇬🇧 English",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff334155)),
            ),
          ),
          const SizedBox(width: 12),

          // 4. ICON CHUÔNG
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Color(0xff64748b), size: 24), onPressed: () {}),
          const SizedBox(width: 16),

          // 5. Ô ĐIỂM
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xfff0fdf4), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xffbbf7d0))),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Color(0xff10b981), size: 16),
                const SizedBox(width: 4),
                Text('0 ${widget.isVietnamese ? "điểm" : "pts"}', style: const TextStyle(color: Color(0xff10b981), fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // 6. AVATAR ACCOUNT
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(color: const Color(0xfff8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xffe2e8f0))),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xff10b981),
                  child: Text(_avatarLetters, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 8),
                  Text(_userName, style: const TextStyle(color: Color(0xff334155), fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, color: Color(0xff64748b), size: 18),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navButton(String text, {required int index}) {
    // So sánh xem tab này có phải tab đang chọn hay không
    bool isActive = widget.currentTabIndex == index;

    return InkWell(
      onTap: () {
        widget.onTabChanged(index); // Đẩy số hiệu tab lên HomeScreen để đổi trang
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xfff0fdf4) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? const Color(0xff10b981) : const Color(0xff64748b),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}