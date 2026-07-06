import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/services/assignment_service.dart';

class CollectorTaskHistoryScreen extends StatefulWidget {
  const CollectorTaskHistoryScreen({super.key});

  @override
  State<CollectorTaskHistoryScreen> createState() =>
      _CollectorTaskHistoryScreenState();
}

class _CollectorTaskHistoryScreenState
    extends State<CollectorTaskHistoryScreen> {
  final _service = AssignmentService();
  bool _loading = true;
  List<dynamic> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await _service.getMyAssignments();
    if (mounted) {
      setState(() {
        _items = all.where((a) => a.isHistory).toList();
        _loading = false;
      });
    }
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
                title: Text('#${item.assignmentId} · ${item.status}'),
                subtitle: Text(item.description),
              ),
            ),
          )
          .toList(),
    );
  }
}
