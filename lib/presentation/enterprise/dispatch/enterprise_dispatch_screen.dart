import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/assignment.dart';
import 'package:waste_collection_management_system/data/models/auth_user.dart';
import 'package:waste_collection_management_system/data/models/collection_request.dart';
import 'package:waste_collection_management_system/data/models/waste_report.dart';
import 'package:waste_collection_management_system/services/assignment_service.dart';
import 'package:waste_collection_management_system/services/user_service.dart';
import 'package:waste_collection_management_system/services/waste_report_service.dart';

class EnterpriseDispatchScreen extends StatefulWidget {
  const EnterpriseDispatchScreen({super.key});

  @override
  State<EnterpriseDispatchScreen> createState() =>
      _EnterpriseDispatchScreenState();
}

class _EnterpriseDispatchScreenState extends State<EnterpriseDispatchScreen> {
  final _reports = WasteReportService();
  final _assignments = AssignmentService();
  final _users = UserService();
  bool _loading = true;
  List<WasteReport> _pending = const [];
  List<CollectionRequest> _requests = const [];
  List<AuthUser> _collectors = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final reports = await _reports.getReports();
      _pending = reports.where((r) => r.status == 'Pending').toList();
      _requests = await _assignments.getCollectionRequests();
      _collectors = await _users.getCollectors();
    } catch (e) {
      _show(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _assign(CollectionRequest request) async {
    final collectorId = await showDialog<int>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Chọn collector'),
        children: _collectors
            .map(
              (u) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, u.userId),
                child: Text(u.fullName),
              ),
            )
            .toList(),
      ),
    );
    if (collectorId == null) return;
    await _assignments.assignCollector(
      requestId: request.requestId,
      collectorId: collectorId,
    );
    await _load();
  }

  Future<void> _showHistory(CollectionRequest request) async {
    try {
      final history = await _assignments.getAssignmentHistory(
        request.requestId,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Assignment history #${request.requestId}'),
          content: SizedBox(
            width: 520,
            child: history.isEmpty
                ? const Text('Chưa có assignment nào.')
                : ListView(
                    shrinkWrap: true,
                    children: history.map(_historyTile).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      _show(e.toString());
    }
  }

  Widget _historyTile(Assignment assignment) {
    return ListTile(
      dense: true,
      title: Text('#${assignment.assignmentId} · ${assignment.status}'),
      subtitle: Text(
        'Assigned: ${assignment.assignedAt ?? ''}\nCompleted: ${assignment.completedAt ?? ''}',
      ),
    );
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Reports chờ xử lý',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          ..._pending.map(
            (report) => Card(
              child: ListTile(
                title: Text('#${report.reportId} ${report.description}'),
                subtitle: Text('${report.latitude}, ${report.longitude}'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        await _reports.acceptReport(report.reportId);
                        await _load();
                      },
                      child: const Text('Accept'),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        await _reports.rejectReport(report.reportId);
                        await _load();
                      },
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 32),
          Text(
            'Collection requests',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          ..._requests.map(
            (request) => Card(
              child: ListTile(
                title: Text('#${request.requestId} · ${request.status}'),
                subtitle: Text(
                  'Report #${request.reportId} · Collector: ${request.assignedCollectorName}',
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () => _assign(request),
                      child: const Text('Assign'),
                    ),
                    OutlinedButton(
                      onPressed: () => _showHistory(request),
                      child: const Text('History'),
                    ),
                    if (request.currentAssignmentId > 0)
                      OutlinedButton(
                        onPressed: () async {
                          await _assignments.cancelAssignment(
                            request.currentAssignmentId,
                          );
                          await _load();
                        },
                        child: const Text('Cancel'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
