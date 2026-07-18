import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';

class AssignmentCard extends StatelessWidget {
  final EnterpriseAssignment assignment;
  final VoidCallback onCancel, onReassign;

  const AssignmentCard({super.key, required this.assignment, required this.onCancel, required this.onReassign});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 400;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeader(isMobile),
          const Divider(height: 32),
          _buildInfoGrid(isMobile),
          if (assignment.assignedAt != null) ...[
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text('Gán lúc: ${_formatDate(assignment.assignedAt!)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ]),
          ],
          if (assignment.status?.toLowerCase() == 'pending') ...[
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: onReassign, style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF10B981)), child: const Text('Gán lại'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: onCancel, style: OutlinedButton.styleFrom(foregroundColor: Colors.red), child: const Text('Hủy'))),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    final color = _getStatusColor(assignment.status);
    return Row(children: [
      Icon(Icons.assignment, color: color, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Phân công #${assignment.assignmentId}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('Yêu cầu #${assignment.requestId}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(_getStatusLabel(assignment.status ?? ''), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
    ]);
  }

  Widget _buildInfoGrid(bool isMobile) {
    if (isMobile) {
      return Column(children: [
        _infoRow(Icons.person, 'Nhân viên', assignment.collectorName ?? 'N/A'),
        _infoRow(Icons.badge, 'Công dân', assignment.citizenName ?? 'N/A'),
        _infoRow(Icons.delete, 'Loại rác', assignment.wasteTypeName ?? 'N/A'),
        _infoRow(Icons.location_on, 'Vị trí', assignment.location),
      ]);
    }
    return Column(children: [
      Row(children: [
        Expanded(child: _infoRow(Icons.person, 'Nhân viên', assignment.collectorName ?? 'N/A')),
        Expanded(child: _infoRow(Icons.badge, 'Công dân', assignment.citizenName ?? 'N/A')),
      ]),
      Row(children: [
        Expanded(child: _infoRow(Icons.delete, 'Loại rác', assignment.wasteTypeName ?? 'N/A')),
        Expanded(child: _infoRow(Icons.location_on, 'Vị trí', assignment.location)),
      ]),
    ]);
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Icon(icon, size: 14, color: Colors.grey),
      const SizedBox(width: 6),
      Text('$label: ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
    ]),
  );

  Color _getStatusColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'inprogress': case 'in_progress': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'completed': return 'Hoàn thành';
      case 'pending': return 'Chờ xử lý';
      case 'inprogress': case 'in_progress': return 'Đang thu gom';
      case 'cancelled': return 'Đã hủy';
      default: return s;
    }
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

class AssignCollectorDialog extends StatelessWidget {
  final int requestId;
  final List<EnterpriseCollector> collectors;
  final bool isLoading;
  final int? selectedId;
  final Function(int) onSelect, onAssign;

  const AssignCollectorDialog({super.key, required this.requestId, required this.collectors, required this.isLoading, this.selectedId, required this.onSelect, required this.onAssign});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Phân công yêu cầu #$requestId'),
      content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (isLoading) const CircularProgressIndicator()
        else if (collectors.isEmpty) const Text('Không có nhân viên sẵn sàng')
        else ConstrainedBox(constraints: const BoxConstraints(maxHeight: 300), child: ListView(children: collectors.map((c) => ListTile(
          leading: CircleAvatar(child: Text(c.fullName?[0] ?? 'C')),
          title: Text(c.fullName ?? 'N/A'),
          subtitle: Text('${c.completedCount} đã hoàn thành'),
          selected: selectedId == c.collectorId,
          onTap: () => onSelect(c.collectorId),
          trailing: selectedId == c.collectorId ? const Icon(Icons.check_circle, color: Colors.green) : null,
        )).toList())),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(onPressed: selectedId == null ? null : () { Navigator.pop(context); onAssign(selectedId!); }, child: const Text('Xác nhận')),
      ],
    );
  }
}
