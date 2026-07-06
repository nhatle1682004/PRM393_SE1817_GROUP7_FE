import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/dashboard_stats.dart';
import 'package:waste_collection_management_system/services/dashboard_service.dart';

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  final _service = DashboardService();
  DashboardStats? _stats;

  @override
  void initState() {
    super.initState();
    _service
        .getAdminDashboard(year: DateTime.now().year)
        .then((value) {
          if (mounted) setState(() => _stats = value);
        })
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    if (stats == null) return const Center(child: CircularProgressIndicator());
    return GridView.count(
      padding: const EdgeInsets.all(24),
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
      childAspectRatio: 1.7,
      children: [
        _Card('Users', stats.totalUsers),
        _Card('Reports', stats.totalReports),
        _Card('Completed collections', stats.totalCompletedCollections),
        _Card('Rewards/points', stats.totalRewards),
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
