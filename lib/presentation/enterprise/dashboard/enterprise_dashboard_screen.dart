import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/services/assignment_service.dart';
import 'package:waste_collection_management_system/services/waste_report_service.dart';

class EnterpriseDashboardScreen extends StatefulWidget {
  const EnterpriseDashboardScreen({super.key});

  @override
  State<EnterpriseDashboardScreen> createState() =>
      _EnterpriseDashboardScreenState();
}

class _EnterpriseDashboardScreenState extends State<EnterpriseDashboardScreen> {
  final _reports = WasteReportService();
  final _assignments = AssignmentService();
  bool _loading = true;
  int _pendingReports = 0;
  int _requests = 0;
  int _activeAssignments = 0;
  int _completed = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final reports = await _reports.getReports();
      final requests = await _assignments.getCollectionRequests();
      _pendingReports = reports.where((r) => r.status == 'Pending').length;
      _requests = requests.length;
      _activeAssignments = requests
          .where((r) => ['Assigned', 'InProgress'].contains(r.status))
          .length;
      _completed = requests.where((r) => r.status == 'Completed').length;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return GridView.count(
      padding: const EdgeInsets.all(24),
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
      childAspectRatio: 1.8,
      children: [
        _Card('Report pending', _pendingReports),
        _Card('Collection requests', _requests),
        _Card('Assignment active', _activeAssignments),
        _Card('Completed', _completed),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String label;
  final int value;

  const _Card(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: ListTile(
          title: Text(
            '$value',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          subtitle: Text(label),
        ),
      ),
    );
  }
}
