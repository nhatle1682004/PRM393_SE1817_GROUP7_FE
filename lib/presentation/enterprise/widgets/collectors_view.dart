import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';

class CollectorsView extends StatefulWidget {
  const CollectorsView({super.key});

  @override
  State<CollectorsView> createState() => _CollectorsViewState();
}

class _CollectorsViewState extends State<CollectorsView> {
  List<EnterpriseCollector> _collectors = [];
  bool _isLoading = true;
  String? _error;
  int? _selectedCollectorId;

  @override
  void initState() {
    super.initState();
    _loadCollectors();
  }

  Future<void> _loadCollectors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final collectors = await EnterpriseApiService.getCollectors();
      if (mounted) {
        setState(() {
          _collectors = collectors;
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

  Future<void> _toggleAvailability(EnterpriseCollector collector) async {
    try {
      await EnterpriseApiService.updateCollectorAvailability(
        collector.collectorId,
        !collector.isAvailable,
      );
      _loadCollectors();
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
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
            '${_collectors.length} nhân viên',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _loadCollectors,
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

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_collectors.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCollectorsList();
  }

  Widget _buildCollectorsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _collectors.length,
      itemBuilder: (context, index) {
        final collector = _collectors[index];
        return _CollectorCard(
          collector: collector,
          isSelected: _selectedCollectorId == collector.collectorId,
          onTap: () {
            setState(() {
              _selectedCollectorId = _selectedCollectorId == collector.collectorId
                  ? null
                  : collector.collectorId;
            });
          },
          onToggleAvailability: () => _toggleAvailability(collector),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Lỗi không xác định',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCollectors,
            child: const Text('Thử lại'),
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
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Chưa có nhân viên nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectorCard extends StatelessWidget {
  final EnterpriseCollector collector;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleAvailability;

  const _CollectorCard({
    required this.collector,
    required this.isSelected,
    required this.onTap,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collector.fullName ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (collector.email != null)
                          Text(
                            collector.email!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildDetails(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final name = collector.fullName ?? 'N/A';
    final initials = name.split(' ').where((s) => s.isNotEmpty).take(2).map((s) => s[0]).join().toUpperCase();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: collector.isAvailable
            ? const Color(0xFF10B981).withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: TextStyle(
            color: collector.isAvailable
                ? const Color(0xFF10B981)
                : Colors.grey.shade400,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: collector.isAvailable
            ? const Color(0xFF10B981).withOpacity(0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        collector.isAvailable ? 'Sẵn sàng' : 'Không sẵn sàng',
        style: TextStyle(
          color: collector.isAvailable
              ? const Color(0xFF10B981)
              : Colors.grey.shade500,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      children: [
        _buildDetailRow(Icons.phone, collector.phone ?? 'N/A'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                Icons.check_circle_outline,
                collector.completedCount.toString(),
                'Hoàn thành',
                const Color(0xFF10B981),
              ),
            ),
            Expanded(
              child: _buildStatItem(
                Icons.assignment,
                collector.totalAssignments.toString(),
                'Tổng phân công',
                const Color(0xFF3B82F6),
              ),
            ),
            Expanded(
              child: _buildStatItem(
                Icons.warning_amber,
                collector.warningCount.toString(),
                'Cảnh cáo',
                collector.warningCount > 0
                    ? const Color(0xFFF59E0B)
                    : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onToggleAvailability,
            icon: Icon(
              collector.isAvailable ? Icons.pause : Icons.play_arrow,
            ),
            label: Text(
              collector.isAvailable
                  ? 'Đánh dấu không sẵn sàng'
                  : 'Đánh dấu sẵn sàng',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: collector.isAvailable
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF10B981),
              side: BorderSide(
                color: collector.isAvailable
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF10B981),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
