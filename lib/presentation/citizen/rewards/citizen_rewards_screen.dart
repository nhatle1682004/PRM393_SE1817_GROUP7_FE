import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/reward.dart';
import 'package:waste_collection_management_system/data/models/reward_transaction.dart';
import 'package:waste_collection_management_system/services/reward_service.dart';

class CitizenRewardsScreen extends StatefulWidget {
  const CitizenRewardsScreen({super.key});

  @override
  State<CitizenRewardsScreen> createState() => _CitizenRewardsScreenState();
}

class _CitizenRewardsScreenState extends State<CitizenRewardsScreen> {
  final _service = RewardService();
  bool _loading = true;
  int _balance = 0;
  List<Reward> _catalog = const [];
  List<RewardTransaction> _history = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final values = await Future.wait([
        _service.getBalance(),
        _service.getCatalog(),
        _service.getHistory(),
      ]);
      _balance = values[0] as int;
      _catalog = values[1] as List<Reward>;
      _history = values[2] as List<RewardTransaction>;
    } catch (e) {
      _show(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _redeem(Reward reward) async {
    await _service.redeemReward(reward.rewardId);
    _show('Đổi thưởng thành công.');
    await _load();
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Điểm hiện có: $_balance',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Danh mục đổi thưởng',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        ..._catalog.map(
          (reward) => Card(
            child: ListTile(
              title: Text(reward.name),
              subtitle: Text('${reward.description}\n${reward.points} điểm'),
              trailing: FilledButton(
                onPressed: _balance >= reward.points
                    ? () => _redeem(reward)
                    : null,
                child: const Text('Đổi'),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Lịch sử điểm', style: Theme.of(context).textTheme.titleLarge),
        ..._history.map(
          (tx) => ListTile(
            title: Text('${tx.type}: ${tx.points}'),
            subtitle: Text(tx.description),
          ),
        ),
      ],
    );
  }
}
