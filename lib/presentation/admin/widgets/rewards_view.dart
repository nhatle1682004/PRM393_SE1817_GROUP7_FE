import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:waste_collection_management_system/data/models/admin_reward.dart';
import 'package:waste_collection_management_system/presentation/admin/widgets/pagination_controls.dart';
import 'package:waste_collection_management_system/services/admin_api_service.dart';

class RewardsView extends StatefulWidget {
  const RewardsView({super.key});

  @override
  State<RewardsView> createState() => _RewardsViewState();
}

class _RewardsViewState extends State<RewardsView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<AdminReward> _rewards = [];
  List<AdminRewardTransaction> _transactions = [];
  bool _loadingRewards = true;
  bool _loadingTransactions = true;
  String? _rewardError;
  String? _transactionError;
  int _rewardPage = 0;
  int _transactionPage = 0;
  static const int _pageSize = 10;

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

  List<T> _page<T>(List<T> items, int page) {
    final start = page * _pageSize;
    if (start >= items.length) return [];
    final end = start + _pageSize > items.length ? items.length : start + _pageSize;
    return items.sublist(start, end);
  }

  Future<void> _loadRewards() async {
    setState(() {
      _loadingRewards = true;
      _rewardError = null;
    });
    try {
      final rewards = await AdminApiService.getRewardCatalog();
      if (!mounted) return;
      setState(() {
        _rewards = rewards;
        _rewardPage = 0;
        _loadingRewards = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _rewardError = e.toString();
        _loadingRewards = false;
      });
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _loadingTransactions = true;
      _transactionError = null;
    });
    try {
      final transactions = await AdminApiService.getAllRewardTransactions();
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _transactionPage = 0;
        _loadingTransactions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _transactionError = e.toString();
        _loadingTransactions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
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
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ElevatedButton.icon(
                  onPressed: () => _showRewardDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tạo phần thưởng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildRewardsTab(), _buildTransactionsTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsTab() {
    if (_loadingRewards) return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
    if (_rewardError != null) return _errorView(_rewardError!, _loadRewards);
    if (_rewards.isEmpty) return _emptyView(Icons.card_giftcard_outlined, 'Chưa có phần thưởng nào');

    final rewards = _page(_rewards, _rewardPage);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rewards.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _rewardRow(rewards[index]),
          ),
        ),
        PaginationControls(
          currentPage: _rewardPage,
          totalItems: _rewards.length,
          pageSize: _pageSize,
          onPageChanged: (page) => setState(() => _rewardPage = page),
        ),
      ],
    );
  }

  Widget _rewardRow(AdminReward reward) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFDCFCE7),
            child: Icon(Icons.card_giftcard, color: reward.status ? const Color(0xFF10B981) : Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (reward.description?.isNotEmpty == true)
                  Text(reward.description!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B))),
              ],
            ),
          ),
          Text('${reward.points} điểm', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
          const SizedBox(width: 16),
          _chip(reward.status ? 'Hoạt động' : 'Tắt', reward.status ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Sửa',
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: const Color(0xFF3B82F6),
            onPressed: () => _showRewardDialog(reward: reward),
          ),
          IconButton(
            tooltip: 'Xóa',
            icon: const Icon(Icons.delete_outline, size: 20),
            color: const Color(0xFFEF4444),
            onPressed: () => _deleteReward(reward),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    if (_loadingTransactions) return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
    if (_transactionError != null) return _errorView(_transactionError!, _loadTransactions);
    if (_transactions.isEmpty) return _emptyView(Icons.history_outlined, 'Chưa có giao dịch nào');

    final transactions = _page(_transactions, _transactionPage);
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _transactionRow(transactions[index]),
          ),
        ),
        PaginationControls(
          currentPage: _transactionPage,
          totalItems: _transactions.length,
          pageSize: _pageSize,
          onPageChanged: (page) => setState(() => _transactionPage = page),
        ),
      ],
    );
  }

  Widget _transactionRow(AdminRewardTransaction transaction) {
    final positive = transaction.points >= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Text('#${transaction.transactionId}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 16),
          Expanded(child: Text(transaction.userName.isEmpty ? 'Người dùng #${transaction.userId}' : transaction.userName)),
          Expanded(child: Text(transaction.rewardName ?? transaction.description, overflow: TextOverflow.ellipsis)),
          Text(
            '${positive ? '+' : ''}${transaction.points}',
            style: TextStyle(fontWeight: FontWeight.w700, color: positive ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
          ),
          const SizedBox(width: 16),
          _chip(_transactionStatusLabel(transaction.status), _transactionStatusColor(transaction.status)),
        ],
      ),
    );
  }

  Future<void> _showRewardDialog({AdminReward? reward}) async {
    final isEdit = reward != null;
    final nameController = TextEditingController(text: reward?.name ?? '');
    final descriptionController = TextEditingController(text: reward?.description ?? '');
    final pointsController = TextEditingController(text: reward?.points.toString() ?? '');
    bool status = reward?.status ?? true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Sửa phần thưởng' : 'Tạo phần thưởng'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên phần thưởng', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: descriptionController, maxLines: 2, decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: pointsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Điểm cần đổi', border: OutlineInputBorder())),
                SwitchListTile(
                  value: status,
                  onChanged: (value) => setDialogState(() => status = value),
                  title: const Text('Đang hoạt động'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final points = int.tryParse(pointsController.text.trim());
                if (nameController.text.trim().isEmpty || points == null || points <= 0) {
                  CherryToast.warning(
                    title: const Text('Thông báo'),
                    description: const Text('Vui lòng nhập tên và điểm hợp lệ'),
                    animationType: AnimationType.fromRight,
                    autoDismiss: true,
                  ).show(context);
                  return;
                }

                final request = CreateRewardRequest(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                  points: points,
                  status: status,
                );

                try {
                  if (isEdit) {
                    await AdminApiService.updateReward(reward.rewardId, request);
                  } else {
                    await AdminApiService.createReward(request);
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    await _loadRewards();
                    if (context.mounted) {
                      CherryToast.success(
                        title: const Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
                        description: Text(isEdit ? 'Đã cập nhật phần thưởng' : 'Đã tạo phần thưởng'),
                        animationType: AnimationType.fromRight,
                        autoDismiss: true,
                      ).show(context);
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    CherryToast.error(
                      title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
                      description: Text('Lỗi: $e'),
                      animationType: AnimationType.fromRight,
                      autoDismiss: true,
                    ).show(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: Text(isEdit ? 'Lưu' : 'Tạo', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReward(AdminReward reward) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa phần thưởng'),
        content: Text('Bạn có chắc muốn xóa/tắt "${reward.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await AdminApiService.deleteReward(reward.rewardId);
      await _loadRewards();
      if (mounted) {
        CherryToast.success(
          title: const Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
          description: const Text('Đã xóa/tắt phần thưởng'),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        CherryToast.error(
          title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text('Lỗi: $e'),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    }
  }

  Widget _errorView(String message, Future<void> Function() retry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: retry, child: const Text('Thử lại')),
        ],
      ),
    );
  }

  Widget _emptyView(IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 64),
          const SizedBox(height: 16),
          Text(text, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }

  Color _transactionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'failed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _transactionStatusLabel(String status) {
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
}
