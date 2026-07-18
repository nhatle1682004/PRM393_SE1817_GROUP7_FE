import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/config/api_config.dart';

class TaskCard extends StatelessWidget {
  final EnterpriseAssignment assignment;
  final Widget actions;
  const TaskCard({super.key, required this.assignment, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('#${assignment.assignmentId}', style: const TextStyle(fontWeight: FontWeight.bold)), _StatusBadge(status: assignment.status ?? '')]),
      const SizedBox(height: 16),
      Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(ApiConfig.getFullImageUrl(assignment.reportImageUrl), width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(assignment.wasteTypeName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)), Text(assignment.location, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
      ]),
      const Divider(height: 32),
      actions,
    ])));
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final color = s == 'completed' ? Colors.green : (s == 'ontheway' ? Colors.blue : Colors.orange);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)));
  }
}
