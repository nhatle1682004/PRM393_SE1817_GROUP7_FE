import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/admin_feedback.dart';
import 'package:waste_collection_management_system/presentation/admin/widgets/pagination_controls.dart';
import 'package:waste_collection_management_system/services/admin_api_service.dart';

class FeedbacksView extends StatefulWidget {
  const FeedbacksView({super.key});

  @override
  State<FeedbacksView> createState() => _FeedbacksViewState();
}

class _FeedbacksViewState extends State<FeedbacksView> {
  List<AdminFeedback> _feedbacks = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  String _status = 'All';
  int _page = 0;
  static const int _pageSize = 10;

  final List<String> _statuses = ['All', 'Pending', 'Resolving', 'ResolveFailed', 'Resolved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  List<AdminFeedback> get _filtered {
    final query = _search.toLowerCase();
    return _feedbacks.where((item) {
      final matchesSearch = item.feedbackId.toString().contains(query) ||
          item.reportId.toString().contains(query) ||
          item.userName.toLowerCase().contains(query) ||
          item.content.toLowerCase().contains(query);
      final matchesStatus = _status == 'All' || item.status == _status;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<AdminFeedback> get _paged {
    final start = _page * _pageSize;
    if (start >= _filtered.length) return [];
    final end = start + _pageSize > _filtered.length ? _filtered.length : start + _pageSize;
    return _filtered.sublist(start, end);
  }

  Future<void> _loadFeedbacks() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final feedbacks = await AdminApiService.getAllFeedbacks();
      if (!mounted) return;
      setState(() {
        _feedbacks = feedbacks;
        _page = 0;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<AdminFeedback> _loadDetail(AdminFeedback feedback) async {
    try {
      return await AdminApiService.getFeedbackById(feedback.feedbackId);
    } catch (_) {
      return feedback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Column(
      children: [
        _toolbar(isMobile),
        Expanded(child: _content(isMobile)),
      ],
    );
  }

  Widget _toolbar(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() {
                _search = value;
                _page = 0;
              }),
              decoration: InputDecoration(
                hintText: 'Tìm phản hồi, report, người gửi...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _status,
            items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(s)))).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _status = value;
                _page = 0;
              });
            },
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: _loadFeedbacks, icon: const Icon(Icons.refresh), tooltip: 'Tải lại'),
        ],
      ),
    );
  }

  Widget _content(bool isMobile) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
    if (_error != null) return _errorView();
    if (_filtered.isEmpty) {
      return Center(child: Text('Không tìm thấy phản hồi nào', style: TextStyle(color: Colors.grey.shade600)));
    }

    if (isMobile) {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _paged.length,
              itemBuilder: (context, index) => _feedbackCard(_paged[index]),
            ),
          ),
          PaginationControls(
            currentPage: _page,
            totalItems: _filtered.length,
            pageSize: _pageSize,
            onPageChanged: (page) => setState(() => _page = page),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _feedbackTable(),
          ),
        ),
        PaginationControls(
          currentPage: _page,
          totalItems: _filtered.length,
          pageSize: _pageSize,
          onPageChanged: (page) => setState(() => _page = page),
        ),
      ],
    );
  }

  Widget _feedbackTable() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF8FAFC),
            child: const Row(
              children: [
                Expanded(child: Text('ID', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Người gửi', style: _headerStyle)),
                Expanded(flex: 2, child: Text('Nội dung', style: _headerStyle)),
                Expanded(child: Text('Report', style: _headerStyle)),
                Expanded(child: Text('Trạng thái', style: _headerStyle)),
                Expanded(child: Text('Ngày tạo', style: _headerStyle)),
                SizedBox(width: 140, child: Text('Hành động', style: _headerStyle)),
              ],
            ),
          ),
          ..._paged.map(_feedbackRow),
        ],
      ),
    );
  }

  Widget _feedbackRow(AdminFeedback feedback) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        children: [
          Expanded(child: Text('#${feedback.feedbackId}', style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(flex: 2, child: Text(feedback.userName, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(feedback.content, maxLines: 2, overflow: TextOverflow.ellipsis)),
          Expanded(child: Text('#${feedback.reportId}')),
          Expanded(child: _chip(_statusLabel(feedback.status), _statusColor(feedback.status))),
          Expanded(child: Text(feedback.createdAt == null ? '-' : _formatDate(feedback.createdAt!))),
          SizedBox(
            width: 140,
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Chi tiết',
                  icon: const Icon(Icons.visibility_outlined),
                  color: const Color(0xFF3B82F6),
                  onPressed: () => _showDetail(feedback),
                ),
                if (_canResolve(feedback))
                  IconButton(
                    tooltip: 'Xử lý',
                    icon: const Icon(Icons.rule),
                    color: const Color(0xFF10B981),
                    onPressed: () => _showResolveDialog(feedback),
                  ),
                if (_canResolve(feedback))
                  IconButton(
                    tooltip: 'Từ chối',
                    icon: const Icon(Icons.cancel_outlined),
                    color: const Color(0xFFEF4444),
                    onPressed: () => _rejectFeedback(feedback),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedbackCard(AdminFeedback feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('#${feedback.feedbackId}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              _chip(_statusLabel(feedback.status), _statusColor(feedback.status)),
              const Spacer(),
              Text(feedback.createdAt == null ? '-' : _formatDate(feedback.createdAt!), style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(feedback.userName, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(feedback.content, maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(
            children: [
              _smallBadge(Icons.report, 'Report #${feedback.reportId}'),
              const Spacer(),
              IconButton(onPressed: () => _showDetail(feedback), icon: const Icon(Icons.visibility_outlined), tooltip: 'Chi tiết'),
              if (_canResolve(feedback)) IconButton(onPressed: () => _showResolveDialog(feedback), icon: const Icon(Icons.rule), tooltip: 'Xử lý'),
              if (_canResolve(feedback)) IconButton(onPressed: () => _rejectFeedback(feedback), icon: const Icon(Icons.cancel_outlined), tooltip: 'Từ chối'),
            ],
          ),
        ],
      ),
    );
  }

  bool _canResolve(AdminFeedback feedback) {
    final status = feedback.status.toLowerCase();
    return status == 'pending' || status == 'resolvefailed';
  }

  Future<void> _showResolveDialog(AdminFeedback feedback) async {
    final detail = await _loadDetail(feedback);
    if (!mounted) return;

    String action = 'warn';
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Xử lý khiếu nại'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _flowSummary(detail),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'warn',
                        icon: Icon(Icons.warning_amber),
                        label: Text('Cảnh cáo'),
                      ),
                      ButtonSegment(
                        value: 'reassign',
                        icon: Icon(Icons.assignment_return),
                        label: Text('Giao lại'),
                      ),
                    ],
                    selected: {action},
                    onSelectionChanged: (value) => setDialogState(() => action = value.first),
                  ),
                  const SizedBox(height: 12),
                  _actionExplanation(action),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú xử lý',
                      hintText: 'Nhập lý do xử lý để gửi vào lịch sử và thông báo...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (noteController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập ghi chú xử lý')));
                  return;
                }

                try {
                  await AdminApiService.resolveFeedback(
                    feedback.feedbackId,
                    ResolveFeedbackRequest(action: action, adminNote: noteController.text.trim()),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    await _loadFeedbacks();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(action == 'warn' ? 'Đã cảnh cáo collector' : 'Đã chuyển yêu cầu về trạng thái cần giao lại')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: const Text('Xác nhận xử lý', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flowSummary(AdminFeedback detail) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ngữ cảnh xử lý', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _detailLine('Người gửi', detail.userName),
          _detailLine('Report', '#${detail.reportId} - ${detail.reportStatus ?? 'N/A'}'),
          _detailLine('Collector', detail.collectorName ?? 'Chưa có dữ liệu'),
          _detailLine('Cảnh cáo hiện tại', detail.collectorWarningCount == null ? 'Chưa có dữ liệu' : '${detail.collectorWarningCount}/4'),
          _detailLine('Enterprise', detail.enterpriseName ?? 'Chưa có dữ liệu'),
          if (detail.resolveFailureReason?.isNotEmpty == true) _detailLine('Lỗi xử lý trước', detail.resolveFailureReason!),
        ],
      ),
    );
  }

  Widget _actionExplanation(String action) {
    final isWarn = action == 'warn';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isWarn ? const Color(0xFFFFFBEB) : const Color(0xFFEFF6FF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isWarn
            ? 'Cảnh cáo: collector +1 warning, feedback thành Resolved, citizen +10 điểm, gửi thông báo cho citizen và collector.'
            : 'Giao lại: report quay về Accepted, assignment hiện tại bị hủy, collection request về Pending, collector +2 warning, citizen +10 điểm và có thể reverse điểm cũ.',
        style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
      ),
    );
  }

  Future<void> _rejectFeedback(AdminFeedback feedback) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối khiếu nại'),
        content: Text('Khiếu nại #${feedback.feedbackId} sẽ chuyển sang Rejected. Không cộng điểm và không phạt collector.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Từ chối', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AdminApiService.rejectFeedback(feedback.feedbackId);
      await _loadFeedbacks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối khiếu nại')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> _showDetail(AdminFeedback feedback) async {
    final detail = await _loadDetail(feedback);
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.feedback, color: Color(0xFF10B981), size: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Phản hồi #${detail.feedbackId}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                    _chip(_statusLabel(detail.status), _statusColor(detail.status)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 16),
                _section('Thông tin phản hồi', [
                  _detailLine('Người gửi', detail.userName),
                  _detailLine('Nội dung', detail.content),
                  _detailLine('Ngày tạo', detail.createdAt == null ? '-' : _formatDate(detail.createdAt!)),
                  if (detail.resolution?.isNotEmpty == true) _detailLine('Ghi chú xử lý', detail.resolution!),
                  if (detail.resolveFailureReason?.isNotEmpty == true) _detailLine('Lỗi xử lý', detail.resolveFailureReason!),
                ]),
                _section('Báo cáo và thu gom', [
                  _detailLine('Report', '#${detail.reportId}'),
                  _detailLine('Trạng thái report', detail.reportStatus ?? '-'),
                  _detailLine('Loại rác', detail.wasteTypeNames.isEmpty ? '-' : detail.wasteTypeNames.join(', ')),
                  _detailLine('Vị trí', detail.latitude == null || detail.longitude == null ? '-' : '${detail.latitude}, ${detail.longitude}'),
                  _detailLine('Assignment', detail.assignmentId == null ? '-' : '#${detail.assignmentId} - ${detail.assignmentStatus ?? 'N/A'}'),
                ]),
                _section('Collector và doanh nghiệp', [
                  _detailLine('Collector', detail.collectorName ?? '-'),
                  _detailLine('Warning', detail.collectorWarningCount == null ? '-' : '${detail.collectorWarningCount}/4'),
                  _detailLine('Enterprise', detail.enterpriseName ?? '-'),
                ]),
                if (detail.confirmationNote?.isNotEmpty == true)
                  _section('Xác nhận thu gom', [
                    _detailLine('Ghi chú', detail.confirmationNote!),
                  ]),
                _imageStrip(detail),
                const SizedBox(height: 16),
                if (_canResolve(detail))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _rejectFeedback(detail);
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Từ chối'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showResolveDialog(detail);
                        },
                        icon: const Icon(Icons.rule),
                        label: const Text('Xử lý'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Color(0xFF64748B)))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _imageStrip(AdminFeedback detail) {
    final images = <String, String?>{
      'Ảnh phản hồi': detail.imageUrl,
      'Ảnh report': detail.reportImageUrl,
      'Trước thu gom': detail.confirmationBeforeImageUrl ?? detail.beforeImageUrl,
      'Sau thu gom': detail.confirmationAfterImageUrl,
    }.entries.where((entry) => entry.value?.isNotEmpty == true).toList();

    if (images.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: images.map((entry) {
        final url = ApiConfig.getFullImageUrl(entry.value);
        return SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  url,
                  height: 110,
                  width: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 110,
                    color: const Color(0xFFE2E8F0),
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 48),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loadFeedbacks, child: const Text('Thử lại')),
        ],
      ),
    );
  }

  Widget _smallBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'resolving':
        return const Color(0xFF3B82F6);
      case 'resolvefailed':
        return const Color(0xFFEF4444);
      case 'resolved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'all':
        return 'Tất cả';
      case 'pending':
        return 'Chờ xử lý';
      case 'resolving':
        return 'Đang xử lý';
      case 'resolvefailed':
        return 'Xử lý lỗi';
      case 'resolved':
        return 'Đã xử lý';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

const _headerStyle = TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B));
