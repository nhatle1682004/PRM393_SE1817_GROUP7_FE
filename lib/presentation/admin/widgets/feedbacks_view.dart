import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/admin_feedback.dart';
import 'package:waste_collection_management_system/services/admin_api_service.dart';

class FeedbacksView extends StatefulWidget {
  const FeedbacksView({super.key});

  @override
  State<FeedbacksView> createState() => _FeedbacksViewState();
}

class _FeedbacksViewState extends State<FeedbacksView> {
  List<AdminFeedback> _feedbacks = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedStatus = 'All';

  final List<String> _statuses = ['All', 'Pending', 'Resolved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final feedbacks = await AdminApiService.getAllFeedbacks();
      if (mounted) {
        setState(() {
          _feedbacks = feedbacks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<AdminFeedback> get _filteredFeedbacks {
    return _feedbacks.where((feedback) {
      final matchesSearch = feedback.feedbackId.toString().contains(_searchQuery) ||
          feedback.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          feedback.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == 'All' || feedback.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Column(
      children: [
        _buildToolbar(isMobile),
        Expanded(child: _buildContent(isMobile)),
      ],
    );
  }

  Widget _buildToolbar(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm phản hồi...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 10 : 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                isDense: true,
                items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedStatus = value);
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _loadFeedbacks,
            icon: const Icon(Icons.refresh),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFeedbacks,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_filteredFeedbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feedback_outlined, color: Colors.grey.shade400, size: 64),
            const SizedBox(height: 16),
            Text('Không tìm thấy phản hồi nào', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _filteredFeedbacks.length,
        itemBuilder: (context, index) => _buildFeedbackCard(_filteredFeedbacks[index]),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildFeedbacksTable(),
    );
  }

  Widget _buildFeedbacksTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 1, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 2, child: Text('Người gửi', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 2, child: Text('Nội dung', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 1, child: Text('Báo cáo', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 1, child: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 1, child: Text('Ngày tạo', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 1, child: Text('Hành động', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
              ],
            ),
          ),
          ..._filteredFeedbacks.map((feedback) => _buildFeedbackRow(feedback)),
        ],
      ),
    );
  }

  Widget _buildFeedbackRow(AdminFeedback feedback) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('#${feedback.feedbackId}', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFEC4899).withValues(alpha: 0.1),
                  child: Text(
                    feedback.userName.isNotEmpty ? feedback.userName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Color(0xFFEC4899), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(feedback.userName, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              feedback.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text('#${feedback.reportId}'),
          ),
          Expanded(
            flex: 1,
            child: _buildStatusChip(feedback.status),
          ),
          Expanded(
            flex: 1,
            child: Text(
              feedback.createdAt != null ? _formatDate(feedback.createdAt!) : '-',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (feedback.status == 'Pending') ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    color: const Color(0xFF10B981),
                    onPressed: () => _showResolveDialog(feedback),
                    tooltip: 'Xử lý',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, size: 20),
                    color: const Color(0xFFEF4444),
                    onPressed: () => _rejectFeedback(feedback),
                    tooltip: 'Từ chối',
                  ),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 20),
                    color: const Color(0xFF3B82F6),
                    onPressed: () => _showFeedbackDetail(feedback),
                    tooltip: 'Xem chi tiết',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(AdminFeedback feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: Text('#${feedback.feedbackId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(feedback.status),
              const Spacer(),
              Text(
                feedback.createdAt != null ? _formatDate(feedback.createdAt!) : '-',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFEC4899).withValues(alpha: 0.1),
                child: Text(
                  feedback.userName.isNotEmpty ? feedback.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Color(0xFFEC4899), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Text(feedback.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback.content,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.report, size: 12, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text('Báo cáo #${feedback.reportId}', style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              const Spacer(),
              if (feedback.status == 'Pending') ...[
                TextButton.icon(
                  onPressed: () => _showResolveDialog(feedback),
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Xử lý'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF10B981)),
                ),
                TextButton.icon(
                  onPressed: () => _rejectFeedback(feedback),
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Từ chối'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () => _showFeedbackDetail(feedback),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Chi tiết'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'resolved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xử lý';
      case 'resolved':
        return 'Đã xử lý';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFeedbackDetail(AdminFeedback feedback) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.feedback, color: Color(0xFFEC4899), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phản hồi #${feedback.feedbackId}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        _buildStatusChip(feedback.status),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Người gửi', feedback.userName),
              _buildDetailRow('Báo cáo liên quan', '#${feedback.reportId}'),
              _buildDetailRow('Ngày tạo', feedback.createdAt != null ? _formatDate(feedback.createdAt!) : '-'),
              if (feedback.resolvedAt != null)
                _buildDetailRow('Ngày xử lý', _formatDate(feedback.resolvedAt!)),
              if (feedback.resolution != null)
                _buildDetailRow('Kết quả xử lý', feedback.resolution!),
              const SizedBox(height: 16),
              const Text('Nội dung:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(feedback.content, style: TextStyle(color: Colors.grey.shade700)),
              ),
              if (feedback.imageUrl != null && feedback.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Hình ảnh:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      feedback.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showResolveDialog(AdminFeedback feedback) {
    final resolutionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xử lý phản hồi'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phản hồi #${feedback.feedbackId} từ: ${feedback.userName}', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(feedback.content),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resolutionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Nội dung xử lý',
                  hintText: 'Nhập kết quả xử lý...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              try {
                await AdminApiService.resolveFeedback(
                  feedback.feedbackId,
                  ResolveFeedbackRequest(resolution: resolutionController.text),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadFeedbacks();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xử lý phản hồi')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectFeedback(AdminFeedback feedback) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối phản hồi'),
        content: Text('Bạn có chắc muốn từ chối phản hồi #${feedback.feedbackId}?'),
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

    if (confirmed == true) {
      try {
        await AdminApiService.rejectFeedback(feedback.feedbackId);
        _loadFeedbacks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã từ chối phản hồi')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e')),
          );
        }
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
