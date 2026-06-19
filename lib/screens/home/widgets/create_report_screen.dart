import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // [SỬA 1] Import Google Maps
import 'package:waste_collection_management_system/config/locale_scope.dart';
import 'package:waste_collection_management_system/screens/home/widgets/map_view_widget.dart'; // [SỬA 2] Import Widget bản đồ

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  LatLng? _selectedLocation; // Biến lưu vị trí tọa độ khi chọn trên bản đồ

  @override
  Widget build(BuildContext context) {
    final text = LocaleScope.of(context).text;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 850;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment, color: Color(0xff1e293b), size: 28),
                  const SizedBox(width: 8),
                  Text(
                    text['report_title'] ?? 'Create Waste Report',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                text['report_subtitle'] ?? 'Take a photo & select a location on the map',
                style: const TextStyle(color: Color(0xff64748b), fontSize: 14),
              ),
              const SizedBox(height: 28),
              isMobile
                  ? Column(
                children: [
                  _buildLeftColumn(text),
                  const SizedBox(height: 24),
                  _buildRightColumn(text),
                ],
              )
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _buildLeftColumn(text)),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: _buildRightColumn(text)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check, color: Colors.white, size: 20),
                  label: Text(
                    text['submit_report'] ?? 'Submit Report',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff10b981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn(Map<String, String> text) {
    return _buildContainerBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library, color: Color(0xff64748b), size: 20),
              const SizedBox(width: 8),
              Text(text['upload_photo'] ?? 'Upload Waste Photo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1e293b))),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity, height: 160,
            decoration: BoxDecoration(color: const Color(0xfff8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xffcbd5e1), width: 1)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_library, color: Colors.orangeAccent, size: 32),
                const SizedBox(height: 8),
                Text(text['drag_drop_hint'] ?? 'Drag & drop...', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff475569))),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(text['waste_types_label'] ?? 'Waste Types *', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1e293b))),
          const SizedBox(height: 10),
          Wrap(spacing: 12, runSpacing: 10, children: [_buildTypeChip('Plastic'), _buildTypeChip('Paper'), _buildTypeChip('Metal')]),
        ],
      ),
    );
  }

  Widget _buildRightColumn(Map<String, String> text) {
    return _buildContainerBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.pinkAccent, size: 20),
              const SizedBox(width: 8),
              Text(text['collection_location'] ?? 'Collection Location', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1e293b))),
            ],
          ),
          const SizedBox(height: 12),
          // [SỬA 5] Thay thế Container trống bằng MapViewWidget
          SizedBox(
            width: double.infinity,
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: MapViewWidget(
                onLocationSelected: (location) {
                  setState(() {
                    _selectedLocation = location; // Cập nhật tọa độ khi chọn trên bản đồ
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // [SỬA 6] Hiển thị tọa độ thực tế từ biến _selectedLocation
          _buildCoordinateRow(text['latitude_label'] ?? 'Latitude (Lat):',
              _selectedLocation?.latitude.toString() ?? text['not_selected'] ?? 'Not selected'),
          const SizedBox(height: 12),
          _buildCoordinateRow(text['longitude_label'] ?? 'Longitude (Lng):',
              _selectedLocation?.longitude.toString() ?? text['not_selected'] ?? 'Not selected'),
        ],
      ),
    );
  }

  Widget _buildCoordinateRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xfff8fafc), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xffe2e8f0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.public, color: Color(0xff2563eb), size: 18), const SizedBox(width: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1e293b), fontSize: 13))]),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Color(0xff64748b), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xffcbd5e1))), child: Text(label));
  }

  Widget _buildContainerBox({required Widget child}) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]), child: child);
  }
}