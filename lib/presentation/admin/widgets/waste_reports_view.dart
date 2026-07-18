import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/admin_waste_report.dart';
import 'package:waste_collection_management_system/services/admin_api_service.dart';
import 'package:waste_collection_management_system/presentation/admin/widgets/pagination_controls.dart';
import 'waste_reports_widgets.dart';

class WasteReportsView extends StatefulWidget {
  const WasteReportsView({super.key});
  @override
  State<WasteReportsView> createState() => _WasteReportsViewState();
}

class _WasteReportsViewState extends State<WasteReportsView> {
  List<AdminWasteReport> _reports = [];
  bool _isLoading = true;
  String _search = '', _status = 'All';
  int _page = 0;
  final int _size = 10;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await AdminApiService.getAllWasteReports();
      if (mounted) setState(() { _reports = res; _isLoading = false; });
    } catch (_) { if (mounted) setState(() => _isLoading = false); }
  }

  List<AdminWasteReport> get _filtered => _reports.where((r) => (r.reportId.toString().contains(_search) || r.submittedByName.toLowerCase().contains(_search.toLowerCase())) && (_status == 'All' || r.status == _status)).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final paged = filtered.skip(_page * _size).take(_size).toList();
    return Column(children: [
      _toolbar(),
      Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(padding: const EdgeInsets.all(12), itemCount: paged.length, itemBuilder: (c, i) => ReportAdminCard(report: paged[i], onDetail: () {}))),
      PaginationControls(currentPage: _page, totalItems: filtered.length, pageSize: _size, onPageChanged: (p) => setState(() => _page = p)),
    ]);
  }

  Widget _toolbar() => Container(padding: const EdgeInsets.all(12), color: Colors.white, child: Row(children: [
    Expanded(child: TextField(onChanged: (v) => setState(() { _search = v; _page = 0; }), decoration: const InputDecoration(hintText: 'Tìm kiếm...'))),
    const SizedBox(width: 12),
    DropdownButton<String>(value: _status, items: ['All', 'Pending', 'Processing', 'Completed', 'Rejected', 'Cancelled'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() { _status = v!; _page = 0; })),
  ]));
}
