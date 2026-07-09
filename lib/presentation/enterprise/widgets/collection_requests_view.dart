import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';
import 'package:waste_collection_management_system/presentation/enterprise/widgets/collection_progress_view.dart';

class CollectionRequestsView extends StatefulWidget {
  const CollectionRequestsView({super.key});

  @override
  State<CollectionRequestsView> createState() => _CollectionRequestsViewState();
}

class _CollectionRequestsViewState extends State<CollectionRequestsView> {
  List<EnterpriseCollectionRequest> _requests = [];
  List<EnterpriseCollector> _collectors = [];
  bool _isLoading = true;
  String? _error;
  String _statusFilter = 'Tất cả';
  final List<String> _statusFilters = ['Tất cả', 'Pending', 'InProgress', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        EnterpriseApiService.getCollectionRequests(),
        EnterpriseApiService.getCollectors(),
      ]);
      if (mounted) {
        setState(() {
          _requests = results[0] as List<EnterpriseCollectionRequest>;
          _collectors = (results[1] as List<EnterpriseCollector>).where((c) => c.isAvailable).toList();
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

  Future<void> _loadRequests() async {
    await _loadData();
  }

  List<EnterpriseCollectionRequest> get _filteredRequests {
    if (_statusFilter == 'Tất cả') return _requests;
    return _requests.where((r) => r.status == _statusFilter).toList();
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'TIẾN ĐỘ XỬ LÝ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_filteredRequests.length} yêu cầu',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF10B981),
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _loadRequests,
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

    if (_filteredRequests.isEmpty) {
      return _buildEmptyState();
    }

    return _buildRequestsList();
  }

  Widget _buildRequestsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRequests.length,
      itemBuilder: (context, index) {
        final request = _filteredRequests[index];
        return _RequestCard(
          request: request,
          onTap: () => _showRequestDetail(request),
          onAssign: () => _showAssignDialog(request),
        );
      },
    );
  }

  void _showAssignDialog(EnterpriseCollectionRequest request) {
    showDialog(
      context: context,
      builder: (context) => _AssignCollectorDialog(
        request: request,
        collectors: _collectors,
        onAssigned: () {
          _loadData();
        },
      ),
    );
  }

  void _showRequestDetail(EnterpriseCollectionRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollectionProgressView(
          requestId: request.requestId,
          reportId: request.reportId, // Pass reportId to progress view
          onRefresh: _loadRequests,
        ),
      ),
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
            onPressed: _loadRequests,
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
              Icons.inbox_outlined,
              size: 48,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Không có yêu cầu nào',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Danh sách yêu cầu sẽ hiển thị tại đây',
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

class _RequestCard extends StatelessWidget {
  final EnterpriseCollectionRequest request;
  final VoidCallback onTap;
  final VoidCallback? onAssign;

