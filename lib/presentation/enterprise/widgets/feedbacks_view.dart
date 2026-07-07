import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';

class FeedbacksView extends StatefulWidget {
  const FeedbacksView({super.key});

  @override
  State<FeedbacksView> createState() => _FeedbacksViewState();
}

class _FeedbacksViewState extends State<FeedbacksView> {
  List<EnterpriseFeedback> _feedbacks = [];
  bool _isLoading = true;
  String? _error;
  String _statusFilter = 'Tất cả';
  final List<String> _statusFilters = ['Tất cả', 'Pending', 'Resolved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final feedbacks = await EnterpriseApiService.getFeedbacks();
      if (mounted) {
        setState(() {
          _feedbacks = feedbacks;
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

  List<EnterpriseFeedback> get _filteredFeedbacks {
    if (_statusFilter == 'Tất cả') return _feedbacks;
    return _feedbacks.where((f) => f.status == _statusFilter).toList();
  }

  Future<void> _resolveFeedback(EnterpriseFeedback feedback) async {
    String? selectedAction;
    final noteController = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Xử lý phản hồi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phản hồi #${feedback.feedbackId} từ: ${feedback.userName ?? 'N/A'}'),
              const SizedBox(height: 16),
              const Text(
                'Chọn hành động:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ActionChip(
                      label: 'Cảnh cáo',
                      icon: Icons.warning_amber,
                      isSelected: selectedAction == 'warn',
                      onTap: () => setDialogState(() => selectedAction = 'warn'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionChip(
                      label: 'Chỉ định lại',
                      icon: Icons.replay,
                      isSelected: selectedAction == 'reassign',
                      onTap: () => setDialogState(() => selectedAction = 'reassign'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: selectedAction == null
                  ? null
                  : () => Navigator.pop(context, {
                        'action': selectedAction!,
                        'note': noteController.text,
                      }),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );

    noteController.dispose();

    if (result != null) {
      try {
        await EnterpriseApiService.resolveFeedback(
          feedback.feedbackId,
          ResolveFeedbackRequest(
            action: result['action']!,
            adminNote: result['note'] ?? '',
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['action'] == 'warn'
                    ? 'Đã cảnh cáo nhân viên thu gom'
                    : 'Đã chỉ định lại và cảnh cáo',
              ),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          _loadFeedbacks();
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

  Future<void> _rejectFeedback(EnterpriseFeedback feedback) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Từ chối phản hồi'),
        content: Text('Từ chối phản hồi #${feedback.feedbackId}?'),
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
        await EnterpriseApiService.rejectFeedback(feedback.feedbackId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã từ chối phản hồi'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          _loadFeedbacks();
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_filteredFeedbacks.length} phản hồi',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _loadFeedbacks,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Làm mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_statusFilters.length, (index) {
            final filter = _statusFilters[index];
            final isSelected = _statusFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_getStatusLabel(filter)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _statusFilter = selected ? filter : 'Tất cả';
                  });
                },
                selectedColor: const Color(0xFF10B981).withOpacity(0.15),
                checkmarkColor: const Color(0xFF10B981),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF10B981) : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            );
          }),
        ),
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

    if (_filteredFeedbacks.isEmpty) {
      return _buildEmptyState();
    }

    return _buildFeedbacksList();
  }

  Widget _buildFeedbacksList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredFeedbacks.length,
      itemBuilder: (context, index) {
        final feedback = _filteredFeedbacks[index];
        return _FeedbackCard(
          feedback: feedback,
          onResolve: () => _resolveFeedback(feedback),
          onReject: () => _rejectFeedback(feedback),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Đã xảy ra lỗi',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error ?? 'Không thể tải dữ liệu',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadFeedbacks,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.feedback_outlined,
              size: 48,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Không có phản hồi nào',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Danh sách phản hồi sẽ hiển thị tại đây',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Pending':
        return 'Chờ xử lý';
      case 'Resolved':
        return 'Đã xử lý';
      case 'Rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final EnterpriseFeedback feedback;
  final VoidCallback onResolve;
  final VoidCallback onReject;

  const _FeedbackCard({
    required this.feedback,
    required this.onResolve,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 400;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            if (isMobile)
              _buildMobileHeader()
            else
              _buildDesktopHeader(),
            const SizedBox(height: 16),

            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                feedback.content,
                style: const TextStyle(fontSize: 14),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Resolution
            if (feedback.resolution != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: const Color(0xFF10B981)),
                        const SizedBox(width: 6),
                        Text(
                          'Đã xử lý',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feedback.resolution!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Timestamp
            if (feedback.createdAt != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _formatDate(feedback.createdAt!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // Action Buttons
            if (feedback.status == 'Pending') ...[
              const SizedBox(height: 16),
              _buildActionButtons(isMobile),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getStatusColor(feedback.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.feedback,
            color: _getStatusColor(feedback.status),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phản hồi #${feedback.feedbackId}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                feedback.userName ?? 'N/A',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Flexible(child: _StatusBadge(status: feedback.status)),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor(feedback.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.feedback,
                color: _getStatusColor(feedback.status),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feedback.userName ?? 'N/A',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _StatusBadge(status: feedback.status),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Phản hồi #${feedback.feedbackId}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onResolve,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Xử lý'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Từ chối'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onReject,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Từ chối'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onResolve,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xử lý'),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _getLabel(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return 'Đã xử lý';
      case 'pending':
        return 'Chờ xử lý';
      case 'rejected':
        return 'Từ chối';
      default:
        return status;
    }
  }
}
