import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/citizen_reward.dart';

class RewardHeader extends StatelessWidget {
  final int balance;
  const RewardHeader({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])),
      child: Column(children: [
        const Row(children: [Icon(Icons.card_giftcard, color: Colors.white), SizedBox(width: 12), Text('Đổi quà xanh', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Số dư điểm', style: TextStyle(color: Colors.grey, fontSize: 12)), Text('Báo cáo để tích điểm', style: TextStyle(fontSize: 10))])),
          Text('$balance', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
          const Text(' điểm', style: TextStyle(color: Colors.green)),
        ])),
      ]),
    );
  }
}

class VoucherCard extends StatelessWidget {
  final RewardVoucher voucher;
  final bool canRedeem;
  final VoidCallback onTap;
  const VoucherCard({super.key, required this.voucher, required this.canRedeem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Column(children: [
      Expanded(child: Container(color: Colors.green.withValues(alpha: 0.1), child: const Center(child: Icon(Icons.card_giftcard, size: 40, color: Colors.green)))),
      Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(voucher.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('${voucher.points} điểm', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: canRedeem ? onTap : null, child: Text(canRedeem ? 'Đổi quà' : 'Thiếu điểm'))),
      ])),
    ]));
  }
}
