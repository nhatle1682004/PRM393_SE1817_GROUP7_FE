import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';

class FeedbackCard extends StatelessWidget {
  final EnterpriseFeedback feedback;
  final VoidCallback onResolve, onReject;

  const FeedbackCard({super.key, required this.feedback, required this.onResolve, required this.onReject});

  @override
  Widget build(BuildContext context) {
    final isPending = feedback.status == 'Pending';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.feedback, color: _getColor(feedback.status), size: 20),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Phản hồi #${feedback.feedbackId}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(feedback.userName ?? 'N/A', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ])),
            _StatusBadge(status: feedback.status),
          ]),
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)), child: Text(feedback.content, style: const TextStyle(fontSize: 14))),
          if (feedback.resolution != null) ...[
            const SizedBox(height: 12),
            Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text('Xử lý: ${feedback.resolution}', style: const TextStyle(fontSize: 13, color: Colors.green))),
          ],
          if (feedback.createdAt != null) ...[
            const SizedBox(height: 12),
            Text('${feedback.createdAt!.day}/${feedback.createdAt!.month} ${feedback.createdAt!.hour}:${feedback.createdAt!.minute}', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          ],
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: onReject, style: OutlinedButton.styleFrom(foregroundColor: Colors.red), child: const Text('Từ chối'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: onResolve, child: const Text('Xử lý'))),
            ]),
          ],
        ]),
      ),
    );
  }

  Color _getColor(String s) {
    switch (s.toLowerCase()) {
      case 'resolved': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = status == 'Resolved' ? Colors.green : (status == 'Pending' ? Colors.orange : Colors.red);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)));
  }
}

class ResolveFeedbackDialog extends StatefulWidget {
  final Function(String action, String note) onResolve;
  const ResolveFeedbackDialog({super.key, required this.onResolve});
  @override
  State<ResolveFeedbackDialog> createState() => _ResolveFeedbackDialogState();
}

class _ResolveFeedbackDialogState extends State<ResolveFeedbackDialog> {
  String? _action;
  final _note = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xử lý phản hồi'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          _act('warn', 'Cảnh cáo', Icons.warning),
          const SizedBox(width: 8),
          _act('reassign', 'Gán lại', Icons.replay),
        ]),
        const SizedBox(height: 16),
        TextField(controller: _note, decoration: const InputDecoration(labelText: 'Ghi chú', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(onPressed: _action == null ? null : () { Navigator.pop(context); widget.onResolve(_action!, _note.text); }, child: const Text('Xác nhận')),
      ],
    );
  }
  Widget _act(String v, String l, IconData i) => Expanded(child: InkWell(onTap: () => setState(() => _action = v), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _action == v ? Colors.green.withValues(alpha: 0.1) : Colors.grey.shade100, border: Border.all(color: _action == v ? Colors.green : Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Column(children: [Icon(i, color: _action == v ? Colors.green : Colors.grey), Text(l, style: TextStyle(fontSize: 12, color: _action == v ? Colors.green : Colors.grey))]))));
}
