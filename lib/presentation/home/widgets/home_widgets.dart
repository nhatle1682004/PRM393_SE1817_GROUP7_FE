import 'package:flutter/material.dart';

class EcoBanner extends StatelessWidget {
  final VoidCallback onReport;
  const EcoBanner({super.key, required this.onReport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF0F6E56), borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Vì một Việt Nam xanh', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Thấy rác là báo, sạch lối sạch đường.', style: TextStyle(color: Color(0xFFC0DD97))),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: onReport, child: const Text('Báo cáo rác ngay')),
      ]),
    );
  }
}

class RewardCard extends StatelessWidget {
  final VoidCallback onTap;
  const RewardCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tích điểm xanh, đổi quà sạch', style: TextStyle(fontWeight: FontWeight.bold)), Text('Mỗi báo cáo thành công giúp bạn tích điểm', style: TextStyle(fontSize: 12, color: Colors.grey))])),
      const Icon(Icons.redeem, size: 40, color: Colors.orange),
    ])));
  }
}

class StatGrid extends StatelessWidget {
  final int total;
  const StatGrid({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _card('Chờ duyệt', 0, Colors.orange),
      const SizedBox(width: 8),
      _card('Đang xử lý', 0, Colors.blue),
      const SizedBox(width: 8),
      _card('Tổng cộng', total, Colors.green),
    ]);
  }

  Widget _card(String l, int v, Color c) => Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(l, style: const TextStyle(fontSize: 10)), Text('$v', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c))])));
}
