import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/config/api_config.dart';

class ReportDetailDialog extends StatelessWidget {
  final EnterpriseReport report;
  const ReportDetailDialog({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Chi tiết báo cáo #${report.reportId}'),
      content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        if (report.imageUrl != null) Image.network(ApiConfig.getFullImageUrl(report.imageUrl), height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported)),
        const SizedBox(height: 16),
        _row('Loại rác', report.wasteTypeNames.join(', ')),
        _row('Người gửi', report.submittedByName),
        _row('Mức độ', report.estimatedSize ?? 'N/A'),
        _row('Mô tả', report.description ?? 'Không có'),
        _row('Vị trí', '${report.latitude}, ${report.longitude}'),
      ])),
      actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
    );
  }

  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 80, child: Text(l, style: const TextStyle(fontWeight: FontWeight.bold))), Expanded(child: Text(v))]));
}

class ReportAssignmentDialog extends StatefulWidget {
  final EnterpriseReport report;
  final List<EnterpriseCollector> collectors;
  final Function(int? id) onAssign;
  const ReportAssignmentDialog({super.key, required this.report, required this.collectors, required this.onAssign});

  @override
  State<ReportAssignmentDialog> createState() => _ReportAssignmentDialogState();
}

class _ReportAssignmentDialogState extends State<ReportAssignmentDialog> {
  int? _id;
  @override
  Widget build(BuildContext context) {
    final list = widget.collectors.where((c) => c.collectorId != widget.report.assignedCollectorId).toList();
    return AlertDialog(
      title: const Text('Phân công thu gom'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        if (widget.report.assignedCollectorName != null) Text('Hiện tại: ${widget.report.assignedCollectorName}', style: const TextStyle(color: Colors.orange)),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(decoration: const InputDecoration(labelText: 'Chọn nhân viên'), items: list.map((c) => DropdownMenuItem(value: c.collectorId, child: Text(c.fullName ?? 'N/A'))).toList(), onChanged: (v) => _id = v),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(onPressed: () => widget.onAssign(_id), child: const Text('Xác nhận')),
      ],
    );
  }
}
