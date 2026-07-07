import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';
import 'package:waste_collection_management_system/config/api_config.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  List<EnterpriseReport> _reports = [];
  List<EnterpriseCollector> _collectors = [];
  bool _isLoading = true;
  bool _isLoadingCollectors = false;
  String? _error;
  String _statusFilter = 'Tất cả';
  final List<String> _statusFilters = ['Tất cả', 'Pending', 'Accepted', 'Rejected', 'Collected'];

  @override
  void initState() {
    super.initState();
    _loadReports();
    _loadCollectors();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reports = await EnterpriseApiService.getReports();
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

  Future<void> _loadCollectors() async {
    setState(() => _isLoadingCollectors = true);
    try {
      final collectors = await EnterpriseApiService.getCollectors();
      if (mounted) {
        setState(() {
          _collectors = collectors.where((c) => c.isAvailable).toList();
          _isLoadingCollectors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCollectors = false);
      }
    }
  }

  List<EnterpriseReport> get _filteredReports {
    if (_statusFilter == 'Tất cả') return _reports;
    return _reports.where((r) => r.status == _statusFilter).toList();
  }

  Future<void> _acceptReportWithAssignment(EnterpriseReport report, int? collectorId) async {
    if (collectorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn nhân viên xử lý'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await EnterpriseApiService.acceptReport(report.reportId);
      await EnterpriseApiService.assignReport(report.reportId, collectorId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã duyệt và phân công nhân viên'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _loadReports();
      }
    } catch (e) {
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã từ chối báo cáo'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          _loadReports();
        }
      } catch (e) {
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

  void _showAssignDialog(EnterpriseReport report) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    
    if (isWide) {
      _showAssignDialogWeb(report);
    } else {
      _showAssignBottomSheet(report);
    }
  }

  void _showAssignDialogWeb(EnterpriseReport report) {
    int? selectedCollectorId;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                ),
                const SizedBox(width: 12),
                Text('Phân công #${report.reportId}'),
              ],
            ),
            content: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chọn nhân viên thu gom để xử lý báo cáo này:',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingCollectors)
                    const Center(child: CircularProgressIndicator())
                  else if (_collectors.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Không có nhân viên rảnh'),
                        ],
                      ),
                    )
                  else
                    Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: SingleChildScrollView(
                        child: Column(
                          children: _collectors.map((collector) {
                            final isSelected = selectedCollectorId == collector.collectorId;
                            return InkWell(
                              onTap: () {
                                setDialogState(() => selectedCollectorId = collector.collectorId);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF10B981).withOpacity(0.1) : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
                                      child: Text(
                                        (collector.fullName ?? 'N').substring(0, 1).toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            collector.fullName ?? 'Nhân viên #${collector.collectorId}',
                                            style: TextStyle(
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                              color: isSelected ? const Color(0xFF10B981) : Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            '${collector.completedCount} công việc hoàn thành',
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: selectedCollectorId != null
                    ? () {
                        Navigator.pop(dialogContext);
                        _acceptReportWithAssignment(report, selectedCollectorId);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text('Xác nhận'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAssignBottomSheet(EnterpriseReport report) {
    int? selectedCollectorId;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person_add, color: Color(0xFF10B981)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Phân công #${report.reportId}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Chọn nhân viên xử lý',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _isLoadingCollectors
                      ? const Center(child: CircularProgressIndicator())
                      : _collectors.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_off, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Không có nhân viên rảnh',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _collectors.length,
                              itemBuilder: (context, index) {
                                final collector = _collectors[index];
                                final isSelected = selectedCollectorId == collector.collectorId;
                                
                                return InkWell(
                                  onTap: () {
                                    setSheetState(() => selectedCollectorId = collector.collectorId);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF10B981).withOpacity(0.08) : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade200,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
                                          child: Text(
                                            (collector.fullName ?? 'N').substring(0, 1).toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                collector.fullName ?? 'Nhân viên #${collector.collectorId}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Icon(Icons.check_circle, size: 14, color: Colors.green.shade400),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${collector.completedCount} hoàn thành',
                                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF10B981),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.check, color: Colors.white, size: 16),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: selectedCollectorId != null
                            ? () {
                                Navigator.pop(sheetContext);
                                _acceptReportWithAssignment(report, selectedCollectorId);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Xác nhận phân công',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showImageDialog(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;
    final fullUrl = ApiConfig.getFullImageUrl(imageUrl);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    fullUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 300,
                      height: 300,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getWasteTypeColor(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('organic') || lowerType.contains('rác hữu cơ')) {
      return const Color(0xFF22C55E); // Green
    } else if (lowerType.contains('plastic') || lowerType.contains('nhựa')) {
      return const Color(0xFF3B82F6); // Blue
    } else if (lowerType.contains('paper') || lowerType.contains('giấy')) {
      return const Color(0xFFF59E0B); // Amber
    } else if (lowerType.contains('metal') || lowerType.contains('kim loại')) {
      return const Color(0xFF6B7280); // Gray
    } else if (lowerType.contains('glass') || lowerType.contains('thủy tinh')) {
      return const Color(0xFF14B8A6); // Teal
    } else if (lowerType.contains('electronic') || lowerType.contains('điện tử')) {
      return const Color(0xFF8B5CF6); // Purple
    } else if (lowerType.contains('hazardous') || lowerType.contains('nguy hại')) {
      return const Color(0xFFEF4444); // Red
    }
    return const Color(0xFF64748B); // Default slate
  }

  Color _getWasteTypeBgColor(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('organic') || lowerType.contains('rác hữu cơ')) {
      return const Color(0xFFDCFCE7); // Green-100
    } else if (lowerType.contains('plastic') || lowerType.contains('nhựa')) {
      return const Color(0xFFDBEAFE); // Blue-100
    } else if (lowerType.contains('paper') || lowerType.contains('giấy')) {
      return const Color(0xFFFEF3C7); // Amber-100
    } else if (lowerType.contains('metal') || lowerType.contains('kim loại')) {
      return const Color(0xFFF3F4F6); // Gray-100
    } else if (lowerType.contains('glass') || lowerType.contains('thủy tinh')) {
      return const Color(0xFFCCFBF1); // Teal-100
    } else if (lowerType.contains('electronic') || lowerType.contains('điện tử')) {
      return const Color(0xFFEDE9FE); // Purple-100
    } else if (lowerType.contains('hazardous') || lowerType.contains('nguy hại')) {
      return const Color(0xFFFEE2E2); // Red-100
    }
    return const Color(0xFFF1F5F9); // Default gray
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildFilters(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            '${_filteredReports.length} báo cáo',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Làm mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final isSelected = _statusFilter == filter;
          return FilterChip(
            label: Text(_getStatusLabel(filter)),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _statusFilter = selected ? filter : 'Tất cả';
              });
            },
            selectedColor: const Color(0xFF10B981).withOpacity(0.2),
            checkmarkColor: const Color(0xFF10B981),
            labelStyle: TextStyle(
              color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade300,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return _buildTableView(constraints);
        } else {
          return _buildMobileCardList();
        }
      },
    );
  }

  Widget _buildTableView(BoxConstraints constraints) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth > 0 ? constraints.maxWidth - 32 : 900,
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF1E293B)),
                dataRowMinHeight: 64,
                dataRowMaxHeight: 64,
                columnSpacing: 24,
                horizontalMargin: 20,
                dividerThickness: 1,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Mã',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Hình ảnh',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Người gửi',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Loại rác',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Ngày tạo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Nhân viên',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Trạng thái',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Hành động',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                rows: _filteredReports.isEmpty
                    ? [_buildEmptyTableRow()]
                    : _filteredReports.map((report) => _buildDataRow(report)).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildEmptyTableRow() {
    return DataRow(
      color: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
      cells: [
        DataCell.empty,
        DataCell.empty,
        DataCell.empty,
        DataCell.empty,
        DataCell.empty,
        DataCell.empty,
        DataCell.empty,
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_outlined,
                size: 32,
                color: const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 8),
              Text(
                'Chưa có dữ liệu',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildDataRow(EnterpriseReport report) {
    return DataRow(
      cells: [
        DataCell(Text(
          '#${report.reportId}',
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
          ),
        )),
        DataCell(_buildImageThumbnailWeb(report.imageUrl)),
        DataCell(
          SizedBox(
            width: 110,
            child: Text(
              report.submittedByName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 130,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: report.wasteTypeNames.take(2).map((type) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getWasteTypeBgColor(type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _getWasteTypeColor(type),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        DataCell(Text(
          report.createdAt != null ? _formatDate(report.createdAt!) : '-',
          style: const TextStyle(fontSize: 13),
        )),
        DataCell(_buildCollectorCell(report)),
        DataCell(_StatusBadge(status: report.status)),
        DataCell(_buildActionButtons(report)),
      ],
    );
  }

  Widget _buildImageThumbnailWeb(String? imageUrl) {
    final fullUrl = ApiConfig.getFullImageUrl(imageUrl);
    
    if (!ApiConfig.isValidImageUrl(imageUrl)) {
      return Container(
        width: 60,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: 20),
      );
    }
    return GestureDetector(
      onTap: () => _showImageDialog(fullUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          fullUrl,
          width: 60,
          height: 42,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 60,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            width: 60,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildCollectorCell(EnterpriseReport report) {
    if (report.assignedCollectorName == null || report.assignedCollectorName!.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 14, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(
              'Chưa phân công',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
          child: Text(
            report.assignedCollectorName!.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          report.assignedCollectorName!,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActionButtons(EnterpriseReport report) {
    if (report.status != 'Pending') {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => _rejectReport(report),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFDC2626),
            backgroundColor: const Color(0xFFFEF2F2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Từ chối', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _showAssignDialog(report),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Chấp nhận', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildMobileCardList() {
    return Column(
      children: [
        if (_filteredReports.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có dữ liệu',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredReports.length,
              itemBuilder: (context, index) {
                final report = _filteredReports[index];
                return _ReportCardMobile(
                  report: report,
                  onAccept: () => _showAssignDialog(report),
                  onReject: () => _rejectReport(report),
                  onImageTap: () => _showImageDialog(report.imageUrl),
                  getWasteTypeBgColor: _getWasteTypeBgColor,
                  getWasteTypeColor: _getWasteTypeColor,
                );
              },
            ),
          ),
      ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ReportCardMobile extends StatelessWidget {
  final EnterpriseReport report;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onImageTap;
  final Color Function(String) getWasteTypeBgColor;
  final Color Function(String) getWasteTypeColor;

  const _ReportCardMobile({
    required this.report,
    required this.onAccept,
    required this.onReject,
    required this.onImageTap,
    required this.getWasteTypeBgColor,
    required this.getWasteTypeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardImage(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#${report.reportId}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const Spacer(),
                          _StatusBadge(status: report.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.description ?? 'Báo cáo rác thải',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              report.submittedByName,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (report.wasteTypeNames.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: report.wasteTypeNames.take(2).map((type) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: getWasteTypeBgColor(type),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: getWasteTypeColor(type),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (report.status == 'Pending') ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        backgroundColor: const Color(0xFFFEF2F2),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Từ chối', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Chấp nhận',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardImage() {
    final fullUrl = ApiConfig.getFullImageUrl(report.imageUrl);
    
    if (!ApiConfig.isValidImageUrl(report.imageUrl)) {
      return Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: 28),
      );
    }
    return GestureDetector(
      onTap: onImageTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          fullUrl,
          width: 76,
          height: 76,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: 28),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'collected':
        return const Color(0xFF3B82F6);
      default:
        return Colors.grey;
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
}
