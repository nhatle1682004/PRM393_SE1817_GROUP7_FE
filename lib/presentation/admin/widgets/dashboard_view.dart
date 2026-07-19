import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/admin_stats.dart';

class DashboardView extends StatelessWidget {
  final AdminStats? stats;
  final VoidCallback onRefresh;

  const DashboardView({super.key, this.stats, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: const Color(0xFF10B981),
      child: ListView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        children: [
          _buildWelcomeBanner(isMobile),
          const SizedBox(height: 24),
          _buildStatCards(context, isMobile),
          const SizedBox(height: 24),
          _buildChartsSection(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xin chào, Quản trị viên!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chào mừng đến với bảng điều khiển quản trị hệ thống thu gom rác thải.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildQuickStat('Tổng User', stats?.totalUsers.toString() ?? '0', Icons.people),
                    const SizedBox(width: 24),
                    _buildQuickStat('Báo cáo', stats?.totalReports.toString() ?? '0', Icons.report),
                  ],
                ),
              ],
            ),
          ),
          if (!isMobile)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 64),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, bool isMobile) {
    final cards = [
      _StatCardData(
        title: 'Tổng người dùng',
        value: stats?.totalUsers ?? 0,
        icon: Icons.people,
        color: const Color(0xFF3B82F6),
        gradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
      ),
      _StatCardData(
        title: 'Báo cáo rác',
        value: stats?.totalReports ?? 0,
        icon: Icons.report_problem,
        color: const Color(0xFF10B981),
        gradient: const [Color(0xFF10B981), Color(0xFF059669)],
      ),
      _StatCardData(
        title: 'Yêu cầu thu gom',
        value: stats?.totalCollections ?? 0,
        icon: Icons.local_shipping,
        color: const Color(0xFFF59E0B),
        gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
      ),
      _StatCardData(
        title: 'Phản hồi',
        value: stats?.totalFeedbacks ?? 0,
        icon: Icons.feedback,
        color: const Color(0xFFEC4899),
        gradient: const [Color(0xFFEC4899), Color(0xFFDB2777)],
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildStatCard(card),
        )).toList(),
      );
    }

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: cards.map((card) => _buildStatCard(card)).toList(),
    );
  }

  Widget _buildStatCard(_StatCardData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.color, size: 24),
              ),
              Icon(Icons.trending_up, color: Colors.grey.shade400, size: 20),
            ],
          ),
          const Spacer(),
          Text(
            data.value.toString(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Biểu đồ thống kê',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 16),
        if (isMobile)
          Column(
            children: [
              _buildStatusBreakdownCard(),
              const SizedBox(height: 16),
              _buildRoleBreakdownCard(),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStatusBreakdownCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildRoleBreakdownCard()),
            ],
          ),
      ],
    );
  }

  Widget _buildStatusBreakdownCard() {
    final breakdown = stats?.reportStatusBreakdown ?? {};
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart, color: Color(0xFF3B82F6), size: 22),
              SizedBox(width: 8),
              Text(
                'Trạng thái báo cáo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (breakdown.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Chưa có dữ liệu', style: TextStyle(color: Colors.grey.shade500)),
              ),
            )
          else
            ...breakdown.entries.map((entry) => _buildProgressBar(entry.key, entry.value, _getStatusColor(entry.key))),
        ],
      ),
    );
  }

  Widget _buildRoleBreakdownCard() {
    final breakdown = stats?.userRoleBreakdown ?? {};
    final colors = [const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFFEC4899)];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.groups, color: Color(0xFF10B981), size: 22),
              SizedBox(width: 8),
              Text(
                'Phân bố người dùng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (breakdown.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Chưa có dữ liệu', style: TextStyle(color: Colors.grey.shade500)),
              ),
            )
          else
            ...breakdown.entries.toList().asMap().entries.map((entry) => 
              _buildRoleBar(entry.value.key, entry.value.value, colors[entry.key % colors.length])),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int value, Color color) {
    final total = stats?.totalReports ?? 1;
    final percentage = total > 0 ? (value / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              Text('$value (${(percentage * 100).toStringAsFixed(1)}%)', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'processing':
      case 'accepted':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

class _StatCardData {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}
