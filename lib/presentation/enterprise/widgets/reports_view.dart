import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/reports_table_widget.dart';

class ReportsView extends StatefulWidget {
  final Function(int requestId)? onReportAccepted;

  const ReportsView({super.key, this.onReportAccepted});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  List<EnterpriseReport> _reports = [];
  List<EnterpriseCollector> _collectors = [];
  bool _isLoading = true;
  String? _error;
  String _statusFilter = 'Tất cả';
  final List<String> _statusFilters = [
    'Tất cả',
    'Pending',
    'Accepted',
    'Rejected',
    'Collected',
  ];

  // Pagination state
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        AuthService.getProfile(),
        EnterpriseApiService.getCollectors(),
        EnterpriseApiService.getReports(),
      ]);

      final collectors = results[1] as List<EnterpriseCollector>;
      final allReports = results[2] as List<EnterpriseReport>;

      if (mounted) {
        setState(() {
          _reports = allReports;
          _collectors = collectors;
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
    return _reports.where((r) => r.status == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF10B981)),
                  )
                : _error != null
                ? _buildErrorState()
                : _filteredReports.isEmpty
                ? _buildEmptyState()
                : _buildMainLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _statusFilters.map((filter) {
            final isSelected = _statusFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(_getStatusLabel(filter)),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _statusFilter = filter;
                    _currentPage = 1;
                  });
                },
                selectedColor: const Color(0xFF10B981).withValues(alpha: 0.15),
                backgroundColor: const Color(0xFFF5F5F5),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : const Color(0xFF595959),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : Colors.transparent,
                  ),
                ),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMainLayout() {
    final filtered = _filteredReports;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filtered.length);
    final pagedReports = filtered.isEmpty
        ? <EnterpriseReport>[]
        : filtered.sublist(startIndex, endIndex);

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF10B981),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: ReportsTableWidget(
          reports: pagedReports,
          collectors: _assignableCollectors,
          totalItems: filtered.length,
          currentPage: _currentPage,
          itemsPerPage: _itemsPerPage,
          onPageChanged: (page) => setState(() => _currentPage = page),
          onReject: (id, reason) => _handleReject(id, reason),
          onAccept: (id, collectorId) => _handleAccept(id, collectorId),
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Tất cả':
        return 'Tất cả';
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

  List<EnterpriseCollector> get _assignableCollectors =>
      _collectors.where((collector) => collector.canReceiveAssignment).toList();

  Future<void> _handleAccept(int reportId, int? collectorId) async {
    try {
      final reportIdx = _reports.indexWhere((r) => r.reportId == reportId);
      if (reportIdx == -1) return;

      EnterpriseReport currentReport = _reports[reportIdx];
      final isAlreadyAccepted =
          currentReport.status.trim().toLowerCase() == 'accepted' ||
          currentReport.status.trim() == 'Đã duyệt';

      // 1. Nếu chưa duyệt thì gọi API duyệt (tạo Collection Request)
      if (!isAlreadyAccepted) {
        final result = await EnterpriseApiService.acceptReport(reportId);
        currentReport = currentReport.copyWith(
          status: result.status,
          requestId: result.requestId,
        );
        if (mounted) {
          setState(() {
            _reports[reportIdx] = currentReport;
          });
        }
      }

      // 2. Nếu có chọn nhân viên thì gọi API gán hoặc gán lại
      String? collectorName;
      int? assignmentId;
      if (collectorId != null) {
        final requestId = currentReport.requestId;
        if (requestId == null || requestId == 0) {
          throw Exception(
            'Không tìm thấy ID yêu cầu thu gom. Vui lòng thử lại.',
          );
        }

        // Nếu đã có assignmentId thì gọi reassign, ngược lại gọi assign
        if (currentReport.assignmentId != null &&
            currentReport.assignmentId != 0) {
          final res = await EnterpriseApiService.reassignCollector(
            currentReport.assignmentId!,
            collectorId,
          );
          assignmentId = res.assignmentId;
          collectorName = res.collectorName;
        } else {
          final res = await EnterpriseApiService.assignCollector(
            AssignCollectorRequest(
              requestId: requestId,
              collectorId: collectorId,
            ),
          );
          assignmentId = res.assignmentId;
          collectorName = res.collectorName;
        }
      }

      if (mounted) {
        setState(() {
          _reports[reportIdx] = _reports[reportIdx].copyWith(
            status: 'Accepted',
            requestId: currentReport.requestId,
            assignmentId: assignmentId ?? _reports[reportIdx].assignmentId,
            assignedCollectorId:
                collectorId ?? _reports[reportIdx].assignedCollectorId,
            assignedCollectorName:
                collectorName ?? _reports[reportIdx].assignedCollectorName,
          );
        });
        CherryToast.success(
          title: const Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
          description: const Text('Cập nhật báo cáo thành công'),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('Only Pending reports can be accepted')) {
          errorMessage =
              'Báo cáo này đã được duyệt hoặc không còn ở trạng thái chờ.';
        }
        CherryToast.error(
          title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text(errorMessage),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    }
  }

  Future<void> _handleReject(int reportId, String reason) async {
    try {
      await EnterpriseApiService.rejectReport(reportId);
      if (mounted) {
        setState(() {
          final idx = _reports.indexWhere((r) => r.reportId == reportId);
          if (idx != -1) {
            _reports[idx] = _reports[idx].copyWith(status: 'Rejected');
          }
        });
        CherryToast.success(
          title: const Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
          description: const Text('Đã từ chối báo cáo'),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        CherryToast.error(
          title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text(e.toString()),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error ?? 'Đã xảy ra lỗi'),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Không có dữ liệu',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
