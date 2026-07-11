import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
  });

  int get totalPages => totalItems == 0 ? 1 : ((totalItems - 1) ~/ pageSize) + 1;

  @override
  Widget build(BuildContext context) {
    final start = totalItems == 0 ? 0 : currentPage * pageSize + 1;
    final end = (currentPage + 1) * pageSize > totalItems ? totalItems : (currentPage + 1) * pageSize;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Text(
            'Hiển thị $start-$end / $totalItems',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Trang trước',
            onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '${currentPage + 1} / $totalPages',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          IconButton(
            tooltip: 'Trang sau',
            onPressed: currentPage < totalPages - 1 ? () => onPageChanged(currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
