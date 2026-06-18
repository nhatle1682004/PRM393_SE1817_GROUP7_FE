import 'package:flutter/material.dart';

class CreateReportScreen extends StatelessWidget {
  final Map<String, String> text; // Nhận bộ từ điển ngôn ngữ từ trang chủ truyền sang
  const CreateReportScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100), // Khống chế chiều rộng tối đa giống giao diện web mẫu
          child: Column(
            children: [
              // 📝 TIÊU ĐỀ CHÍNH
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined, color: Color(0xff1e293b), size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Create Waste Report',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Take a photo & select a location on the map',
                style: TextStyle(color: Color(0xff64748b), fontSize: 14),
              ),
              const SizedBox(height: 28),

              // CHIA 2 CỘT (WEB) HOẶC 1 CỘT (MOBILE)
              isMobile
                  ? Column(
                children: [
                  _buildLeftColumn(),
                  const SizedBox(height: 24),
                  _buildRightColumn(),
                ],
              )
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cột trái: Upload ảnh & thông tin loại rác
                  Expanded(flex: 5, child: _buildLeftColumn()),
                  const SizedBox(width: 24),
                  // Cột phải: Bản đồ & Vị trí địa lý
                  Expanded(flex: 5, child: _buildRightColumn()),
                ],
              ),

              const SizedBox(height: 24),
              // NÚT SUBMIT DƯỚI CÙNG
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff10b981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Submit Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====== 📸 CỘT TRÁI: UPLOAD & CHOOSE TYPES ======
  Widget _buildLeftColumn() {
    return _buildContainerBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.image_outlined, color: Color(0xff64748b), size: 20),
              SizedBox(width: 8),
              Text('Upload Waste Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1e293b))),
            ],
          ),
          const SizedBox(height: 12),
          // Khung Drag & Drop ảnh nét đứt
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xfff8fafc),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffcbd5e1), width: 1, style: BorderStyle.solid), // Để làm nét đứt chuẩn bạn cần gói bài toán nâng cao, tạm thời làm viền xám mịn rất đẹp
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, color: Colors.orangeAccent, size: 32),
                SizedBox(height: 8),
                Text('Drag & drop an image here or click to select', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xff475569))),
                SizedBox(height: 4),
                Text('Supported: PNG, JPG, JPEG (Max 10MB)', style: TextStyle(fontSize: 12, color: Color(0xff94a3b8))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Waste Types * (You can select multiple)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1e293b))),
          const SizedBox(height: 10),
          // Danh sách checkbox loại rác
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildTypeChip('Plastic'),
              _buildTypeChip('Paper'),
              _buildTypeChip('Metal'),
              _buildTypeChip('Glass'),
              _buildTypeChip('E-Waste'),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Detailed Description', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1e293b))),
          const SizedBox(height: 8),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add detailed information about the waste (optional)...',
              hintStyle: const TextStyle(color: Color(0xff94a3b8), fontSize: 14),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xffcbd5e1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xffcbd5e1))),
            ),
          ),
        ],
      ),
    );
  }

  // ====== 📍 CỘT PHẢI: LOCATION & MAP ======
  Widget _buildRightColumn() {
    return _buildContainerBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.pinkAccent, size: 20),
              SizedBox(width: 8),
              Text('Collection Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1e293b))),
            ],
          ),
          const SizedBox(height: 12),
          // Ô tìm kiếm địa chỉ
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Eg: 123 Main St, Ho Chi Minh City...',
                      hintStyle: const TextStyle(color: Color(0xff94a3b8), fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xffcbd5e1))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xffcbd5e1))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search, size: 16, color: Colors.white),
                  label: const Text('Search', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff2563eb), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Khung chứa bản đồ giả lập (Trong ảnh mẫu của bạn)
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xffe2e8f0),
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: NetworkImage('https://user-images.githubusercontent.com/14053915/121873138-024f2b00-cd22-11eb-8984-dfbf755b6c86.png'), // Ảnh map demo
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Nút Use Current Location
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.my_location, size: 16, color: Colors.white),
              label: const Text('Use Current Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff10b981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCoordinate('Latitude (Lat):', 'Not selected'),
          const SizedBox(height: 12),
          _buildInfoCoordinate('Longitude (Lng):', 'Not selected'),
        ],
      ),
    );
  }

  // Hàm tạo nhanh ô chọn loại rác giống hệt ảnh mẫu
  Widget _buildTypeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), // Bo tròn góc mạnh hơn
        border: Border.all(color: const Color(0xffcbd5e1)), // Viền xám mảnh
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Checkbox tùy chỉnh kích thước nhỏ hơn để nhìn tinh tế
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: false, 
              onChanged: (v) {}, 
              activeColor: const Color(0xff10b981),
              side: const BorderSide(color: Color(0xff94a3b8)), // Màu viền checkbox
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label, 
            style: const TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w500, 
              color: Color(0xff1e293b),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm hiển thị ô tọa độ Lat/Lng
  Widget _buildInfoCoordinate(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xfff1f5f9), borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff475569))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, color: Color(0xff94a3b8))),
        ],
      ),
    );
  }

  Widget _buildContainerBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: child,
    );
  }
}