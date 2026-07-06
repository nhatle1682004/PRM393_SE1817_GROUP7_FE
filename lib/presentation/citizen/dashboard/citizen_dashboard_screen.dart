import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/waste_report.dart';
import 'package:waste_collection_management_system/services/reward_service.dart';
import 'package:waste_collection_management_system/services/waste_report_service.dart';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});

  @override
  State<CitizenDashboardScreen> createState() => _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen> {
  final _reports = WasteReportService();
  final _rewards = RewardService();
  bool _loading = true;
  int _points = 0;
  List<WasteReport> _items = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _reports.getReports(),
        _rewards.getBalance(),
      ]);
      _items = results[0] as List<WasteReport>;
      _points = results[1] as int;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorView(message: _error!, onRetry: _load);
    final pending = _items.where((r) => r.status == 'Pending').length;
    final processing = _items
        .where((r) => ['Accepted', 'Collected', 'Completed'].contains(r.status))
        .length;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Xin chào, cùng giữ thành phố sạch hơn nhé!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _StatCard(
              label: 'Tổng điểm',
              value: _points.toString(),
              icon: Icons.stars,
            ),
            _StatCard(
              label: 'Report đã gửi',
              value: _items.length.toString(),
              icon: Icons.assignment,
            ),
            _StatCard(
              label: 'Đang chờ',
              value: pending.toString(),
              icon: Icons.hourglass_empty,
            ),
            _StatCard(
              label: 'Đang xử lý/hoàn tất',
              value: processing.toString(),
              icon: Icons.recycling,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Hành động nhanh'),
        const SizedBox(height: 12),
        const Text(
          'Dùng menu bên trái/bên dưới để tạo báo cáo, xem lịch sử hoặc đổi thưởng.',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xff10b981)),
              const SizedBox(height: 12),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
