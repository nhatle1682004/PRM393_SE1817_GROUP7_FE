import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/admin_collection_request.dart';
import 'package:waste_collection_management_system/services/admin_api_service.dart';

class CollectionRequestsView extends StatefulWidget {
  const CollectionRequestsView({super.key});

  @override
  State<CollectionRequestsView> createState() => _CollectionRequestsViewState();
}

class _CollectionRequestsViewState extends State<CollectionRequestsView> {
  List<AdminCollectionRequest> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedStatus = 'All';

  final List<String> _statuses = ['All', 'Pending', 'Assigned', 'InProgress', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requests = await AdminApiService.getAllCollectionRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
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

  List<AdminCollectionRequest> get _filteredRequests {
    return _requests.where((request) {
      final matchesSearch = request.requestId.toString().contains(_searchQuery) ||
          (request.enterpriseName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (request.assignedCollectorName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesStatus = _selectedStatus == 'All' || request.status == _selectedStatus;
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
                hintText: 'Tìm kiếm yêu cầu...',
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
            onPressed: _loadRequests,
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
              onPressed: _loadRequests,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, color: Colors.grey.shade400, size: 64),
            const SizedBox(height: 16),
            Text('Không tìm thấy yêu cầu nào', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _filteredRequests.length,
        itemBuilder: (context, index) => _buildRequestCard(_filteredRequests[index]),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildRequestsTable(),
    );
  }

  Widget _buildRequestsTable() {
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
                Expanded(flex: 2, child: Text('Doanh nghiệp', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 2, child: Text('Người thu gom', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 1, child: Text('Loại rác', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 1, child: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 1, child: Text('Ngày tạo', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
              ],
            ),
          ),
          ..._filteredRequests.map((request) => _buildRequestRow(request)),
        ],
      ),
    );
  }

  Widget _buildRequestRow(AdminCollectionRequest request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('#${request.requestId}', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  child: const Icon(Icons.business, size: 16, color: Color(0xFFF59E0B)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.enterpriseName ?? 'N/A',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                  child: Text(
                    request.assignedCollectorName?.isNotEmpty == true
                        ? request.assignedCollectorName![0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.assignedCollectorName ?? 'Chưa phân công',
                    style: TextStyle(
                      color: request.assignedCollectorName != null ? null : Colors.grey.shade400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              request.wasteTypeName ?? 'N/A',
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildStatusChip(request.status),
          ),
          Expanded(
            flex: 1,
            child: Text(
              request.createdAt != null ? _formatDate(request.createdAt!) : '-',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(AdminCollectionRequest request) {
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
                child: Text('#${request.requestId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(request.status),
              const Spacer(),
              Text(
                request.createdAt != null ? _formatDate(request.createdAt!) : '-',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.business, size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Doanh nghiệp: ${request.enterpriseName ?? 'N/A'}', style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: request.assignedCollectorName != null ? const Color(0xFF10B981) : Colors.grey.shade400),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Người thu gom: ${request.assignedCollectorName ?? 'Chưa phân công'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: request.assignedCollectorName != null ? null : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
          if (request.wasteTypeName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(request.wasteTypeName!, style: const TextStyle(fontSize: 12, color: Color(0xFF10B981))),
                ),
              ],
            ),
          ],
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
      case 'assigned':
        return const Color(0xFF3B82F6);
      case 'inprogress':
        return const Color(0xFF8B5CF6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xử lý';
      case 'assigned':
        return 'Đã phân công';
      case 'inprogress':
        return 'Đang thu gom';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
