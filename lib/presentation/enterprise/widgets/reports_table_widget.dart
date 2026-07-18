import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'reports_table_widgets.dart';

class ReportsTableWidget extends StatefulWidget {
  final List<EnterpriseReport> reports;
  final List<EnterpriseCollector> collectors;
  final int totalItems, currentPage, itemsPerPage;
  final Function(int page) onPageChanged;
  final Function(int id, String reason) onReject;
  final Function(int id, int? colId) onAccept;
  final bool isLoading;

  const ReportsTableWidget({super.key, required this.reports, required this.collectors, required this.totalItems, required this.currentPage, this.itemsPerPage = 10, required this.onPageChanged, required this.onReject, required this.onAccept, this.isLoading = false});

  @override
  State<ReportsTableWidget> createState() => _ReportsTableWidgetState();
}

class _ReportsTableWidgetState extends State<ReportsTableWidget> {
  final Map<int, int> _steps = {};
  final Map<int, TextEditingController> _rejs = {};

  @override
  void dispose() {
    for (final c in _rejs.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Card(child: Container(width: double.infinity, decoration: BoxDecoration(border: Border.all(color: Colors.green, width: 2), borderRadius: BorderRadius.circular(12)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: const [DataColumn(label: Text('ID')), DataColumn(label: Text('Ảnh')), DataColumn(label: Text('Loại rác')), DataColumn(label: Text('Người báo')), DataColumn(label: Text('Thời gian')), DataColumn(label: Text('Mức độ')), DataColumn(label: Text('Trạng thái')), DataColumn(label: Text('Hành động'))], rows: widget.reports.map((r) => _row(r)).toList())))),
      const SizedBox(height: 20),
      _pagination(),
    ]);
  }

  DataRow _row(EnterpriseReport r) {
    final step = _steps[r.reportId] ?? 0;
    final isPending = r.status.toLowerCase() == 'pending';
    return DataRow(cells: [
      DataCell(Text('#${r.reportId}')),
      DataCell(Image.network(ApiConfig.getFullImageUrl(r.imageUrl), width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image))),
      DataCell(Text(r.wasteTypeNames.join(', '))),
      DataCell(Text(r.submittedByName)),
      DataCell(Text('${r.createdAt?.day}/${r.createdAt?.month}')),
      DataCell(Text(r.estimatedSize ?? 'N/A')),
      DataCell(Text(r.status)),
      DataCell(Row(children: [
        IconButton(icon: const Icon(Icons.visibility), onPressed: () => showDialog(context: context, builder: (c) => ReportDetailDialog(report: r))),
        if (isPending) ...[
          if (step == 0) ...[
            TextButton(onPressed: () => setState(() => _steps[r.reportId] = 1), child: const Text('Từ chối', style: TextStyle(color: Colors.red))),
            ElevatedButton(onPressed: () => setState(() => _steps[r.reportId] = 2), child: const Text('Duyệt')),
          ] else if (step == 1) ...[
            SizedBox(width: 80, child: TextField(controller: _rejs.putIfAbsent(r.reportId, () => TextEditingController()), decoration: const InputDecoration(hintText: 'Lý do'))),
            IconButton(icon: const Icon(Icons.check, color: Colors.red), onPressed: () { widget.onReject(r.reportId, _rejs[r.reportId]!.text); setState(() => _steps[r.reportId] = 0); }),
            IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _steps[r.reportId] = 0)),
          ] else if (step == 2) ...[
            const Text('Gán NV?'),
            TextButton(onPressed: () { widget.onAccept(r.reportId, null); setState(() => _steps[r.reportId] = 0); }, child: const Text('K')),
            ElevatedButton(onPressed: () => _showAssign(r), child: const Text('C')),
          ]
        ] else if (r.status.toLowerCase() == 'accepted') ...[
          TextButton(onPressed: () => _showAssign(r), child: Text(r.assignedCollectorId == null ? 'Gán NV' : 'Đổi NV')),
        ]
      ])),
    ]);
  }

  void _showAssign(EnterpriseReport r) => showDialog(context: context, builder: (c) => ReportAssignmentDialog(report: r, collectors: widget.collectors, onAssign: (id) { widget.onAccept(r.reportId, id); Navigator.pop(c); setState(() => _steps[r.reportId] = 0); }));

  Widget _pagination() {
    final total = (widget.totalItems / widget.itemsPerPage).ceil();
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(onPressed: widget.currentPage > 1 ? () => widget.onPageChanged(widget.currentPage - 1) : null, icon: const Icon(Icons.chevron_left)),
      Text('${widget.currentPage} / $total'),
      IconButton(onPressed: widget.currentPage < total ? () => widget.onPageChanged(widget.currentPage + 1) : null, icon: const Icon(Icons.chevron_right)),
    ]);
  }
}
