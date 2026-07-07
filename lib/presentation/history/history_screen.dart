import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/presentation/history/report_detail_screen.dart';
import '../../services/citizen_api_service.dart';
import 'history_contract.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  String? _error;
  List<WasteReportItem> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final reports = await CitizenApiService.getMyReports();
      if (mounted) setState(() { _reports = reports; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final maxWidth = isMobile ? double.infinity : 900.0;
        
        return Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                _buildHeader(isMobile),
                Expanded(child: _buildBody(isMobile)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        boxShadow: [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.history, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lịch sử báo cáo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text('Xem danh sách báo cáo của bạn', style: TextStyle(fontSize: 13, color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isMobile) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
    }
    if (_error != null) {
      return _buildError();
    }
    if (_reports.isEmpty) {
      return _buildEmpty();
    }
    return RefreshIndicator(
      onRefresh: _loadReports,
      color: const Color(0xFF10B981),
      child: ListView.builder(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        itemCount: _reports.length,
        itemBuilder: (context, index) => _ReportCard(report: _reports[index], isMobile: isMobile),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.report_outlined, size: 48, color: Color(0xFF10B981)),
          ),
          const SizedBox(height: 24),
          const Text('Chưa có báo cáo nào', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text('Báo cáo rác để xem tại đây!', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
          ),
          const SizedBox(height: 24),
          Text(_error ?? 'Lỗi không xác định', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final WasteReportItem report;
  final bool isMobile;

  const _ReportCard({required this.report, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final imageUrl = report.displayImageUrl;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportDetailScreen(report: report))),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 16),
            child: Row(
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Container(
                    width: 80, height: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade100),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(imageUrl, fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            color: const Color(0xFF10B981),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported_outlined, size: 32, color: Colors.grey.shade400),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                            child: Text('#${report.reportId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          _StatusChip(status: report.status),
                          const Spacer(),
                          if (report.createdAt != null) Text(_formatDate(report.createdAt!), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (report.wasteTypes.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: report.wasteTypes.take(3).map((t) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text(t, style: const TextStyle(fontSize: 12, color: Color(0xFF10B981))),
                          )).toList(),
                        ),
                      if (report.description != null && report.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(report.description!, style: TextStyle(color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(child: Text(report.locationString, style: TextStyle(color: Colors.grey.shade500, fontSize: 12), overflow: TextOverflow.ellipsis)),
                          Icon(Icons.chevron_right, color: Colors.grey.shade400),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return '${diff.inHours}h trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status.toLowerCase()) {
      case 'pending': bg = const Color(0xFFFEF3C7); fg = const Color(0xFFD97706);
      case 'accepted': case 'in_progress': bg = const Color(0xFFDBEAFE); fg = const Color(0xFF2563EB);
      case 'collected': case 'completed': bg = const Color(0xFFDCFCE7); fg = const Color(0xFF16A34A);
      case 'rejected': case 'cancelled': bg = const Color(0xFFFEE2E2); fg = const Color(0xFFDC2626);
      default: bg = const Color(0xFFF1F5F9); fg = const Color(0xFF64748B);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(_getLabel(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
    );
  }

  String _getLabel() {
    switch (status.toLowerCase()) {
      case 'pending': return 'Chờ xử lý';
      case 'accepted': return 'Đã chấp nhận';
      case 'in_progress': return 'Đang xử lý';
      case 'collected': return 'Đã thu gom';
      case 'completed': return 'Hoàn thành';
      case 'rejected': return 'Từ chối';
      case 'cancelled': return 'Đã hủy';
      default: return status;
    }
  }
}
