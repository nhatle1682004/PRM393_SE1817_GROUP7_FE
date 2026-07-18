import 'package:flutter/material.dart';
import 'history_contract.dart';

class ReportDetailScreen extends StatelessWidget {
  final WasteReportItem report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        title: const Text('Chi tiết báo cáo'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (report.imageUrl != null && report.imageUrl!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 240,
                    color: Colors.grey.shade100,
                    child: Image.network(
                      report.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) => const Center(child: Icon(Icons.broken_image_outlined, size: 64, color: Colors.grey)),
                      loadingBuilder: (_, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Báo cáo #${report.reportId}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                if (report.createdAt != null) ...[
                                  const SizedBox(height: 4),
                                  Text(_formatDateTime(report.createdAt!), style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                                ],
                              ],
                            ),
                          ),
                          _StatusBadge(status: report.status),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 24),
                      _InfoRow(icon: Icons.category_outlined, label: 'Loại rác', value: report.wasteTypes.isNotEmpty ? report.wasteTypes.join(', ') : 'Không có thông tin'),
                      if (report.description != null && report.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _InfoRow(icon: Icons.description_outlined, label: 'Mô tả', value: report.description!, multiline: true),
                      ],
                      const SizedBox(height: 16),
                      _InfoRow(icon: Icons.location_on_outlined, label: 'Vị trí', value: report.locationString),
                      if (report.assignedCollectorName != null) ...[
                        const SizedBox(height: 16),
                        _InfoRow(icon: Icons.person_outline, label: 'Nhân viên thu gom', value: report.assignedCollectorName!),
                      ],
                      if (report.collectedAt != null) ...[
                        const SizedBox(height: 16),
                        _InfoRow(icon: Icons.check_circle_outline, label: 'Ngày thu gom', value: _formatDateTime(report.collectedAt!)),
                      ],
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

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} lúc ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'pending': bg = const Color(0xFFFEF3C7); fg = const Color(0xFFD97706); icon = Icons.schedule;
      case 'accepted': case 'in_progress': bg = const Color(0xFFDBEAFE); fg = const Color(0xFF2563EB); icon = Icons.autorenew;
      case 'collected': case 'completed': bg = const Color(0xFFDCFCE7); fg = const Color(0xFF16A34A); icon = Icons.check_circle;
      case 'rejected': case 'cancelled': bg = const Color(0xFFFEE2E2); fg = const Color(0xFFDC2626); icon = Icons.cancel;
      default: bg = const Color(0xFFF1F5F9); fg = const Color(0xFF64748B); icon = Icons.help_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(_getLabel(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  const _InfoRow({required this.icon, required this.label, required this.value, this.multiline = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: const Color(0xFF10B981)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B), height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
