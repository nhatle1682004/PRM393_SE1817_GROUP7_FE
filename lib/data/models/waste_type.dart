import 'package:flutter/material.dart';

class WasteType {
  final int id;
  final String name;
  final String nameVi;
  final IconData? icon;
  final Color? color;

  const WasteType({
    required this.id,
    required this.name,
    required this.nameVi,
    this.icon,
    this.color,
  });

  factory WasteType.fromJson(Map<String, dynamic> json) {
    // Backend trả về "wasteTypeId", frontend đọc đúng field
    final id = json['wasteTypeId'] is int ? json['wasteTypeId'] as int : int.tryParse(json['wasteTypeId']?.toString() ?? '') ?? 0;
    final name = json['name']?.toString() ?? '';
    
    // Map icon và color từ name
    final iconData = _getIcon(name);
    final colorData = _getColor(name);
    // Suy ra nameVi từ name tiếng Anh
    final nameVi = _getNameVi(name);

    return WasteType(
      id: id,
      name: name,
      nameVi: nameVi,
      icon: iconData,
      color: colorData,
    );
  }

  static IconData _getIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('organic') || lowerName.contains('hữu cơ')) return Icons.eco;
    if (lowerName.contains('plastic') || lowerName.contains('nhựа')) return Icons.local_drink;
    if (lowerName.contains('paper') || lowerName.contains('giấy')) return Icons.description;
    if (lowerName.contains('metal') || lowerName.contains('kim loại')) return Icons.hardware;
    if (lowerName.contains('glass') || lowerName.contains('thủy tinh')) return Icons.wine_bar;
    if (lowerName.contains('e-waste') || lowerName.contains('electronic') || lowerName.contains('điện tử')) return Icons.memory;
    if (lowerName.contains('hazardous') || lowerName.contains('nguy hại')) return Icons.warning;
    if (lowerName.contains('other') || lowerName.contains('khác')) return Icons.more_horiz;
    return Icons.delete_outline;
  }

  static Color _getColor(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('organic') || lowerName.contains('hữu cơ')) return const Color(0xFFEF4444);
    if (lowerName.contains('plastic') || lowerName.contains('nhựа')) return const Color(0xFF3B82F6);
    if (lowerName.contains('paper') || lowerName.contains('giấy')) return const Color(0xFFF59E0B);
    if (lowerName.contains('metal') || lowerName.contains('kim loại')) return const Color(0xFF8B5CF6);
    if (lowerName.contains('glass') || lowerName.contains('thủy tinh')) return const Color(0xFF10B981);
    if (lowerName.contains('e-waste') || lowerName.contains('electronic') || lowerName.contains('điện tử')) return const Color(0xFF6366F1);
    if (lowerName.contains('hazardous') || lowerName.contains('nguy hại')) return const Color(0xFFDC2626);
    if (lowerName.contains('other') || lowerName.contains('khác')) return const Color(0xFF6B7280);
    return const Color(0xFF6B7280);
  }

  static String _getNameVi(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('organic')) return 'Hữu cơ';
    if (lowerName.contains('plastic')) return 'Nhựa';
    if (lowerName.contains('paper')) return 'Giấy';
    if (lowerName.contains('metal')) return 'Kim loại';
    if (lowerName.contains('glass')) return 'Thủy tinh';
    if (lowerName.contains('e-waste') || lowerName.contains('electronic')) return 'Điện tử';
    if (lowerName.contains('hazardous')) return 'Nguy hại';
    if (lowerName.contains('other')) return 'Khác';
    return name;
  }
}
