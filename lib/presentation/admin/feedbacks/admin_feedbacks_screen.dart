import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/feedback.dart';
import 'package:waste_collection_management_system/services/feedback_service.dart';

class AdminFeedbacksScreen extends StatefulWidget {
  const AdminFeedbacksScreen({super.key});

  @override
  State<AdminFeedbacksScreen> createState() => _AdminFeedbacksScreenState();
}

class _AdminFeedbacksScreenState extends State<AdminFeedbacksScreen> {
  final _service = FeedbackService();
  bool _loading = true;
  List<FeedbackItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _items = await _service.getFeedbacks();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resolve(FeedbackItem item) async {
    final result = await _feedbackActionDialog();
    if (result == null) return;
    await _service.resolve(
      item.feedbackId,
      action: result.action,
      note: result.note,
    );
    await _load();
  }

  Future<void> _reject(FeedbackItem item) async {
    final reason = await _textDialog(title: 'Lý do reject', hint: 'Nhập lý do');
    if (reason == null) return;
    await _service.reject(item.feedbackId, reason: reason);
    await _load();
  }

  Future<_FeedbackAction?> _feedbackActionDialog() async {
    var action = 'reassign';
    final note = TextEditingController();
    final result = await showDialog<_FeedbackAction>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Resolve feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: action,
              decoration: const InputDecoration(labelText: 'Action'),
              items: const [
                DropdownMenuItem(value: 'reassign', child: Text('Reassign')),
                DropdownMenuItem(value: 'warn', child: Text('Warn')),
              ],
              onChanged: (value) => action = value ?? 'reassign',
            ),
            TextField(
              controller: note,
              decoration: const InputDecoration(labelText: 'Ghi chú xử lý'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              _FeedbackAction(action, note.text.trim()),
            ),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
    note.dispose();
    return result;
  }

  Future<String?> _textDialog({
    required String title,
    required String hint,
  }) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    controller.dispose();
    return value?.isEmpty == true ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _items
          .map(
            (item) => Card(
              child: ListTile(
                title: Text('Report #${item.reportId} · ${item.status}'),
                subtitle: Text('${item.userName}\n${item.content}'),
                isThreeLine: true,
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () => _resolve(item),
                      child: const Text('Resolve'),
                    ),
                    OutlinedButton(
                      onPressed: () => _reject(item),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FeedbackAction {
  final String action;
  final String note;

  const _FeedbackAction(this.action, this.note);
}