  const _RequestCard({
    required this.request,
    required this.onTap,
    this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernHeader(),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagePreview(request.reportImageUrl),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.location_on_rounded, request.location, color: Colors.redAccent),
                        const SizedBox(height: 8),
                        _buildCollectorInfo(context),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              request.createdAt != null ? _formatDate(request.createdAt!) : 'N/A',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '#${request.reportId}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: Color(0xFF475569),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            request.wasteTypeName ?? 'N/A',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _StatusBadge(status: request.status ?? 'Pending'),
      ],
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
            ? Image.network(
                fullUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 20),
              )
            : const Icon(Icons.image_rounded, color: Colors.grey, size: 20),
      ),
    );
  }

  Widget _buildCollectorInfo(BuildContext context) {
    final hasCollector = request.assignedCollectorName != null;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: hasCollector ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasCollector ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasCollector ? Icons.person_rounded : Icons.person_off_rounded,
            size: 16,
            color: hasCollector ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasCollector ? 'NV: ${request.assignedCollectorName}' : 'Chưa phân công',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: hasCollector ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!hasCollector && onAssign != null)
            GestureDetector(
              onTap: onAssign,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFB91C1C),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Gán NV',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return const SizedBox.shrink();
  }

  Widget _buildMobileHeader() {
    return const SizedBox.shrink();
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return const SizedBox.shrink();
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

class _AssignCollectorDialog extends StatefulWidget {
  final EnterpriseCollectionRequest request;
  final List<EnterpriseCollector> collectors;
  final VoidCallback onAssigned;

  const _AssignCollectorDialog({
    required this.request,
    required this.collectors,
    required this.onAssigned,
  });

  @override
  State<_AssignCollectorDialog> createState() => _AssignCollectorDialogState();
}

class _AssignCollectorDialogState extends State<_AssignCollectorDialog> {
  int? _selectedCollectorId;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Gán nhân viên cho #${widget.request.reportId}'),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.collectors.isEmpty
            ? const Text('Hiện không có nhân viên nào sẵn sàng để gán việc.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: widget.collectors.length,
                itemBuilder: (context, index) {
                  final collector = widget.collectors[index];
                  return RadioListTile<int>(
                    title: Text(collector.fullName ?? 'N/A'),
                    subtitle: Text('Hoàn thành: ${collector.completedCount} việc'),
                    value: collector.collectorId,
                    groupValue: _selectedCollectorId,
                    onChanged: (val) => setState(() => _selectedCollectorId = val),
                    activeColor: const Color(0xFF10B981),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: (_selectedCollectorId == null || _isSubmitting)
              ? null
              : _handleAssign,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Xác nhận', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _handleAssign() async {
    setState(() => _isSubmitting = true);
    try {
      await EnterpriseApiService.assignCollector(AssignCollectorRequest(
        requestId: widget.request.requestId,
        collectorId: _selectedCollectorId!,
      ));
      if (mounted) {
        Navigator.pop(context);
        widget.onAssigned();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
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

class _RequestDetailSheet extends StatefulWidget {
  final int requestId;
  final VoidCallback onRefresh;

  const _RequestDetailSheet({
    required this.requestId,
    required this.onRefresh,
  });

  @override
  State<_RequestDetailSheet> createState() => _RequestDetailSheetState();
}

class _RequestDetailSheetState extends State<_RequestDetailSheet> {
  CollectionRequestDetail? _detail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
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
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                    : _error != null
                        ? Center(child: Text('Lỗi: $_error'))
                        : _buildContent(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Chi tiết yêu cầu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ScrollController scrollController) {
    if (_detail == null) return const SizedBox();

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Thông tin yêu cầu', [
            _buildInfoRow('ID', '#${_detail!.requestId}'),
            _buildInfoRow('Trạng thái', _detail!.status ?? 'N/A'),
            _buildInfoRow('Ngày tạo', _detail!.createdAt != null
                ? _formatDate(_detail!.createdAt!) : 'N/A'),
          ]),
          if (_detail!.report != null) ...[
            const SizedBox(height: 20),
            _buildSection('Thông tin báo cáo', [
              _buildInfoRow('ID', '#${_detail!.report!.reportId}'),
              _buildInfoRow('Công dân', _detail!.report!.citizenName ?? 'N/A'),
              _buildInfoRow('Loại rác', _detail!.report!.wasteTypeNames.join(', ')),
              _buildInfoRow('Vị trí', _detail!.report!.location),
              if (_detail!.report!.description != null)
                _buildInfoRow('Mô tả', _detail!.report!.description!),
            ]),
          ],
          if (_detail!.assignmentHistory?.isNotEmpty ?? false) ...[
            const SizedBox(height: 20),
            _buildSection('Lịch sử phân công', [
              ...(_detail!.assignmentHistory!.map((h) => _buildAssignmentHistoryItem(h))),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentHistoryItem(AssignmentHistoryDto history) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFF10B981),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.collectorName ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (history.collectorPhone != null)
                  Text(
                    history.collectorPhone!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          _StatusBadge(status: history.status ?? 'Pending'),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
