import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';
import 'feedbacks_widgets.dart';

class FeedbacksView extends StatefulWidget {
  const FeedbacksView({super.key});
  @override
  State<FeedbacksView> createState() => _FeedbacksViewState();
}

class _FeedbacksViewState extends State<FeedbacksView> {
  List<EnterpriseFeedback> _feedbacks = [];
  bool _isLoading = true;
  String? _error;
  String _filter = 'Tất cả';
  final _filters = ['Tất cả', 'Pending', 'Resolved', 'Rejected'];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await EnterpriseApiService.getFeedbacks();
      if (mounted) setState(() { _feedbacks = res; _isLoading = false; });
    } catch (e) { if (mounted) setState(() { _error = e.toString(); _isLoading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'Tất cả' ? _feedbacks : _feedbacks.where((f) => f.status == _filter).toList();
    return Column(children: [
      _buildHeader(filtered.length),
      _buildFilters(),
      Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : (_error != null ? Center(child: Text(_error!)) : (filtered.isEmpty ? const Center(child: Text('Không có phản hồi')) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: filtered.length, itemBuilder: (c, i) => FeedbackCard(feedback: filtered[i], onResolve: () => _showResolve(filtered[i]), onReject: () => _reject(filtered[i])))))),
    ]);
  }

  Widget _buildHeader(int count) => Container(padding: const EdgeInsets.all(16), color: Colors.white, child: Row(children: [Text('$count phản hồi', style: const TextStyle(color: Colors.grey)), const Spacer(), IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: Colors.green))]));

  Widget _buildFilters() => SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: _filters.map((f) => Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(label: Text(f), selected: _filter == f, onSelected: (s) => setState(() => _filter = f)))).toList()));

  void _showResolve(EnterpriseFeedback f) => showDialog(context: context, builder: (c) => ResolveFeedbackDialog(onResolve: (act, note) async {
    try {
      await EnterpriseApiService.resolveFeedback(f.feedbackId, ResolveFeedbackRequest(action: act, adminNote: note));
      _load();
    } catch (e) { _msg('Lỗi: $e', true); }
  }));

  Future<void> _reject(EnterpriseFeedback f) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Từ chối?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Không')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Có'))]));
    if (ok == true) try { await EnterpriseApiService.rejectFeedback(f.feedbackId); _load(); } catch (e) { _msg('Lỗi: $e', true); }
  }

  void _msg(String m, [bool err = false]) {
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
}
