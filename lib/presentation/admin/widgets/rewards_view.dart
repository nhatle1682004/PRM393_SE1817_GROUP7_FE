import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/admin_reward.dart';
import 'package:waste_collection_management_system/services/admin_api_service.dart';

class RewardsView extends StatefulWidget {
  const RewardsView({super.key});

  @override
  State<RewardsView> createState() => _RewardsViewState();
}

class _RewardsViewState extends State<RewardsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AdminReward> _rewards = [];
  List<AdminRewardTransaction> _transactions = [];
  bool _isLoadingRewards = true;
  bool _isLoadingTransactions = true;
  String? _errorMessageRewards;
  String? _errorMessageTransactions;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRewards();
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRewards() async {
    setState(() {
      _isLoadingRewards = true;
      _errorMessageRewards = null;
    });

    try {
      final rewards = await AdminApiService.getRewardCatalog();
      if (mounted) {
        setState(() {
          _rewards = rewards;
          _isLoadingRewards = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessageRewards = e.toString();
          _isLoadingRewards = false;
        });
      }
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoadingTransactions = true;
      _errorMessageTransactions = null;
    });

    try {
      final transactions = await AdminApiService.getAllRewardTransactions();
      if (mounted) {
        setState(() {
          _transactions = transactions;
          _isLoadingTransactions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessageTransactions = e.toString();
          _isLoadingTransactions = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF10B981),
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: const Color(0xFF10B981),
            tabs: const [
              Tab(text: 'Danh sách phần thưởng', icon: Icon(Icons.card_giftcard, size: 20)),
              Tab(text: 'Lịch sử giao dịch', icon: Icon(Icons.history, size: 20)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRewardsTab(isMobile),
              _buildTransactionsTab(isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsTab(bool isMobile) {
    if (_isLoadingRewards) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
    }

    if (_errorMessageRewards != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 48),
            const SizedBox(height: 16),
            Text(_errorMessageRewards!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRewards,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_rewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard_outlined, color: Colors.grey.shade400, size: 64),
            const SizedBox(height: 16),
            Text('Chưa có phần thưởng nào', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _rewards.length,
        itemBuilder: (context, index) => _buildRewardCard(_rewards[index]),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _rewards.length,
      itemBuilder: (context, index) => _buildRewardCard(_rewards[index]),
    );
  }

  Widget _buildRewardCard(AdminReward reward) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    reward.status ? const Color(0xFF10B981) : Colors.grey,
                    reward.status ? const Color(0xFF059669) : Colors.grey.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  Icons.card_giftcard,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 48,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reward.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: reward.status ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reward.status ? 'Hoạt động' : 'Tắt',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: reward.status ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (reward.description != null)
                  Text(
                    reward.description!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars, size: 14, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(
                            '${reward.points} điểm',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${reward.totalRedeemed} đã đổi',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(bool isMobile) {
    if (_isLoadingTransactions) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
    }

    if (_errorMessageTransactions != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 48),
            const SizedBox(height: 16),
            Text(_errorMessageTransactions!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTransactions,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, color: Colors.grey.shade400, size: 64),
            const SizedBox(height: 16),
            Text('Chưa có giao dịch nào', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      );
    }

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _transactions.length,
        itemBuilder: (context, index) => _buildTransactionCard(_transactions[index]),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildTransactionsTable(),
    );
  }

  Widget _buildTransactionsTable() {
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
                Expanded(flex: 2, child: Text('Người dùng', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 2, child: Text('Phần thưởng', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 1, child: Text('Điểm', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 1, child: Text('Loại', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 1, child: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                Expanded(flex: 1, child: Text('Ngày', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
              ],
            ),
          ),
          ..._transactions.map((transaction) => _buildTransactionRow(transaction)),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(AdminRewardTransaction transaction) {
    final isPositive = transaction.points > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('#${transaction.transactionId}', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                  child: Text(
                    transaction.userName.isNotEmpty ? transaction.userName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(transaction.userName, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              transaction.rewardName ?? transaction.description,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
                Text(
                  '${isPositive ? '+' : ''}${transaction.points}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildTypeChip(transaction.type),
          ),
          Expanded(
            flex: 1,
            child: _buildStatusChip(transaction.status),
          ),
          Expanded(
            flex: 1,
            child: Text(
              transaction.createdAt != null ? _formatDate(transaction.createdAt!) : '-',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(AdminRewardTransaction transaction) {
    final isPositive = transaction.points > 0;

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
                child: Text('#${transaction.transactionId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(transaction.status),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${transaction.points}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                child: Text(
                  transaction.userName.isNotEmpty ? transaction.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(transaction.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.card_giftcard, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  transaction.rewardName ?? transaction.description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTypeChip(transaction.type),
              const Spacer(),
              Text(
                transaction.createdAt != null ? _formatDate(transaction.createdAt!) : '-',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    Color color;
    switch (type.toLowerCase()) {
      case 'redeemed':
        color = const Color(0xFFEF4444);
        break;
      case 'earned':
        color = const Color(0xFF10B981);
        break;
      default:
        color = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
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
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'failed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Hoàn thành';
      case 'pending':
        return 'Đang xử lý';
      case 'failed':
        return 'Thất bại';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
