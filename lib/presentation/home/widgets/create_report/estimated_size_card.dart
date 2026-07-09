import 'package:flutter/material.dart';

class EstimatedSizeCard extends StatelessWidget {
  final bool isMobile;
  final String? selectedSize;
  final Function(String) onSizeSelected;

  const EstimatedSizeCard({
    super.key,
    required this.isMobile,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = [
      {'value': 'SMALL', 'label': 'Nhỏ', 'desc': 'Dưới 10kg (1-2 túi nhỏ)', 'icon': Icons.shopping_bag_outlined},
      {'value': 'MEDIUM', 'label': 'Vừa', 'desc': '10kg - 50kg (3-5 bao tải)', 'icon': Icons.inventory_2_outlined},
      {'value': 'LARGE', 'label': 'Lớn', 'desc': '50kg - 200kg (Ngập vỉa hè)', 'icon': Icons.local_shipping_outlined},
      {'value': 'HUGE', 'label': 'Rất lớn', 'desc': 'Trên 200kg (Bãi tự phát)', 'icon': Icons.warning_amber_rounded},
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.scale, color: Color(0xFF059669), size: 22),
          const SizedBox(width: 14),
          Text('Quy mô rác ước tính', 
            style: TextStyle(fontSize: isMobile ? 16 : 17, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
        ]),
        const SizedBox(height: 16),
        ...sizes.map((size) {
          final isSelected = selectedSize == size['value'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => onSizeSelected(size['value'] as String),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(children: [
                  Icon(size['icon'] as IconData, 
                    color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade600, size: 24),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(size['label'] as String, 
                        style: TextStyle(
                          fontWeight: FontWeight.w700, 
                          color: isSelected ? const Color(0xFF059669) : const Color(0xFF1E293B))),
                      Text(size['desc'] as String, 
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  )),
                  if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                ]),
              ),
            ),
          );
        }),
      ]),
    );
  }
}
