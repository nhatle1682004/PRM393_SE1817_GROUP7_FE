import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:waste_collection_management_system/data/models/citizen_reward.dart';
import 'package:waste_collection_management_system/presentation/rewards/rewards_contract.dart';
import 'package:waste_collection_management_system/presentation/rewards/rewards_presenter.dart';
import 'rewards_widgets.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});
  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> implements RewardsView {
  late RewardsPresenter _presenter;
  bool _isLoading = false;
  List<RewardVoucher> _rewards = [];
  int _balance = 0;

  @override
  void initState() { super.initState(); _presenter = RewardsPresenterImpl(this); _presenter.loadRewards(); }

  @override
  void onLoadingStateChanged(bool l) => setState(() => _isLoading = l);
  @override
  void onRewardsLoaded(List<RewardVoucher> r) => setState(() => _rewards = r);
  @override
  void onBalanceLoaded(int b) => setState(() => _balance = b);
  @override
  void onRedeemSuccess(String m, int r) {
    setState(() => _balance = r);
    CherryToast.success(
      title: const Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(m),
      animationType: AnimationType.fromRight,
      autoDismiss: true,
    ).show(context);
  }

  @override
  void onRedeemError(String m) {
    if (!mounted) return;
    CherryToast.error(
      title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
      description: Text(m),
      animationType: AnimationType.fromRight,
      autoDismiss: true,
    ).show(context);
  }
  @override
  void onRedeemInProgress(bool i) {}
  @override
  void onError(String? m) {}
  @override
  void onRefreshComplete() {}

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      RewardHeader(balance: _balance),
      Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(onRefresh: () async => _presenter.refreshRewards(), child: GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.8), itemCount: _rewards.length, itemBuilder: (c, i) => VoucherCard(voucher: _rewards[i], canRedeem: _balance >= _rewards[i].points, onTap: () => _confirm(_rewards[i]))))),
    ]);
  }

  void _confirm(RewardVoucher r) => showDialog(context: context, builder: (c) => AlertDialog(title: const Text('Xác nhận đổi?'), content: Text('Sử dụng ${r.points} điểm để đổi ${r.name}'), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Hủy')), ElevatedButton(onPressed: () { Navigator.pop(c); _presenter.redeemReward(r); }, child: const Text('Đổi'))]));
}
