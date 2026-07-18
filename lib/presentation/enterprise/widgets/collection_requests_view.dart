import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/collection_progress_view.dart';
import 'collection_requests_widgets.dart';

class CollectionRequestsView extends StatefulWidget {
  const CollectionRequestsView({super.key});
  @override
  State<CollectionRequestsView> createState() => _CollectionRequestsViewState();
}

class _CollectionRequestsViewState extends State<CollectionRequestsView> {
  List<EnterpriseCollectionRequest> _requests = [];
  List<EnterpriseCollector> _collectors = [];
  bool _isLoading = true;
  String? _error;
  String _statusFilter = 'Tất cả';
  final List<String> _filters = ['Tất cả', 'Pending', 'InProgress', 'Completed', 'Cancelled'];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await Future.wait([EnterpriseApiService.getCollectionRequests(), EnterpriseApiService.getCollectors()]);
      if (mounted) setState(() { _requests = res[0] as List<EnterpriseCollectionRequest>; _collectors = (res[1] as List<EnterpriseCollector>).where((c) => c.canReceiveAssignment).toList(); _isLoading = false; });
    } catch (e) { if (mounted) setState(() { _error = e.toString(); _isLoading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _statusFilter == 'Tất cả' ? _requests : _requests.where((r) => r.status == _statusFilter).toList();
    return Column(children: [
      _buildHeader(filtered.length),
      _buildFilters(),
      Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : (_error != null ? Center(child: Text(_error!)) : (filtered.isEmpty ? const Center(child: Text('Không có dữ liệu')) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: filtered.length, itemBuilder: (c, i) => RequestCard(request: filtered[i], onTap: () => _showDetail(filtered[i]), onAssign: () => _showAssign(filtered[i])))))),
    ]);
  }

  Widget _buildHeader(int count) => Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))), child: Row(children: [const Text('TIẾN ĐỘ XỬ LÝ', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text('$count yêu cầu', style: const TextStyle(color: Colors.green, fontSize: 12))), const Spacer(), IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh, color: Colors.green))]));

  Widget _buildFilters() => SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(12), child: Row(children: _filters.map((f) => Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(label: Text(f), selected: _statusFilter == f, onSelected: (s) => setState(() => _statusFilter = f)))).toList()));

  void _showAssign(EnterpriseCollectionRequest r) => showDialog(context: context, builder: (c) => AssignCollectorDialog(request: r, collectors: _collectors, onAssigned: _loadData));

  void _showDetail(EnterpriseCollectionRequest r) => Navigator.push(context, MaterialPageRoute(builder: (c) => CollectionProgressView(requestId: r.requestId, reportId: r.reportId, onRefresh: _loadData)));
}
