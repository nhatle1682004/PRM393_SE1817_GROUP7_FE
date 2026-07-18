import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';
import 'collection_progress_widgets.dart';

class CollectionProgressView extends StatefulWidget {
  final int requestId;
  final int? reportId;
  final VoidCallback onRefresh;
  const CollectionProgressView({super.key, required this.requestId, this.reportId, required this.onRefresh});
  @override
  State<CollectionProgressView> createState() => _CollectionProgressViewState();
}

class _CollectionProgressViewState extends State<CollectionProgressView> {
  CollectionRequestDetail? _detail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await EnterpriseApiService.getCollectionRequestById(widget.requestId);
      if (mounted) setState(() { _detail = res; _isLoading = false; });
    } catch (e) { if (mounted) setState(() { _error = e.toString(); _isLoading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tiến độ #${_detail?.report?.reportId ?? widget.reportId ?? widget.requestId}'), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : (_error != null ? Center(child: Text(_error!)) : _buildContent()),
    );
  }

  Widget _buildContent() {
    final a = _detail?.assignmentHistory?.first;
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _card('Thông tin chung', [
        _row(Icons.person, 'Người báo', _detail?.report?.citizenName ?? 'N/A'),
        _row(Icons.delete, 'Loại rác', _detail?.report?.wasteTypeNames.join(', ') ?? 'N/A'),
        _row(Icons.location_on, 'Vị trí', _detail?.report?.location ?? 'N/A'),
      ]),
      const SizedBox(height: 20),
      if (a != null) ...[
        const Text('TIẾN TRÌNH', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        TimelineStep(title: 'Đã gán', subtitle: 'NV: ${a.collectorName}', time: a.assignedAt, isDone: a.assignedAt != null),
        TimelineStep(title: 'Đang di chuyển', subtitle: 'NV đang đến', time: a.startedAt, isDone: a.startedAt != null),
        TimelineStep(title: 'Đã đến', subtitle: 'Đã xác nhận bãi rác', time: a.arrivedAt, isDone: a.arrivedAt != null),
        TimelineStep(title: 'Hoàn thành', subtitle: 'Đã thu gom', time: a.completedAt, isDone: a.completedAt != null, isLast: true, isError: a.status == 'ReportedIssue'),
        const SizedBox(height: 20),
        ProofGallery(before: a.beforeImageUrl, after: a.afterImageUrl),
        const SizedBox(height: 20),
        if (a.collectionDetails != null) _card('Khối lượng thực tế', a.collectionDetails!.map((d) => _row(Icons.scale, d.wasteTypeName ?? 'N/A', '${d.actualWeight} kg')).toList()),
      ]
    ]));
  }

  Widget _card(String t, List<Widget> children) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold)), const Divider(), ...children])));
  Widget _row(IconData i, String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(i, size: 16, color: Colors.grey), const SizedBox(width: 8), Text('$l: ', style: const TextStyle(color: Colors.grey)), Text(v, style: const TextStyle(fontWeight: FontWeight.bold))]));
}
