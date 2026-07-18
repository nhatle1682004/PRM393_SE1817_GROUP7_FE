import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';
import 'assignments_view_widgets.dart';

class AssignmentsView extends StatefulWidget {
  final int? pendingRequestId;
  final VoidCallback? onAssignmentComplete;
  const AssignmentsView({super.key, this.pendingRequestId, this.onAssignmentComplete});
  @override
  State<AssignmentsView> createState() => _AssignmentsViewState();
}

class _AssignmentsViewState extends State<AssignmentsView> {
  List<EnterpriseAssignment> _assignments = [];
  List<EnterpriseCollector> _collectors = [];
  bool _isLoading = true, _isLoadingCollectors = false, _isAssigning = false;
  String _statusFilter = 'Tất cả';
  final List<String> _filters = ['Tất cả', 'Pending', 'InProgress', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.pendingRequestId != null) WidgetsBinding.instance.addPostFrameCallback((_) => _showAssignDialog(widget.pendingRequestId!));
  }

  @override
  void didUpdateWidget(AssignmentsView old) {
    super.didUpdateWidget(old);
    if (widget.pendingRequestId != null && widget.pendingRequestId != old.pendingRequestId) _showAssignDialog(widget.pendingRequestId!);
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    try {
      final res = await EnterpriseApiService.getAssignments();
      if (mounted) setState(() { _assignments = res; _isLoading = false; });
    } catch (e) { if (mounted) setState(() { _isLoading = false; }); }
    _loadCollectors();
  }

  Future<void> _loadCollectors() async {
    if (_isLoadingCollectors) return;
    setState(() => _isLoadingCollectors = true);
    try {
      final res = await EnterpriseApiService.getCollectors();
      if (mounted) setState(() { _collectors = res; _isLoadingCollectors = false; });
    } catch (_) { if (mounted) setState(() => _isLoadingCollectors = false); }
  }

  void _showAssignDialog(int requestId, {bool reassign = false, int? excludeId}) {
    int? localId;
    showDialog(context: context, builder: (c) => StatefulBuilder(builder: (c, setS) => AssignCollectorDialog(
      requestId: requestId,
      isLoading: _isLoadingCollectors,
      collectors: _collectors.where((c) => c.canReceiveAssignment && c.collectorId != excludeId).toList(),
      selectedId: localId,
      onSelect: (id) => setS(() => localId = id),
      onAssign: (id) => reassign ? _doReassign(requestId, id) : _doAssign(requestId, id),
    )));
  }

  Future<void> _doAssign(int reqId, int colId) async {
    if (_isAssigning) return;
    setState(() => _isAssigning = true);
    try {
      await EnterpriseApiService.assignCollector(AssignCollectorRequest(requestId: reqId, collectorId: colId));
      await _loadData();
      widget.onAssignmentComplete?.call();
    } catch (e) { _showMsg('Lỗi: $e', true); }
    finally { if (mounted) setState(() => _isAssigning = false); }
  }

  Future<void> _doReassign(int reqId, int colId) async {
    // Note: reassign uses assignmentId in original code, but requestId was passed.
    // Need to find assignmentId from requestId.
    final assignment = _assignments.firstWhere((a) => a.requestId == reqId);
    setState(() => _isAssigning = true);
    try {
      await EnterpriseApiService.reassignCollector(assignment.assignmentId, colId);
      await _loadData();
      _showMsg('Gán lại thành công');
    } catch (e) { _showMsg('Lỗi: $e', true); }
    finally { if (mounted) setState(() => _isAssigning = false); }
  }

  void _showMsg(String m, [bool err = false]) {
    if (!mounted) return;
    if (err) {
      CherryToast.error(
        title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
        description: Text(m),
        animationType: AnimationType.fromRight,
        autoDismiss: true,
      ).show(context);
    } else {
      CherryToast.success(
        title: const Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
        description: Text(m),
        animationType: AnimationType.fromRight,
        autoDismiss: true,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _statusFilter == 'Tất cả' ? _assignments : _assignments.where((a) => a.status == _statusFilter).toList();
    return Column(children: [
      _buildHeader(filtered.length),
      _buildFilterRow(),
      Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : (filtered.isEmpty ? const Center(child: Text('Chưa có dữ liệu')) : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (c, i) => AssignmentCard(
          assignment: filtered[i],
          onCancel: () => _cancel(filtered[i]),
          onReassign: () => _showAssignDialog(filtered[i].requestId, reassign: true, excludeId: filtered[i].assignedCollector),
        ),
      ))),
    ]);
  }

  Widget _buildHeader(int count) => Container(
    padding: const EdgeInsets.all(16),
    color: Colors.white,
    child: Row(children: [
      Text('$count phân công', style: const TextStyle(color: Colors.grey)),
      const Spacer(),
      IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh, color: Colors.green)),
    ]),
  );

  Widget _buildFilterRow() => SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: _filters.map((f) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: FilterChip(
      label: Text(f),
      selected: _statusFilter == f,
      onSelected: (s) => setState(() => _statusFilter = f),
      selectedColor: Colors.green.withValues(alpha: 0.1),
    ),
  )).toList()));

  Future<void> _cancel(EnterpriseAssignment a) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Hủy phân công'), content: const Text('Bạn có chắc?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Không')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Có'))]));
    if (ok == true) {
      try { await EnterpriseApiService.cancelAssignment(a.assignmentId); _loadData(); }
      catch (e) { _showMsg('Lỗi: $e', true); }
    }
  }
}
