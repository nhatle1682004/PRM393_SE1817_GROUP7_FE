import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';

class CollectionProgressView extends StatefulWidget {
  final int requestId;
  final VoidCallback onRefresh;

  const CollectionProgressView({
    super.key,
    required this.requestId,
    required this.onRefresh,
  });

  @override
  State<CollectionProgressView> createState() => _CollectionProgressViewState();
}

class _CollectionProgressViewState extends State<CollectionProgressView> {
  CollectionRequestDetail? _detail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final detail = await EnterpriseApiService.getCollectionRequestById(widget.requestId);
      if (mounted) {
        setState(() {
          _detail = detail;
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Tiến độ xử lý #${widget.requestId}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadDetail,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : _error != null
              ? _buildErrorState()
              : isDesktop
                  ? _buildDesktopLayout()
                  : _buildMobileLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildTimeline(),
          ),
        ),
        VerticalDivider(width: 1, color: Colors.grey.shade200),
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRequestOverview(),
                const SizedBox(height: 24),
                _buildAiAnalysis(),
                const SizedBox(height: 24),
                _buildProofGallery(),
                const SizedBox(height: 24),
                _buildWeightsSummary(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequestOverview(),
          const SizedBox(height: 20),
          _buildAiAnalysis(),
          const SizedBox(height: 20),
          _buildTimeline(),
          const SizedBox(height: 20),
          _buildProofGallery(),
          const SizedBox(height: 20),
          _buildWeightsSummary(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildAiAnalysis() {
    if (_detail?.report?.aiPredictions == null || _detail!.report!.aiPredictions.isEmpty) {
      return const SizedBox();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology_outlined, color: Color(0xFF3B82F6), size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phân tích AI',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Gợi ý từ hệ thống dựa trên hình ảnh báo cáo',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ..._detail!.report!.aiPredictions.map((prediction) {
              final double confidence = prediction.confidence ?? 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          prediction.suggestedType ?? 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Text(
                          '${(confidence).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: confidence > 80 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: confidence / 100,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: confidence > 80 ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestOverview() {
    if (_detail == null) return const SizedBox();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: Color(0xFF10B981), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin chung',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Trạng thái: ${_getStatusLabel(_detail!.status ?? "")}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow(Icons.person_outline, 'Người báo cáo', _detail!.report?.citizenName ?? 'N/A'),
            _buildDetailRow(Icons.delete_outline, 'Loại rác', _detail!.report?.wasteTypeNames.join(', ') ?? 'N/A'),
            _buildDetailRow(Icons.location_on_outlined, 'Vị trí', _detail!.report?.location ?? 'N/A'),
            _buildDetailRow(Icons.calendar_today_outlined, 'Thời gian gán', _formatDate(_detail!.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    if (_detail?.assignmentHistory == null || _detail!.assignmentHistory!.isEmpty) {
      return const Center(child: Text('Chưa có lịch sử xử lý'));
    }

    // Lấy assignment mới nhất (thường là cái đang active)
    final assignment = _detail!.assignmentHistory!.first;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 20),
          child: Text(
            'LUỒNG XỬ LÝ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 1),
          ),
        ),
        _buildTimelineStep(
          title: 'Đã gán nhân viên',
          subtitle: 'Nhân viên: ${assignment.collectorName}',
          time: assignment.assignedAt,
          isCompleted: assignment.assignedAt != null,
          isLast: false,
        ),
        _buildTimelineStep(
          title: 'Đang di chuyển',
          subtitle: assignment.startedAt != null ? 'Bắt đầu di chuyển tới điểm tập kết' : 'Chờ nhân viên xuất phát',
          time: assignment.startedAt,
          isCompleted: assignment.startedAt != null,
          isLast: false,
        ),
        _buildTimelineStep(
          title: 'Đã đến điểm tập kết',
          subtitle: assignment.arrivedAt != null ? 'Đã chụp ảnh xác nhận bãi rác' : 'Nhân viên đang trên đường',
          time: assignment.arrivedAt,
          isCompleted: assignment.arrivedAt != null,
          isLast: false,
        ),
        _buildTimelineStep(
          title: 'Hoàn thành thu gom',
          subtitle: assignment.completedAt != null ? 'Đã dọn dẹp và khai báo khối lượng' : 'Đang trong quá trình dọn dẹp',
          time: assignment.completedAt,
          isCompleted: assignment.completedAt != null,
          isLast: true,
          isError: assignment.status == 'ReportedIssue',
          errorTitle: 'Có sự cố phát sinh',
          errorSubtitle: assignment.status == 'ReportedIssue' ? 'Nhân viên đã báo cáo sự cố' : null,
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required DateTime? time,
    required bool isCompleted,
    required bool isLast,
    bool isError = false,
    String? errorTitle,
    String? errorSubtitle,
  }) {
    final color = isError ? Colors.red : (isCompleted ? const Color(0xFF10B981) : Colors.grey.shade300);
    final displayTitle = isError ? (errorTitle ?? title) : title;
    final displaySubtitle = isError ? (errorSubtitle ?? subtitle) : subtitle;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: isCompleted
                    ? Icon(isError ? Icons.priority_high_rounded : Icons.check_rounded, size: 14, color: color)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: color.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isError ? Colors.red : (isCompleted ? const Color(0xFF1E293B) : Colors.grey.shade500),
                        ),
                      ),
                    ),
                    if (time != null)
                      Text(
                        _formatTime(time),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                  ],
                ),
                Text(
                  displaySubtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofGallery() {
    if (_detail?.assignmentHistory == null || _detail!.assignmentHistory!.isEmpty) return const SizedBox();
    final assignment = _detail!.assignmentHistory!.first;

    if (assignment.beforeImageUrl == null && assignment.afterImageUrl == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'MINH CHỨNG HÌNH ẢNH',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 1),
          ),
        ),
        LayoutBuilder(builder: (context, constraints) {
          final double imgWidth = (constraints.maxWidth - 12) / 2;
          return Row(
            children: [
              if (assignment.beforeImageUrl != null)
                _buildImageItem('Ảnh khi đến', assignment.beforeImageUrl!, imgWidth),
              if (assignment.beforeImageUrl != null && assignment.afterImageUrl != null) const SizedBox(width: 12),
              if (assignment.afterImageUrl != null)
                _buildImageItem('Ảnh sau khi dọn', assignment.afterImageUrl!, imgWidth),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildImageItem(String label, String url, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: width,
          height: width * 0.75,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.network(
              ApiConfig.getFullImageUrl(url),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildWeightsSummary() {
    if (_detail?.assignmentHistory == null || _detail!.assignmentHistory!.isEmpty) return const SizedBox();
    final assignment = _detail!.assignmentHistory!.first;
    if (assignment.collectionDetails == null || assignment.collectionDetails!.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'KHỐI LƯỢNG THU GOM THỰC TẾ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 1),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              ...assignment.collectionDetails!.map((d) => _buildWeightRow(d)),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng khối lượng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      '${assignment.collectionDetails!.fold(0.0, (sum, item) => sum + item.actualWeight).toStringAsFixed(1)} kg',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightRow(CollectionDetailHistoryDto detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.scale_outlined, size: 16, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              detail.wasteTypeName ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Text(
            '${detail.actualWeight.toStringAsFixed(1)} kg',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
          const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Đã xảy ra lỗi: $_error', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadDetail, child: const Text('Thử lại')),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Chờ xử lý';
      case 'inprogress':
      case 'in_progress':
      case 'ontheway': return 'Đang thu gom';
      case 'arrived': return 'Đã đến hiện trường';
      case 'completed': return 'Hoàn thành';
      case 'cancelled': return 'Đã hủy';
      case 'issue': return 'Gặp sự cố';
      default: return status;
    }
  }
}
