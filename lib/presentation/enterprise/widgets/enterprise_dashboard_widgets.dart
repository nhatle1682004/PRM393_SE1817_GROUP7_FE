import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';

class EnterpriseDoughnutChart extends StatelessWidget {
  final List<EnterpriseCollectionRequest> collectionRequests;

  const EnterpriseDoughnutChart({super.key, required this.collectionRequests});

  @override
  Widget build(BuildContext context) {
    int hoanThanh = 0, dangXuLy = 0, choXuLy = 0;
    for (var req in collectionRequests) {
      final s = (req.status ?? '').toLowerCase();
      if (s.contains('completed')) {
        hoanThanh++;
      } else if (s.contains('in_progress') || s.contains('inprogress')) {
        dangXuLy++;
      } else {
        choXuLy++;
      }
    }
    final total = hoanThanh + dangXuLy + choXuLy;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        children: [
          const Text('Tổng quan thu gom', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 50,
                  sections: total > 0 ? [
                    PieChartSectionData(value: hoanThanh.toDouble(), color: const Color(0xFF10B981), showTitle: false, radius: 14),
                    PieChartSectionData(value: dangXuLy.toDouble(), color: const Color(0xFF3B82F6), showTitle: false, radius: 14),
                    PieChartSectionData(value: choXuLy.toDouble(), color: const Color(0xFFF59E0B), showTitle: false, radius: 14),
                  ] : [PieChartSectionData(value: 1, color: Colors.grey.shade200, showTitle: false, radius: 14)],
                )),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('$total', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const Text('Tổng cộng', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildLegendItem('Hoàn thành', const Color(0xFF10B981)),
            _buildLegendItem('Đang xử lý', const Color(0xFF3B82F6)),
            _buildLegendItem('Chờ xử lý', const Color(0xFFF59E0B)),
          ]),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
    ]);
  }
}

class EnterpriseStatsGrid extends StatelessWidget {
  final EnterpriseStats? stats;
  final Function(int) onTabChange;

  const EnterpriseStatsGrid({super.key, this.stats, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _buildStatCard(Icons.people_alt_outlined, (stats?.totalCollectors ?? 0).toString(), 'Nhân viên', const Color(0xFF3B82F6), () => onTabChange(2))),
      const SizedBox(width: 12),
      Expanded(child: _buildStatCard(Icons.local_shipping_outlined, (stats?.totalCollections ?? 0).toString(), 'Yêu cầu', const Color(0xFF10B981), () => onTabChange(1))),
      const SizedBox(width: 12),
      Expanded(child: _buildStatCard(Icons.pending_actions_outlined, (stats?.pendingReports ?? 0).toString(), 'Chờ duyệt', const Color(0xFFF59E0B), () => onTabChange(3))),
    ]);
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.1))),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        ]),
      ),
    );
  }
}

class RecentCollectionsList extends StatelessWidget {
  final List<EnterpriseCollectionRequest> requests;
  final VoidCallback onViewAll;

  const RecentCollectionsList({super.key, required this.requests, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final recent = requests.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Thu gom gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(onPressed: onViewAll, child: const Text('Xem tất cả')),
        ]),
        if (recent.isEmpty) const Text('Chưa có dữ liệu') else ...recent.map((req) => _buildCollectionItem(req)),
      ]),
    );
  }

  Widget _buildCollectionItem(EnterpriseCollectionRequest req) {
    final s = (req.status ?? '').toLowerCase();
    final color = s.contains('completed') ? Colors.green : (s.contains('in_progress') ? Colors.blue : Colors.orange);
    return ListTile(
      leading: const Icon(Icons.local_shipping, size: 18),
      title: Text(req.reportDescription ?? 'Không có mô tả', maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(req.createdAt != null ? _formatTime(req.createdAt!) : ''),
      trailing: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(s, style: TextStyle(color: color, fontSize: 10))),
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${date.day}/${date.month}';
  }
}

class RecentReportsList extends StatelessWidget {
  final List<EnterpriseReport> reports;
  final VoidCallback onViewAll;

  const RecentReportsList({super.key, required this.reports, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final recent = reports.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Báo cáo gần đây', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(onPressed: onViewAll, child: const Text('Xem tất cả')),
        ]),
        if (recent.isEmpty) const Text('Chưa có dữ liệu') else ...recent.map((rep) => _buildReportItem(rep)),
      ]),
    );
  }

  Widget _buildReportItem(EnterpriseReport rep) {
    return ListTile(
      leading: const Icon(Icons.report_problem, size: 18),
      title: Text(rep.description ?? 'Báo cáo rác', maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(rep.createdAt != null ? _formatTime(rep.createdAt!) : ''),
    );
  }

  String _formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${date.day}/${date.month}';
  }
}
