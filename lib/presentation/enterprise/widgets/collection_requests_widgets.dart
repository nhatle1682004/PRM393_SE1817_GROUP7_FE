import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';

class RequestCard extends StatelessWidget {
  final EnterpriseCollectionRequest request;
  final VoidCallback onTap, onAssign;

  const RequestCard({super.key, required this.request, required this.onTap, required this.onAssign});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)), child: Text('#${request.reportId}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF475569)))),
              const SizedBox(width: 10),
              Expanded(child: Text(request.wasteTypeName ?? 'N/A', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
              _StatusBadge(status: request.status ?? 'Pending'),
            ]),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildImage(request.reportImageUrl),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _infoRow(Icons.location_on, request.location, Colors.redAccent),
                const SizedBox(height: 8),
                _collectorBox(context),
                const SizedBox(height: 12),
                Row(children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(request.createdAt != null ? _formatDate(request.createdAt!) : 'N/A', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ]),
              ])),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildImage(String? url) => Container(
    width: 80, height: 80,
    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
    child: ClipRRect(borderRadius: BorderRadius.circular(11), child: (url != null && url.isNotEmpty) ? Image.network(ApiConfig.getFullImageUrl(url), fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey)) : const Icon(Icons.image, color: Colors.grey)),
  );

  Widget _collectorBox(BuildContext context) {
    final has = request.assignedCollectorName != null;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: has ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10), border: Border.all(color: has ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA))),
      child: Row(children: [
        Icon(has ? Icons.person : Icons.person_off, size: 16, color: has ? Colors.green : Colors.red),
        const SizedBox(width: 8),
        Expanded(child: Text(has ? 'NV: ${request.assignedCollectorName}' : 'Chưa phân công', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: has ? Colors.green : Colors.red), overflow: TextOverflow.ellipsis)),
        if (!has) InkWell(onTap: onAssign, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)), child: const Text('Gán NV', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) => Row(children: [
    Icon(icon, size: 16, color: color),
    const SizedBox(width: 8),
    Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis)),
  ]);

  String _formatDate(DateTime d) => '${d.day}/${d.month} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

class AssignCollectorDialog extends StatefulWidget {
  final EnterpriseCollectionRequest request;
  final List<EnterpriseCollector> collectors;
  final VoidCallback onAssigned;
  const AssignCollectorDialog({super.key, required this.request, required this.collectors, required this.onAssigned});
  @override
  State<AssignCollectorDialog> createState() => _AssignCollectorDialogState();
}

class _AssignCollectorDialogState extends State<AssignCollectorDialog> {
  int? _selectedId;
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Gán nhân viên cho #${widget.request.reportId}'),
      content: SizedBox(width: double.maxFinite, child: widget.collectors.isEmpty ? const Text('Không có nhân viên sẵn sàng') : ListView.builder(shrinkWrap: true, itemCount: widget.collectors.length, itemBuilder: (c, i) => RadioListTile<int>(title: Text(widget.collectors[i].fullName ?? 'N/A'), subtitle: Text('Hoàn thành: ${widget.collectors[i].completedCount}'), value: widget.collectors[i].collectorId, groupValue: _selectedId, onChanged: (v) => setState(() => _selectedId = v)))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(onPressed: (_selectedId == null || _loading) ? null : _handle, child: _loading ? const CircularProgressIndicator() : const Text('Xác nhận')),
      ],
    );
  }
  Future<void> _handle() async {
    setState(() => _loading = true);
    try {
      await EnterpriseApiService.assignCollector(AssignCollectorRequest(requestId: widget.request.requestId, collectorId: _selectedId!));
      if (mounted) { Navigator.pop(context); widget.onAssigned(); }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        CherryToast.error(
          title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text('Lỗi: $e'),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = _getColor(status);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text(_getLabel(status), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)));
  }
  Color _getColor(String s) {
    switch (s.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'inprogress': case 'in_progress': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
  String _getLabel(String s) {
    switch (s.toLowerCase()) {
      case 'completed': return 'Hoàn thành';
      case 'pending': return 'Chờ xử lý';
      case 'inprogress': case 'in_progress': return 'Đang thu gom';
      case 'cancelled': return 'Đã hủy';
      default: return s;
    }
  }
}
