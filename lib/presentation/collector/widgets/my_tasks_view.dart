import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/collector_api_service.dart';
import 'package:waste_collection_management_system/config/api_config.dart';

class MyTasksView extends StatefulWidget {
  const MyTasksView({super.key});

  @override
  State<MyTasksView> createState() => _MyTasksViewState();
}

class _MyTasksViewState extends State<MyTasksView> {
  List<EnterpriseAssignment> _assignments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tasks = await CollectorApiService.getMyAssignments();
      if (mounted) {
        setState(() {
          _assignments = tasks;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadTasks, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    if (_assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Bạn chưa có công việc nào được giao.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _assignments.length,
        itemBuilder: (context, index) {
          final assignment = _assignments[index];
          return _TaskCard(
            assignment: assignment,
            onUpdate: _loadTasks,
          );
        },
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final EnterpriseAssignment assignment;
  final VoidCallback onUpdate;

  const _TaskCard({required this.assignment, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final status = assignment.status?.toLowerCase() ?? 'assigned';
    final bool isCompleted = status == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${assignment.assignmentId}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePreview(assignment.reportImageUrl),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.wasteTypeName ?? 'Loại rác không xác định',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      _IconLabel(Icons.location_on_outlined, assignment.location, color: Colors.redAccent),
                      const SizedBox(height: 4),
                      _IconLabel(Icons.person_outline, assignment.citizenName ?? 'Ẩn danh'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            if (!isCompleted) _buildActionButtons(context, status),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String? imageUrl) {
    final fullUrl = ApiConfig.getFullImageUrl(imageUrl);
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: (imageUrl != null && imageUrl.isNotEmpty)
            ? Image.network(fullUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey))
            : const Icon(Icons.image_outlined, color: Colors.grey),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String status) {
    switch (status) {
      case 'assigned':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _handleDecline(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Từ chối'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleStart(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Bắt đầu đi'),
              ),
            ),
          ],
        );
      case 'ontheway':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _handleArrived(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Đã đến nơi'),
          ),
        );
      case 'arrived':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _handleComplete(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Hoàn thành'),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _handleStart(BuildContext context) async {
    try {
      await CollectorApiService.startCollection(assignment.assignmentId);
      onUpdate();
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _handleArrived(BuildContext context) async {
    try {
      await CollectorApiService.confirmArrival(assignment.assignmentId);
      onUpdate();
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _handleComplete(BuildContext context) async {
    try {
      await CollectorApiService.completeCollection(assignment.assignmentId);
      onUpdate();
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  Future<void> _handleDecline(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lý do từ chối'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nhập lý do...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Xác nhận')),
        ],
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      try {
        await CollectorApiService.declineAssignment(assignment.assignmentId, reason);
        onUpdate();
      } catch (e) {
        _showError(context, e.toString());
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $message'), backgroundColor: Colors.red));
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'assigned':
        color = Colors.orange;
        label = 'Mới gán';
        break;
      case 'ontheway':
        color = Colors.blue;
        label = 'Đang đi';
        break;
      case 'arrived':
        color = Colors.teal;
        label = 'Đã đến';
        break;
      case 'completed':
        color = const Color(0xFF10B981);
        label = 'Hoàn thành';
        break;
      case 'declined':
        color = Colors.red;
        label = 'Đã từ chối';
        break;
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _IconLabel(this.icon, this.label, {this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Colors.grey),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
