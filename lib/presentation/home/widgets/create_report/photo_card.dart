import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/waste_type.dart';

class PhotoCard extends StatelessWidget {
  final bool isMobile;
  final dynamic imageFile;
  final dynamic webPickedFile;
  final Set<String> selectedTypes;
  final VoidCallback onPickImage;
  final void Function(String) onToggleWasteType;
  final List<WasteType> wasteTypes;

  const PhotoCard({
    super.key,
    required this.isMobile,
    this.imageFile,
    this.webPickedFile,
    required this.selectedTypes,
    required this.onPickImage,
    required this.onToggleWasteType,
    this.wasteTypes = const [],
  });

  @override
  Widget build(BuildContext context) {
    final imageHeight = isMobile ? 180.0 : 200.0;
    final iconSize = isMobile ? 36.0 : 40.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.camera_alt, 'Tải ảnh rác thải'),
          SizedBox(height: isMobile ? 14 : 20),
          _buildImageUploadArea(imageHeight, iconSize),
          SizedBox(height: isMobile ? 16 : 24),
          _buildSectionTitle(Icons.category, 'Loại rác thải'),
          SizedBox(height: isMobile ? 12 : 16),
          WasteTypeChips(selectedTypes: selectedTypes, onToggle: onToggleWasteType, wasteTypes: wasteTypes),
          const SizedBox(height: 6),
          Text('Chọn loại rác thải có trong hình ảnh', style: TextStyle(color: Colors.grey.shade500, fontSize: isMobile ? 11 : 12, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) => Row(children: [
    Icon(icon, color: const Color(0xFF059669), size: isMobile ? 20 : 22),
    SizedBox(width: isMobile ? 10 : 14),
    Text(title, style: TextStyle(fontSize: isMobile ? 16 : 17, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
  ]);

  Widget _buildImageUploadArea(double imageHeight, double iconSize) {
    final hasImage = imageFile != null || webPickedFile != null;
    return InkWell(
      onTap: onPickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: imageHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3), width: 2, strokeAlign: BorderSide.strokeAlignInside),
        ),
        child: hasImage ? _buildImagePreview() : _buildUploadPlaceholder(iconSize),
      ),
    );
  }

  Widget _buildImagePreview() => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: Stack(fit: StackFit.expand, children: [
      kIsWeb ? Image.network(webPickedFile!.path, fit: BoxFit.cover) : Image.file(imageFile!, fit: BoxFit.cover),
      Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 16))),
    ]),
  );

  Widget _buildUploadPlaceholder(double iconSize) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(padding: EdgeInsets.all(isMobile ? 14 : 16), decoration: BoxDecoration(color: const Color(0xFF059669).withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.cloud_upload_outlined, color: const Color(0xFF059669).withValues(alpha: 0.7), size: iconSize)),
    const SizedBox(height: 14),
    Text('Nhấn để tải lên hình ảnh', style: TextStyle(color: Colors.grey.shade500, fontSize: isMobile ? 14 : 15, fontWeight: FontWeight.w500)),
    const SizedBox(height: 6),
    Text('Hỗ trợ: JPG, PNG, WEBP', style: TextStyle(color: Colors.grey.shade400, fontSize: isMobile ? 11 : 12)),
  ]);
}

class WasteTypeChips extends StatelessWidget {
  final Set<String> selectedTypes;
  final void Function(String) onToggle;
  final List<WasteType> wasteTypes;

  const WasteTypeChips({
    super.key,
    required this.selectedTypes,
    required this.onToggle,
    this.wasteTypes = const [],
  });

  @override
  Widget build(BuildContext context) {
    // Nếu chưa load xong hoặc list rỗng, hiển thị placeholder
    if (wasteTypes.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Đang tải loại rác...',
          style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
        ),
      );
    }
    
    // Dùng data từ API
    return Wrap(spacing: 10, runSpacing: 10, children: wasteTypes.map((type) {
      final isSelected = selectedTypes.contains(type.nameVi);
      return _buildChip(type.nameVi, type.icon ?? Icons.delete_outline, type.color ?? const Color(0xFF6B7280), isSelected);
    }).toList());
  }

  Widget _buildChip(String label, IconData icon, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () => onToggle(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: isSelected ? color : Colors.grey.shade500, size: 18),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: isSelected ? color : Colors.grey.shade600, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, fontSize: 14)),
        ]),
      ),
    );
  }
}
