import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/config/api_config.dart';

class ReportsTableWidget extends StatefulWidget {
  final List<EnterpriseReport> reports;
  final List<EnterpriseCollector> collectors;
  final int totalItems;
  final int currentPage;
  final int itemsPerPage;
  final Function(int page) onPageChanged;
  final Function(int reportId, String reason) onReject;
  final Function(int reportId, int? collectorId) onAccept;
  final bool isLoading;

  const ReportsTableWidget({
    super.key,
    required this.reports,
    required this.collectors,
    required this.totalItems,
    required this.currentPage,
    this.itemsPerPage = 10,
    required this.onPageChanged,
    required this.onReject,
    required this.onAccept,
    this.isLoading = false,
  });

  @override
  State<ReportsTableWidget> createState() => _ReportsTableWidgetState();
}

class _ReportsTableWidgetState extends State<ReportsTableWidget> {
  // Quản lý trạng thái tương tác động tại cột Hành động cho từng dòng
  final Map<int, int> _actionSteps = {};
  final Map<int, TextEditingController> _rejectControllers = {};

  @override
  void dispose() {
    for (var controller in _rejectControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setStep(int reportId, int step) {
    setState(() {
      _actionSteps[reportId] = step;
      if (step == 1 && !_rejectControllers.containsKey(reportId)) {
        _rejectControllers[reportId] = TextEditingController();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Thẻ Card chứa bảng với thiết kế mới
            Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 2.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // Chống tràn ngang trên Mobile
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth - 4,
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF0FDF4),
                        ),
                        dataRowMaxHeight: 80,
                        headingRowHeight: 56,
                        horizontalMargin: 20,
                        columnSpacing: 24,
                        columns: const [
                          DataColumn(label: Text('STT', style: _headerStyle)),
                          DataColumn(
                            label: Text('Hình ảnh', style: _headerStyle),
                          ),
                          DataColumn(
                            label: Text('Loại rác', style: _headerStyle),
                          ),
                          DataColumn(
                            label: Text('Người báo cáo', style: _headerStyle),
                          ),
                          DataColumn(
                            label: Text('Thời gian', style: _headerStyle),
                          ),
                          DataColumn(
                            label: Text('Mức độ', style: _headerStyle),
                          ),
                          DataColumn(
                            label: Text('Trạng thái', style: _headerStyle),
                          ),
                          DataColumn(
                            label: Text('Hành động', style: _headerStyle),
                          ),
                        ],
                        rows: widget.reports.asMap().entries.map((entry) {
                          return _buildDataRow(entry.value, entry.key);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Thanh điều hướng phân trang mới (Căn giữa)
            _buildPaginationControls(),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  DataRow _buildDataRow(EnterpriseReport report, int index) {
    final int step = _actionSteps[report.reportId] ?? 0;
    // Đảm bảo so khớp trạng thái không phân biệt hoa thường để tránh lỗi UI
    final String statusLower = report.status.trim().toLowerCase();
    final bool isPending = statusLower == 'pending';
    final bool isAccepted = statusLower == 'accepted';
    final int displayStt =
        ((widget.currentPage - 1) * widget.itemsPerPage) + index + 1;

    // Lấy mức độ từ estimatedSize của BE
    String level = _mapEstimatedSize(report.estimatedSize);

    return DataRow(
      cells: [
        DataCell(
          Text(
            '#${report.reportId}',
            style: const TextStyle(color: Color(0xFF595959), fontSize: 13),
          ),
        ),
        DataCell(_buildImageCell(report.imageUrl)),
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              report.wasteTypeNames.join(', '),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF0D2B1E),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Text(
            report.submittedByName,
            style: const TextStyle(color: Color(0xFF434343)),
          ),
        ),
        DataCell(
          Text(
            _formatDate(report.createdAt),
            style: const TextStyle(fontSize: 13, color: Color(0xFF8C8C8C)),
          ),
        ),
        DataCell(_buildBadge(level, _getLevelColor(level))),
        DataCell(
          _buildBadge(
            _getStatusLabel(report.status),
            _getStatusColor(report.status),
          ),
        ),
        DataCell(_buildActionCell(report, step, isPending, isAccepted)),
      ],
    );
  }

  Widget _buildImageCell(String? imageUrl) {
    final fullUrl = ApiConfig.getFullImageUrl(imageUrl);
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: (imageUrl != null && imageUrl.isNotEmpty)
            ? Image.network(
                fullUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 24,
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              )
            : const Icon(Icons.image, color: Colors.grey, size: 24),
      ),
    );
  }

  String _mapEstimatedSize(String? size) {
    if (size == null || size.isEmpty) return 'N/A';
    switch (size.toUpperCase()) {
      case 'SMALL':
        return 'Thấp';
      case 'MEDIUM':
        return 'Trung bình';
      case 'LARGE':
      case 'HUGE':
        return 'Cao';
      default:
        return size;
    }
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Cao':
        return Colors.red;
      case 'Trung bình':
        return Colors.orange;
      case 'Thấp':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
      case 'Collected':
      case 'Đã duyệt':
        return const Color(0xFF10B981);
      case 'Rejected':
      case 'Từ chối':
        return Colors.red;
      case 'Pending':
      case 'Chờ duyệt':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPaginationControls() {
    final int totalPages = (widget.totalItems / widget.itemsPerPage).ceil();
    bool isFirstPage = widget.currentPage == 1;
    bool isLastPage = widget.currentPage == totalPages || totalPages == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNavButton(
          icon: Icons.chevron_left,
          isDisabled: isFirstPage,
          onTap: () => widget.onPageChanged(widget.currentPage - 1),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '${widget.currentPage}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildNavButton(
          icon: Icons.chevron_right,
          isDisabled: isLastPage,
          onTap: () => widget.onPageChanged(widget.currentPage + 1),
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Icon(icon, color: const Color(0xFF10B981)),
        ),
      ),
    );
  }

  Widget _buildActionCell(
    EnterpriseReport report,
    int step,
    bool isPending,
    bool isAccepted,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút Xem chi tiết với hình con mắt
          IconButton(
            icon: const Icon(
              Icons.visibility_outlined,
              color: Color(0xFF10B981),
              size: 22,
            ),
            onPressed: () => _showDetailDialog(report),
            tooltip: 'Xem chi tiết báo cáo',
          ),

          if (isPending) ...[
            if (step == 0) ...[
              TextButton(
                onPressed: () => _setStep(report.reportId, 1),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE1251B),
                ),
                child: const Text(
                  'Từ chối',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () => _setStep(report.reportId, 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B074),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Duyệt',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ] else if (step == 1) ...[
              SizedBox(
                width: 100,
                height: 32,
                child: TextField(
                  controller: _rejectControllers[report.reportId],
                  style: const TextStyle(fontSize: 11),
                  decoration: InputDecoration(
                    hintText: 'Lý do...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.check_circle,
                  color: Color(0xFFE1251B),
                  size: 20,
                ),
                onPressed: () {
                  widget.onReject(
                    report.reportId,
                    _rejectControllers[report.reportId]?.text ?? '',
                  );
                  _setStep(report.reportId, 0);
                },
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                onPressed: () => _setStep(report.reportId, 0),
              ),
            ] else if (step == 2) ...[
              const Text(
                'Gán NV?',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B074),
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onAccept(report.reportId, null);
                  _setStep(report.reportId, 0);
                },
                child: const Text('K', style: TextStyle(fontSize: 10)),
              ),
              ElevatedButton(
                onPressed: () => _showAssignmentDialog(report),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B074),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(30, 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('C', style: TextStyle(fontSize: 10)),
              ),
            ],
          ] else if (isAccepted) ...[
            if (report.assignedCollectorId == null)
              TextButton.icon(
                onPressed: () => _showAssignmentDialog(report),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Gán NV', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                ),
              )
            else
              TextButton.icon(
                onPressed: () => _showAssignmentDialog(report),
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: const Text('Đổi NV', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: Colors.orange),
              ),
          ] else
            const Text('-', style: TextStyle(color: Color(0xFFBFBFBF))),
        ],
      ),
    );
  }

  void _showDetailDialog(EnterpriseReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.visibility_outlined, color: Color(0xFF10B981)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Dữ liệu chi tiết báo cáo #${report.reportId}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (report.imageUrl != null && report.imageUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      ApiConfig.getFullImageUrl(report.imageUrl),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 250,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                            Text(
                              'Không thể tải hình ảnh',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const Text('THÔNG TIN HỆ THỐNG', style: _sectionHeaderStyle),
                const Divider(),
                _buildDetailRow('Report ID', report.reportId.toString()),
                _buildDetailRow(
                  'Request ID',
                  report.requestId?.toString() ?? 'N/A',
                ),
                _buildDetailRow('Trạng thái (Raw)', report.status),

                const SizedBox(height: 16),
                const Text('NỘI DUNG BÁO CÁO', style: _sectionHeaderStyle),
                const Divider(),
                _buildDetailRow('Loại rác', report.wasteTypeNames.join(', ')),
                _buildDetailRow('Người báo cáo', report.submittedByName),
                _buildDetailRow(
                  'Thời gian tạo',
                  _formatDateTime(report.createdAt),
                ),
                _buildDetailRow(
                  'Mức độ rác',
                  '${_mapEstimatedSize(report.estimatedSize)} (${report.estimatedSize ?? "N/A"})',
                ),
                _buildDetailRow(
                  'Mô tả',
                  report.description ?? 'Không có mô tả',
                ),

                const SizedBox(height: 16),
                const Text('VỊ TRÍ & PHÂN CÔNG', style: _sectionHeaderStyle),
                const Divider(),
                _buildDetailRow('Vĩ độ (Lat)', report.latitude.toString()),
                _buildDetailRow('Kinh độ (Long)', report.longitude.toString()),
                _buildDetailRow(
                  'Tọa độ Google Maps',
                  '${report.latitude},${report.longitude}',
                ),
                _buildDetailRow(
                  'Nhân viên phụ trách',
                  report.assignedCollectorName ?? 'Chưa phân công',
                ),
                _buildDetailRow(
                  'ID Nhân viên',
                  report.assignedCollectorId?.toString() ?? 'N/A',
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0D2B1E),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static const _sectionHeaderStyle = TextStyle(
    color: Color(0xFF10B981),
    fontWeight: FontWeight.bold,
    fontSize: 14,
    letterSpacing: 0.5,
  );

  void _showAssignmentDialog(EnterpriseReport report) {
    int? selectedCollectorId;
    final assignableCollectors = widget.collectors
        .where(
          (collector) => collector.collectorId != report.assignedCollectorId,
        )
        .toList();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Phân công thu gom',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (report.assignedCollectorName != null &&
                report.assignedCollectorName!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                    children: [
                      const TextSpan(text: 'Nhân viên hiện tại: '),
                      TextSpan(
                        text: report.assignedCollectorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (assignableCollectors.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Hiá»‡n khÃ´ng cÃ³ nhÃ¢n viÃªn nÃ o sáºµn sÃ ng Ä‘á»ƒ gÃ¡n viá»‡c.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelText: 'Chọn nhân viên',
              ),
              items: assignableCollectors
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.collectorId,
                      child: Text(c.fullName ?? 'Nhân viên #${c.collectorId}'),
                    ),
                  )
                  .toList(),
              onChanged: assignableCollectors.isEmpty
                  ? null
                  : (val) => selectedCollectorId = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: assignableCollectors.isEmpty
                ? null
                : () {
                    if (selectedCollectorId != null) {
                      widget.onAccept(report.reportId, selectedCollectorId);
                      Navigator.pop(context);
                      _setStep(report.reportId, 0);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B074),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
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

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  static const _headerStyle = TextStyle(
    fontWeight: FontWeight.w700,
    color: Color(0xFF0D2B1E),
    fontSize: 14,
  );
}
