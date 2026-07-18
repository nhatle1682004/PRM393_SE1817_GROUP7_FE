import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/api_config.dart';

class TimelineStep extends StatelessWidget {
  final String title, subtitle;
  final DateTime? time;
  final bool isDone, isLast, isError;
  const TimelineStep({super.key, required this.title, required this.subtitle, this.time, this.isDone = false, this.isLast = false, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final color = isError ? Colors.red : (isDone ? Colors.green : Colors.grey.shade300);
    return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(width: 24, height: 24, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: color, width: 2)), child: isDone ? Icon(isError ? Icons.priority_high : Icons.check, size: 14, color: color) : null),
        if (!isLast) Expanded(child: Container(width: 2, color: color.withValues(alpha: 0.3))),
      ]),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isError ? Colors.red : (isDone ? Colors.black : Colors.grey)))),
          if (time != null) Text('${time!.hour}:${time!.minute.toString().padLeft(2, "0")}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 20),
      ])),
    ]));
  }
}

class ProofGallery extends StatelessWidget {
  final String? before, after;
  const ProofGallery({super.key, this.before, this.after});

  @override
  Widget build(BuildContext context) {
    if (before == null && after == null) return const SizedBox();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('MINH CHỨNG', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      const SizedBox(height: 12),
      Row(children: [
        if (before != null) Expanded(child: _img('Trước', before!)),
        if (before != null && after != null) const SizedBox(width: 12),
        if (after != null) Expanded(child: _img('Sau', after!)),
      ]),
    ]);
  }

  Widget _img(String l, String u) => Column(children: [
    ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(ApiConfig.getFullImageUrl(u), height: 120, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported))),
    Text(l, style: const TextStyle(fontSize: 12)),
  ]);
}
