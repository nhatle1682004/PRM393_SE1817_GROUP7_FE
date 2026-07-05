import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final bool isMobile;
  final double? lat;
  final double? lng;
  final VoidCallback onGetLocation;

  const LocationCard({
    super.key,
    required this.isMobile,
    this.lat,
    this.lng,
    required this.onGetLocation,
  });

  @override
  Widget build(BuildContext context) {
    final mapHeight = isMobile ? 140.0 : 160.0;
    final buttonHeight = isMobile ? 48.0 : 50.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildSectionTitle(),
        SizedBox(height: isMobile ? 14 : 20),
        _buildSearchField(),
        SizedBox(height: isMobile ? 12 : 16),
        _buildMapPreview(mapHeight),
        SizedBox(height: isMobile ? 12 : 16),
        _buildLocationButton(buttonHeight),
        SizedBox(height: isMobile ? 12 : 16),
        _buildCoordinates(),
      ]),
    );
  }

  Widget _buildSectionTitle() => Row(children: [
    Icon(Icons.location_on, color: const Color(0xFF059669), size: isMobile ? 20 : 22),
    SizedBox(width: isMobile ? 10 : 14),
    Text('Vị trí thu gom', style: TextStyle(fontSize: isMobile ? 16 : 17, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
  ]);

  Widget _buildSearchField() => TextField(
    decoration: InputDecoration(
      hintText: 'Tìm kiếm địa chỉ...',
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 12 : 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF059669), width: 2)),
    ),
  );

  Widget _buildMapPreview(double mapHeight) => Container(
    height: mapHeight,
    width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Stack(children: [
      CustomPaint(size: Size(double.infinity, mapHeight), painter: _MapGridPainter()),
      Center(child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: const Icon(Icons.location_on, color: Colors.white, size: 28),
      )),
    ]),
  );

  Widget _buildLocationButton(double buttonHeight) => SizedBox(
    width: double.infinity,
    height: buttonHeight,
    child: ElevatedButton.icon(
      onPressed: onGetLocation,
      icon: const Icon(Icons.my_location, size: 20),
      label: Text('Vị trí hiện tại', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isMobile ? 14 : 15)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  Widget _buildCoordinates() => Container(
    padding: EdgeInsets.all(isMobile ? 12 : 16),
    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Vĩ độ', style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(lat?.toStringAsFixed(6) ?? "—", style: TextStyle(fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
      ])),
      Container(width: 1, height: isMobile ? 30 : 36, color: const Color(0xFFE2E8F0)),
      Expanded(child: Padding(padding: const EdgeInsets.only(left: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Kinh độ', style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(lng?.toStringAsFixed(6) ?? "—", style: TextStyle(fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
      ]))),
    ]),
  );
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += 30) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
