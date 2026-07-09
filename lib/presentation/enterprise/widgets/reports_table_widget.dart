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
  // map: reportId -> actionStep (0: mặc định, 1: hiện form từ chối, 2: hỏi phân công)
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EAE8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: const Color(0xFFEDF2F0),
              ),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF0F7F4)),
                dataRowMaxHeight: 70,
                headingRowHeight: 56,
                horizontalMargin: 24,
                columnSpacing: 24,
                showCheckboxColumn: false,
                columns: [
                  const DataColumn(label: Center(child: Text('STT', style: _headerStyle))),
                  const DataColumn(label: Center(child: Text('Ảnh', style: _headerStyle))),
                  const DataColumn(label: Text('Loại rác', style: _headerStyle)),
                  const DataColumn(label: Text('Người báo cáo', style: _headerStyle)),
                  const DataColumn(label: Center(child: Text('Thời gian', style: _headerStyle))),
                  const DataColumn(label: Center(child: Text('Trạng thái', style: _headerStyle))),
                  const DataColumn(label: Text('Hành động', style: _headerStyle)),
                ],
                rows: widget.reports.map((report) => _buildDataRow(report)).toList(),
              ),
            ),
          ),
          
          // Pagination Section
          _buildPaginationBar(),
        ],
      ),
    );
  }

  DataRow _buildDataRow(EnterpriseReport report) {
    final int step = _actionSteps[report.reportId] ?? 0;
    final bool isPending = report.status == 'Pending';

    return DataRow(
      onSelectChanged: (_) {}, // Enable hover effect
      color: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered)) return const Color(0xFFF2FBF7);
        return null;
      }),
      cells: [
        DataCell(Center(child: Text('#${report.reportId}', style: const TextStyle(color: Color(0xFF595959), fontSize: 13)))),
        DataCell(Center(child: _buildImagePreview(report.imageUrl))),
        DataCell(ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Text(
            report.wasteTypeNames.join(', '),
            style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF0D2B1E)),
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            report.submittedByName,
            style: const TextStyle(color: Color(0xFF434343)),
            overflow: TextOverflow.ellipsis,
          ),
        )),
        DataCell(Center(child: Text(_formatDate(report.createdAt), style: const TextStyle(fontSize: 13, color: Color(0xFF8C8C8C))))),
        DataCell(Center(child: _buildStatusTag(report.status))),
        DataCell(_buildActionCell(report, step, isPending)),
      ],
    );
  }

  Widget _buildActionCell(EnterpriseReport report, int step, bool isPending) {
    if (!isPending) {
      return const Text('-', style: TextStyle(color: Color(0xFFBFBFBF)));
    }

    // Step 1: Default Buttons
    if (step == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => _setStep(report.reportId, 1),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFE1251B)),
            child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _setStep(report.reportId, 2),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B074),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Duyệt', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      );
    }

    // Step 2A: Rejection Form
    if (step == 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 140,
            height: 36,
            child: TextField(
              controller: _rejectControllers[report.reportId],
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Lý do từ chối...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE1251B)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.check_circle, color: Color(0xFFE1251B)),
            onPressed: () {
              final reason = _rejectControllers[report.reportId]?.text ?? '';
              widget.onReject(report.reportId, reason);
              _setStep(report.reportId, 0);
            },
            tooltip: 'Xác nhận từ chối',
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.grey),
            onPressed: () => _setStep(report.reportId, 0),
            tooltip: 'Hủy',
          ),
        ],
      );
    }

    // Step 2B: Assignment Choice
    if (step == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Phân công ngay?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00B074))),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              widget.onAccept(report.reportId, null);
              _setStep(report.reportId, 0);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Hủy', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: () => _showAssignmentDialog(report),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B074),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Phân công', style: TextStyle(fontSize: 12)),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _showAssignmentDialog(EnterpriseReport report) {
    int? selectedCollectorId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.assignment_ind, color: Color(0xFF00B074)),
            const SizedBox(width: 12),
            const Text('Phân công thu gom', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _dialogInfoRow('Người báo cáo:', report.submittedByName),
                  const SizedBox(height: 4),
                  _dialogInfoRow('Loại rác:', report.wasteTypeNames.join(', ')),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Chọn nhân viên thu gom:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              hint: const Text('Chọn nhân viên'),
              items: widget.collectors.map((c) => DropdownMenuItem(
                value: c.collectorId,
                child: Text(c.fullName ?? 'Collector #${c.collectorId}'),
              )).toList(),
              onChanged: (val) => selectedCollectorId = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy bỏ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedCollectorId != null) {
                widget.onAccept(report.reportId, selectedCollectorId);
                Navigator.pop(context);
                _setStep(report.reportId, 0);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B074),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xác nhận gán'),
          ),
        ],
      ),
    );
  }

  Widget _dialogInfoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D2B1E)), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildPaginationBar() {
    final int startItem = (widget.currentPage - 1) * widget.itemsPerPage + 1;
    final int endItem = (startItem + widget.reports.length - 1).clamp(0, widget.totalItems);
    final int totalPages = (widget.totalItems / widget.itemsPerPage).ceil();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEDF2F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Hiển thị $startItem-$endItem trên tổng số ${widget.totalItems} mục',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(width: 24),
          _paginationButton(
            icon: Icons.chevron_left,
            onPressed: widget.currentPage > 1 ? () => widget.onPageChanged(widget.currentPage - 1) : null,
          ),
          const SizedBox(width: 8),
          _paginationButton(
            icon: Icons.chevron_right,
            onPressed: widget.currentPage < totalPages ? () => widget.onPageChanged(widget.currentPage + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _paginationButton({required IconData icon, VoidCallback? onPressed}) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: onPressed == null ? Colors.grey.shade300 : const Color(0xFF00B074),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildImagePreview(String? url) {
    final fullUrl = ApiConfig.getFullImageUrl(url);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFEDF2F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: fullUrl.isNotEmpty
            ? Image.network(
                fullUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 20, color: Color(0xFFBFBFBF)),
              )
            : const Icon(Icons.image, size: 20, color: Color(0xFFBFBFBF)),
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color textColor;
    Color bgColor;
    Color borderColor;
    String label = _getStatusLabel(status);

    switch (status) {
      case 'Pending':
        textColor = const Color(0xFFD46B08);
        bgColor = const Color(0xFFFFF7E6);
        borderColor = const Color(0xFFFFD591);
        break;
      case 'Accepted':
      case 'Collected':
        textColor = const Color(0xFF00B074);
        bgColor = const Color(0xFFE6F9F0);
        borderColor = const Color(0xFFB3F2D4);
        break;
      case 'Rejected':
        textColor = const Color(0xFFE1251B);
        bgColor = const Color(0xFFFFF1F0);
        borderColor = const Color(0xFFFFA39E);
        break;
      default:
        textColor = Colors.grey;
        bgColor = Colors.grey.shade100;
        borderColor = Colors.grey.shade300;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Pending': return 'Chờ duyệt';
      case 'Accepted': return 'Đã duyệt';
      case 'Rejected': return 'Từ chối';
      case 'Collected': return 'Đã thu gom';
      default: return status;
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
