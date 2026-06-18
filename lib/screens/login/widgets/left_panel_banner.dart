import 'package:flutter/material.dart';

class LeftPanelBanner extends StatelessWidget {
  const LeftPanelBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 550),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min, // thu gọn chiều dọc vừa đủ nội dung
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconBox(Icons.eco_outlined, const Color(0xff22c55e)),
                  const SizedBox(width: 16),
                  _buildIconBox(Icons.published_with_changes, const Color(0xff14b8a6)),
                  const SizedBox(width: 16),
                  _buildIconBox(Icons.forest_outlined, const Color(0xff15803d)),
                ],
              ),
              const SizedBox(height: 32),
              // tieu de lon in dam
              const Text(
                'Together for a Greener Future',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Join us in making a difference. Report waste, track collection, and help create a cleaner environment for everyone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.6, // tăng khoảng cách dòng để dễ đọc hơn
                ),
              ),
              const SizedBox(height: 48),
              // Tạo 3 cột dữ liệu thống kê màu xanh
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('50K+', 'Active Users'),
                  _buildStatItem('120T', 'Waste Recycled'),
                  _buildStatItem('98%', 'Satisfaction'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
  // hàm tạo ô vuông chứa các icon nhỏ phía trên
  Widget _buildIconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }

  // hàm tạo chữ số thống kê
  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xff10b981),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black45, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}