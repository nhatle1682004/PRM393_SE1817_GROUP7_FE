import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/collector_api_service.dart';

class CollectionHistoryView extends StatefulWidget {
  const CollectionHistoryView({super.key});

  @override
  State<CollectionHistoryView> createState() => _CollectionHistoryViewState();
}

class _CollectionHistoryViewState extends State<CollectionHistoryView> {
  List<EnterpriseAssignment> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final assignments = await CollectorApiService.getMyAssignments();
      final history = assignments.where(_isHistoryStatus).toList()
        ..sort((a, b) {
          final left = a.completedAt ?? a.assignedAt ?? DateTime(1970);
          final right = b.completedAt ?? b.assignedAt ?? DateTime(1970);
          return right.compareTo(left);
        });

      if (mounted) {
        setState(() {
          _history = history;
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

  bool _isHistoryStatus(EnterpriseAssignment assignment) {
    final status = assignment.status?.toLowerCase() ?? '';
    return status == 'completed' ||
        status == 'cancelled' ||
        status == 'reportedissue' ||
        status == 'issue';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 48),
            const SizedBox(height: 12),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_history.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadHistory,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            Icon(Icons.history_outlined, size: 64, color: Color(0xFFCBD5E1)),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Chưa có lịch sử thu gom',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: const Color(0xFF10B981),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) =>
            _HistoryCard(assignment: _history[index]),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final EnterpriseAssignment assignment;

  const _HistoryCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final status = assignment.status?.toLowerCase() ?? '';
    final isCompleted = status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
              Expanded(
                child: Text(
                  'Yêu cầu #${assignment.requestId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              _StatusChip(status: assignment.status ?? 'Completed'),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            Icons.delete_outline,
            assignment.wasteTypeName ?? 'Loại rác không xác định',
          ),
          const SizedBox(height: 6),
          _InfoRow(Icons.location_on_outlined, assignment.location),
          const SizedBox(height: 6),
          _InfoRow(Icons.person_outline, assignment.citizenName ?? 'Ẩn danh'),
          if (assignment.completedAt != null) ...[
            const SizedBox(height: 6),
            _InfoRow(
              Icons.event_available_outlined,
              _formatDateTime(assignment.completedAt!),
            ),
          ],
          if (isCompleted && assignment.totalCollectedWeight > 0) ...[
            const SizedBox(height: 10),
            Text(
              '${assignment.totalCollectedWeight.toStringAsFixed(1)} kg đã thu gom',
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if ((assignment.collectedWasteSummary ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              assignment.collectedWasteSummary!,
              style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
            ),
          ],
          if ((assignment.beforeImageUrl ?? '').isNotEmpty ||
              (assignment.afterImageUrl ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if ((assignment.beforeImageUrl ?? '').isNotEmpty)
                  Expanded(
                    child: _ProofImage(
                      title: 'Trước',
                      url: assignment.beforeImageUrl!,
                    ),
                  ),
                if ((assignment.beforeImageUrl ?? '').isNotEmpty &&
                    (assignment.afterImageUrl ?? '').isNotEmpty)
                  const SizedBox(width: 10),
                if ((assignment.afterImageUrl ?? '').isNotEmpty)
                  Expanded(
                    child: _ProofImage(
                      title: 'Sau',
                      url: assignment.afterImageUrl!,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year} $hour:$minute';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

class _ProofImage extends StatelessWidget {
  final String title;
  final String url;

  const _ProofImage({required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    final fullUrl = ApiConfig.getFullImageUrl(url);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              fullUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stackTrace) => Container(
                color: const Color(0xFFF1F5F9),
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'completed' => const Color(0xFF10B981),
      'cancelled' => const Color(0xFFEF4444),
      'reportedissue' || 'issue' => const Color(0xFFF59E0B),
      _ => const Color(0xFF64748B),
    };
    final label = switch (normalized) {
      'completed' => 'Hoàn thành',
      'cancelled' => 'Đã hủy',
      'reportedissue' || 'issue' => 'Có sự cố',
      _ => status,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
