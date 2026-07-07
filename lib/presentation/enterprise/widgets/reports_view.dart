import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';

class ReportsView extends StatefulWidget {
  final Function(int requestId)? onReportAccepted;

  const ReportsView({super.key, this.onReportAccepted});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  List<EnterpriseReport> _reports = [];
  bool _isLoading = true;
  String? _error;
  String _statusFilter = 'Tất cả';
  final List<String> _statusFilters = ['Tất cả', 'Chưa gán', 'Pending', 'Accepted', 'Rejected', 'Collected'];
  final Set<int> _processingReportIds = {};

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await AuthService.getProfile();
      final districtId = profile?.managedDistrictId;
      final reports = districtId != null
        ? await EnterpriseApiService.getReportsByDistrict(districtId)
        : await EnterpriseApiService.getReports();
      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<EnterpriseReport> get _filteredReports {
    if (_statusFilter == 'Tất cả') return _reports;
    if (_statusFilter == 'Chưa gán') {
      // Báo cáo Accepted (đã duyệt) nhưng chưa được gán collector
      return _reports.where((r) => r.status == 'Accepted').toList();
    }
    return _reports.where((r) => r.status == _statusFilter).toList();
  }

  Future<void> _acceptReport(EnterpriseReport report) async {
    if (_processingReportIds.contains(report.reportId)) return;

    _processingReportIds.add(report.reportId);

    try {
      if (report.status != 'Pending') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Báo cáo đã được xử lý trước đó (${report.status})'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final acceptedReport = await EnterpriseApiService.acceptReport(report.reportId);
      debugPrint('Accept report response: requestId=${acceptedReport.requestId}');

      // Update UI ngay lập tức
      if (mounted) {
        setState(() {
          final index = _reports.indexWhere((r) => r.reportId == report.reportId);
          if (index != -1) {
            _reports[index] = EnterpriseReport(
              reportId: report.reportId,
              requestId: acceptedReport.requestId,
              submittedByName: report.submittedByName,
              wasteTypeNames: report.wasteTypeNames,
              status: 'Accepted',
              description: report.description,
              imageUrl: report.imageUrl,
              latitude: report.latitude,
              longitude: report.longitude,
              createdAt: report.createdAt,
              assignedCollectorName: null,
              assignedCollectorId: null,
            );
          }
        });

        final requestId = acceptedReport.requestId;
        debugPrint('RequestId after accept: $requestId');
        if (requestId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã duyệt báo cáo - Chuyển sang phân công'),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'Phân công',
                textColor: Colors.white,
                onPressed: () => widget.onReportAccepted?.call(requestId),
              ),
            ),
          );

          // Tự động chuyển sang trang phân công sau 1.5s
          Future.delayed(const Duration(milliseconds: 1500), () {
            widget.onReportAccepted?.call(requestId);
          });
        }
      }
    } on Exception catch (e) {
      if (!e.toString().contains('404') && !e.toString().contains('Không tìm thấy')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      _processingReportIds.remove(report.reportId);
    }
  }

  Future<void> _rejectReport(EnterpriseReport report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối báo cáo'),
        content: Text('Từ chối báo cáo #${report.reportId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await EnterpriseApiService.rejectReport(report.reportId);

        // Update UI ngay lập tức
        if (mounted) {
          setState(() {
            final index = _reports.indexWhere((r) => r.reportId == report.reportId);
            if (index != -1) {
              _reports[index] = EnterpriseReport(
                reportId: report.reportId,
                submittedByName: report.submittedByName,
                wasteTypeNames: report.wasteTypeNames,
                status: 'Rejected',
                description: report.description,
                imageUrl: report.imageUrl,
                latitude: report.latitude,
                longitude: report.longitude,
                createdAt: report.createdAt,
                assignedCollectorName: null,
                assignedCollectorId: null,
              );
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã từ chối báo cáo'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      } on Exception catch (e) {
        if (!e.toString().contains('404') && !e.toString().contains('Không tìm thấy')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Pending':
        return 'Chờ duyệt';
      case 'Accepted':
        return 'Đã duyệt';
      case 'Rejected':
        return 'Từ chối';
      case 'Collected':
        return 'Đã thu gom';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Accepted':
        return const Color(0xFF10B981);
      case 'Rejected':
        return const Color(0xFFEF4444);
      case 'Collected':
        return const Color(0xFF6366F1);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Column(
      children: [
        // Filter tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusFilters.map((filter) {
                final isSelected = _statusFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter == 'Tất cả' ? filter : _getStatusLabel(filter)),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _statusFilter = filter),
                    selectedColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFF10B981),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorState()
                  : _filteredReports.isEmpty
                      ? _buildEmptyState()
                      : isWide
                          ? _buildDesktopList()
                          : _buildMobileCardList(),
        ),
      ],
    );
  }

  Widget _buildDesktopList() {
    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredReports.length,
        itemBuilder: (context, index) {
          final report = _filteredReports[index];
          return _buildReportCard(report, isCompact: false);
        },
      ),
    );
  }

  Widget _buildMobileCardList() {
    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredReports.length,
        itemBuilder: (context, index) {
          final report = _filteredReports[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildReportCard(report, isCompact: true),
          );
        },
      ),
    );
  }

  Widget _buildReportCard(EnterpriseReport report, {required bool isCompact}) {
    final isPending = report.status == 'Pending';
    final isProcessing = _processingReportIds.contains(report.reportId);

    if (isCompact) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showReportDetail(report),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(report.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusLabel(report.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(report.status),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '#${report.reportId}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (report.wasteTypeNames.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: report.wasteTypeNames.map((type) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                if (report.description != null && report.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    report.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.submittedByName,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (report.createdAt != null) ...[
                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateTime(report.createdAt!),
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
                if (isPending) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isProcessing ? null : () => _rejectReport(report),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Từ chối'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: isProcessing ? null : () => _acceptReport(report),
                          icon: isProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.check, size: 18),
                          label: Text(isProcessing ? 'Đang xử lý...' : 'Duyệt & Phân công'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Desktop version - more compact row
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(report.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusLabel(report.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(report.status),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 60,
              child: Text(
                '#${report.reportId}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                report.wasteTypeNames.join(', '),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                report.submittedByName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            if (report.createdAt != null)
              SizedBox(
                width: 100,
                child: Text(
                  _formatDateTime(report.createdAt!),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
            if (isPending) ...[
              TextButton(
                onPressed: isProcessing ? null : () => _rejectReport(report),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                ),
                child: const Text('Từ chối', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isProcessing ? null : () => _acceptReport(report),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(isProcessing ? '...' : 'Duyệt'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReportDetail(EnterpriseReport report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Chi tiết báo cáo #${report.reportId}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _detailRow('Trạng thái', _getStatusLabel(report.status)),
                  _detailRow('Người gửi', report.submittedByName),
                  if (report.wasteTypeNames.isNotEmpty)
                    _detailRow('Loại rác', report.wasteTypeNames.join(', ')),
                  if (report.description != null)
                    _detailRow('Mô tả', report.description!),
                  if (report.imageUrl != null && report.imageUrl!.isNotEmpty)
                    _detailRow('Hình ảnh', report.imageUrl!),
                  if (report.createdAt != null)
                    _detailRow('Thời gian', _formatDateTime(report.createdAt!)),
                  if (report.assignedCollectorName != null)
                    _detailRow('Nhân viên', report.assignedCollectorName!),
                  const SizedBox(height: 16),
                  if (report.status == 'Pending')
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _rejectReport(report);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFEF4444)),
                            ),
                            child: const Text('Từ chối'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _acceptReport(report);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Duyệt & Phân công'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Không có báo cáo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadReports,
            child: const Text('Tải lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(_error ?? 'Lỗi không xác định'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadReports,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
