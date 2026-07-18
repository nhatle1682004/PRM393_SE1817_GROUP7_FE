import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/admin_waste_report.dart';

class ReportAdminCard extends StatelessWidget {
  final AdminWasteReport report;
  final VoidCallback onDetail;
  const ReportAdminCard({super.key, required this.report, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('#${report.reportId}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        _StatusBadge(status: report.status),
      ]),
      const SizedBox(height: 12),
      Text(report.submittedByName, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(report.wasteTypeNames.join(', '), style: const TextStyle(fontSize: 12, color: Colors.green)),
      const SizedBox(height: 12),
      Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: onDetail, child: const Text('Chi tiết'))),
    ])));
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = status.toLowerCase() == 'completed' ? Colors.green : (status.toLowerCase() == 'pending' ? Colors.orange : Colors.blue);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)));
  }
}
