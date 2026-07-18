import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/admin_feedback.dart';
import 'package:waste_collection_management_system/presentation/admin/widgets/pagination_controls.dart';
import 'package:waste_collection_management_system/services/admin_api_service.dart';
import 'feedbacks_widgets.dart';

class FeedbacksView extends StatefulWidget {
  const FeedbacksView({super.key});
  @override
  State<FeedbacksView> createState() => _FeedbacksViewState();
}

class _FeedbacksViewState extends State<FeedbacksView> {
  List<AdminFeedback> _feedbacks = [];
  bool _isLoading = true;
  String _search = '', _status = 'All';
  int _page = 0;
  final int _size = 10;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await AdminApiService.getAllFeedbacks();
      if (mounted) setState(() { _feedbacks = res; _isLoading = false; });
    } catch (_) { if (mounted) setState(() => _isLoading = false); }
  }

  List<AdminFeedback> get _filtered => _feedbacks.where((f) => (f.userName.toLowerCase().contains(_search.toLowerCase()) || f.content.toLowerCase().contains(_search.toLowerCase())) && (_status == 'All' || f.status == _status)).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final paged = filtered.skip(_page * _size).take(_size).toList();
    return Column(children: [
      _toolbar(),
      Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(padding: const EdgeInsets.all(12), itemCount: paged.length, itemBuilder: (c, i) => FeedbackAdminCard(feedback: paged[i], onDetail: () {}, onResolve: () {}, onReject: () => _reject(paged[i]), canResolve: ['Pending', 'ResolveFailed'].contains(paged[i].status)))),
      PaginationControls(currentPage: _page, totalItems: filtered.length, pageSize: _size, onPageChanged: (p) => setState(() => _page = p)),
    ]);
  }

  Widget _toolbar() => Container(padding: const EdgeInsets.all(12), color: Colors.white, child: Row(children: [
    Expanded(child: TextField(onChanged: (v) => setState(() { _search = v; _page = 0; }), decoration: const InputDecoration(hintText: 'Tìm kiếm...'))),
    const SizedBox(width: 12),
    DropdownButton<String>(value: _status, items: ['All', 'Pending', 'Resolved', 'Rejected'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => setState(() { _status = v!; _page = 0; })),
  ]));

  void _reject(AdminFeedback f) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Từ chối?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Hủy')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('OK'))]));
    if (ok == true) { await AdminApiService.rejectFeedback(f.feedbackId); _load(); }
  }
}
