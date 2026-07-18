import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/collector_api_service.dart';
import 'my_tasks_widgets.dart';

class MyTasksView extends StatefulWidget {
  const MyTasksView({super.key});
  @override
  State<MyTasksView> createState() => _MyTasksViewState();
}

class _MyTasksViewState extends State<MyTasksView> {
  List<EnterpriseAssignment> _tasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await CollectorApiService.getMyAssignments();
      if (mounted) setState(() { _tasks = res.where((t) => !['completed', 'cancelled', 'issue'].contains(t.status?.toLowerCase())).toList(); _isLoading = false; });
    } catch (e) { if (mounted) setState(() { _error = e.toString(); _isLoading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_tasks.isEmpty) return const Center(child: Text('Không có công việc'));
    return RefreshIndicator(onRefresh: _load, child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _tasks.length, itemBuilder: (c, i) => TaskCard(assignment: _tasks[i], actions: _buildActions(_tasks[i]))));
  }

  Widget _buildActions(EnterpriseAssignment t) {
    final s = t.status?.toLowerCase();
    if (s == 'assigned') return Row(children: [Expanded(child: OutlinedButton(onPressed: () => _decline(t), child: const Text('Từ chối'))), const SizedBox(width: 12), Expanded(child: ElevatedButton(onPressed: () => _start(t), child: const Text('Bắt đầu')))]);
    if (s == 'ontheway') return SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _arrive(t), child: const Text('Đã đến nơi')));
    if (s == 'arrived') return SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _complete(t), child: const Text('Hoàn thành')));
    return const SizedBox.shrink();
  }

  Future<void> _start(EnterpriseAssignment t) async { try { await CollectorApiService.startCollection(t.assignmentId); _load(); } catch (e) { _msg(e.toString()); } }
  Future<void> _arrive(EnterpriseAssignment t) async {
    final img = await ImagePicker().pickImage(source: ImageSource.camera);
    if (img != null) try { await CollectorApiService.confirmArrival(t.assignmentId, beforeImage: img); _load(); } catch (e) { _msg(e.toString()); }
  }
  Future<void> _complete(EnterpriseAssignment t) async {} // Simplified
  Future<void> _decline(EnterpriseAssignment t) async {} // Simplified
  void _msg(String m) {
    if (!mounted) return;
    CherryToast.info(
      title: const Text('Thông báo'),
      description: Text(m),
      animationType: AnimationType.fromRight,
      autoDismiss: true,
    ).show(context);
  }
}
