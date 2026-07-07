import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';

class AssignmentsView extends StatefulWidget {
  const AssignmentsView({super.key});

  @override
  State<AssignmentsView> createState() => _AssignmentsViewState();
}

class _AssignmentsViewState extends State<AssignmentsView> {
  List<EnterpriseAssignment> _assignments = [];
  bool _isLoading = true;
  String? _error;
  String _statusFilter = 'Tất cả';
  final List<String> _statusFilters = ['Tất cả', 'Pending', 'InProgress', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final assignments = await EnterpriseApiService.getAssignments();
      if (mounted) {
        setState(() {
          _assignments = assignments;
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

  List<EnterpriseAssignment> get _filteredAssignments {
    if (_statusFilter == 'Tất cả') return _assignments;
    return _assignments.where((a) => a.status == _statusFilter).toList();
  }

  Future<void> _cancelAssignment(EnterpriseAssignment assignment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy phân công'),
        content: Text(
          'Bạn có chắc muốn hủy phân công #${assignment.assignmentId}?',
        ),
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
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await EnterpriseApiService.cancelAssignment(assignment.assignmentId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã hủy phân công'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          _loadAssignments();
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
            '${_filteredAssignments.length} phân công',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _loadAssignments,
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

    if (_filteredAssignments.isEmpty) {
      return _buildEmptyState();
    }

    return _buildAssignmentsList();
  }

  Widget _buildAssignmentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredAssignments.length,
      itemBuilder: (context, index) {
        final assignment = _filteredAssignments[index];
        return _AssignmentCard(
          assignment: assignment,
          onCancel: () => _cancelAssignment(assignment),
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
            onPressed: _loadAssignments,
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
              Icons.assignment_outlined,
              size: 48,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Chưa có phân công nào',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Danh sách phân công sẽ hiển thị tại đây',
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
      case 'InProgress':
        return 'Đang thu gom';
      case 'Completed':
        return 'Hoàn thành';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}

class _AssignmentCard extends StatelessWidget {
  final EnterpriseAssignment assignment;
  final VoidCallback onCancel;

  const _AssignmentCard({
    required this.assignment,
    required this.onCancel,
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
            // Header
            if (isMobile)
              _buildMobileHeader()
            else
              _buildDesktopHeader(),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            
            // Info Grid
            if (isMobile)
              _buildMobileInfoGrid()
            else
              _buildDesktopInfoGrid(),
            
            // Timestamp
            if (assignment.assignedAt != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(
                    'Gán lúc: ${_formatDate(assignment.assignedAt!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ],
            
            // Cancel Button
            if (assignment.status?.toLowerCase() == 'pending') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel),
                  label: const Text('Hủy phân công'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
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
            color: _getStatusColor(assignment.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.assignment,
            color: _getStatusColor(assignment.status),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phân công #${assignment.assignmentId}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Yêu cầu #${assignment.requestId}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Flexible(child: _StatusBadge(status: assignment.status ?? 'Pending')),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(assignment.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.assignment,
            color: _getStatusColor(assignment.status),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'PC #${assignment.assignmentId}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(child: _StatusBadge(status: assignment.status ?? 'Pending')),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Yêu cầu #${assignment.requestId}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopInfoGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoSection(
                'Collector',
                assignment.collectorName ?? 'N/A',
                Icons.person,
              ),
            ),
            Expanded(
              child: _buildInfoSection(
                'Công dân',
                assignment.citizenName ?? 'N/A',
                Icons.badge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoSection(
                'Loại rác',
                assignment.wasteTypeName ?? 'N/A',
                Icons.delete_outline,
              ),
            ),
            Expanded(
              child: _buildInfoSection(
                'Vị trí',
                assignment.location,
                Icons.location_on,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileInfoGrid() {
    return Column(
      children: [
        _buildInfoRow(Icons.person, 'Collector', assignment.collectorName ?? 'N/A'),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.badge, 'Công dân', assignment.citizenName ?? 'N/A'),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.delete_outline, 'Loại rác', assignment.wasteTypeName ?? 'N/A'),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.location_on, 'Vị trí', assignment.location),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'inprogress':
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'cancelled':
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
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'inprogress':
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _getLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Hoàn thành';
      case 'pending':
        return 'Chờ xử lý';
      case 'inprogress':
      case 'in_progress':
        return 'Đang thu gom';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}
