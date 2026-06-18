import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/locale_scope.dart';

class CreateReportScreen extends StatelessWidget {
  const CreateReportScreen({super.key});

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
              Text(
                text['upload_photo'] ?? 'Upload Waste Photo',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1e293b)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xfff8fafc),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffcbd5e1), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_library, color: Colors.orangeAccent, size: 32),
                const SizedBox(height: 8),
                Text(
                  text['drag_drop_hint'] ?? 'Drag & drop an image here or click to select',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff475569)),
                ),
                Text(
                  text['supported_formats'] ?? 'Supported: PNG, JPG, JPEG (Max 10MB)',
                  style: const TextStyle(fontSize: 12, color: Color(0xff94a3b8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            text['waste_types_label'] ?? 'Waste Types * (You can select multiple)',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildTypeChip(text['waste_plastic'] ?? 'Plastic'),
              _buildTypeChip(text['waste_paper'] ?? 'Paper'),
              _buildTypeChip(text['waste_metal'] ?? 'Metal'),
              _buildTypeChip(text['waste_glass'] ?? 'Glass'),
              _buildTypeChip(text['waste_ewaste'] ?? 'E-Waste'),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            text['detailed_description'] ?? 'Detailed Description',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1e293b)),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: text['description_hint'] ?? 'Add detailed information about the waste (optional)...',
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

  Widget _buildRightColumn(Map<String, String> text) {
    return _buildContainerBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.pinkAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                text['collection_location'] ?? 'Collection Location',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xff1e293b)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: text['address_hint'] ?? 'E.g.: 123 Main St, Ho Chi Minh City...',
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
                  label: Text(text['search'] ?? 'Search', style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff2563eb), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xffe2e8f0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Icon(Icons.map, color: Colors.grey, size: 40)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.gps_fixed, size: 16, color: Colors.white),
              label: Text(text['use_current_location'] ?? 'Use Current Location', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff10b981), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
            ),
          ),
          const SizedBox(height: 16),
          _buildCoordinateRow(text['latitude_label'] ?? 'Latitude (Lat):', text['not_selected'] ?? 'Not selected'),
          const SizedBox(height: 12),
          _buildCoordinateRow(text['longitude_label'] ?? 'Longitude (Lng):', text['not_selected'] ?? 'Not selected'),
        ],
      ),
    );
  }

  Widget _buildCoordinateRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.public, color: Color(0xff2563eb), size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff1e293b), fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Color(0xff64748b), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffcbd5e1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff94a3b8)),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xff1e293b))),
        ],
      ),
    );
  }

  Widget _buildContainerBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}