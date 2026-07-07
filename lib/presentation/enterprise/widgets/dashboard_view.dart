import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';

class DashboardView extends StatelessWidget {
  final EnterpriseStats? stats;
  final VoidCallback onRefresh;

  const DashboardView({
    super.key,
    required this.stats,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isWide ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(context, isWide),
            const SizedBox(height: 24),
            _buildCollectionsSection(context),
            const SizedBox(height: 24),
            _buildReportsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isWide) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 400;

    int crossAxisCount;
    double childAspectRatio;

    if (isVerySmall) {
      crossAxisCount = 2;
      childAspectRatio = 1.1;
    } else if (isWide) {
      crossAxisCount = 4;
      childAspectRatio = 1.2;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 1.15;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: isWide ? 16 : 10,
      mainAxisSpacing: isWide ? 16 : 10,
      childAspectRatio: childAspectRatio,
      children: [
        _StatCard(
          title: 'Tổng Collector',
          value: stats?.totalCollectors ?? 0,
          icon: Icons.people,
          color: const Color(0xFF3B82F6),
          isWide: isWide,
        ),
        _StatCard(
          title: 'Yêu cầu thu gom',
          value: stats?.totalCollections ?? 0,
          icon: Icons.local_shipping,
          color: const Color(0xFF10B981),
          isWide: isWide,
        ),
        _StatCard(
          title: 'Chờ xử lý',
          value: stats?.pendingReports ?? 0,
          icon: Icons.pending_actions,
          color: const Color(0xFFF59E0B),
          isWide: isWide,
        ),
        _StatCard(
          title: 'Hoàn thành',
          value: stats?.completedCollections ?? 0,
          icon: Icons.check_circle,
          color: const Color(0xFF6366F1),
          isWide: isWide,
        ),
      ],
    );
  }

  Widget _buildCollectionsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thu gom gần đây',
          style: TextStyle(
            fontSize: isWide ? 18 : 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        if (stats?.recentCollections?.isEmpty ?? true)
          _buildEmptyState('Chưa có yêu cầu thu gom nào')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats!.recentCollections!.length.clamp(0, 5),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = stats!.recentCollections![index];
              return _CollectionCard(item: item, isWide: isWide);
            },
          ),
      ],
    );
  }

  Widget _buildReportsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Báo cáo gần đây',
          style: TextStyle(
            fontSize: isWide ? 18 : 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        if (stats?.recentReports?.isEmpty ?? true)
          _buildEmptyState('Chưa có báo cáo nào')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats!.recentReports!.length.clamp(0, 5),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = stats!.recentReports![index];
              return _ReportCard(item: item, isWide: isWide);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final bool isWide;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final isVerySmall = MediaQuery.of(context).size.width < 400;
    final padding = isWide ? 14.0 : 10.0;
    final iconSize = isVerySmall ? 16.0 : (isWide ? 22.0 : 18.0);
    final valueFontSize = isVerySmall ? 18.0 : (isWide ? 26.0 : 22.0);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(isWide ? 10 : 7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: isWide ? 12 : 9,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final RecentCollectionDto item;
  final bool isWide;

  const _CollectionCard({required this.item, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final isVerySmall = MediaQuery.of(context).size.width < 400;
    final padding = isWide ? 14.0 : 10.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isWide ? 10 : 8),
            decoration: BoxDecoration(
              color: _getStatusColor(item.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getStatusIcon(item.status),
              color: _getStatusColor(item.status),
              size: isVerySmall ? 14 : (isWide ? 20 : 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yêu cầu #${item.requestId}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isWide ? 14 : (isVerySmall ? 10 : 12),
                  ),
                ),
                const SizedBox(height: 4),
                if (item.collectorName != null)
                  Text(
                    'Collector: ${item.collectorName}',
                    style: TextStyle(
                      fontSize: isWide ? 12 : (isVerySmall ? 8 : 10),
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          _StatusBadge(status: item.status),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'in_progress':
      case 'inprogress':
        return const Color(0xFF3B82F6);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'in_progress':
      case 'inprogress':
        return Icons.local_shipping;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
}

class _ReportCard extends StatelessWidget {
  final RecentReportDto item;
  final bool isWide;

  const _ReportCard({required this.item, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final isVerySmall = MediaQuery.of(context).size.width < 400;
    final padding = isWide ? 14.0 : 10.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isWide ? 10 : 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.report_problem,
              color: const Color(0xFFF59E0B),
              size: isVerySmall ? 14 : (isWide ? 20 : 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Báo cáo #${item.reportId}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isWide ? 14 : (isVerySmall ? 10 : 12),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.submittedByName,
                  style: TextStyle(
                    fontSize: isWide ? 12 : (isVerySmall ? 8 : 10),
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.wasteTypeNames.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: item.wasteTypeNames.take(2).map((type) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(fontSize: isWide ? 10 : 8),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          _StatusBadge(status: item.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'accepted':
        return const Color(0xFF3B82F6);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'collected':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  String _getLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Hoàn thành';
      case 'pending':
        return 'Chờ xử lý';
      case 'in_progress':
      case 'inprogress':
        return 'Đang thu gom';
      case 'accepted':
        return 'Đã duyệt';
      case 'rejected':
        return 'Từ chối';
      case 'cancelled':
        return 'Đã hủy';
      case 'collected':
        return 'Đã thu gom';
      default:
        return status;
    }
  }
}
