import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/admin_feedback.dart';

class FeedbackAdminCard extends StatelessWidget {
  final AdminFeedback feedback;
  final VoidCallback onDetail, onResolve, onReject;
  final bool canResolve;
  const FeedbackAdminCard({super.key, required this.feedback, required this.onDetail, required this.onResolve, required this.onReject, required this.canResolve});

  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('#${feedback.feedbackId}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        _chip(feedback.status),
      ]),
      const SizedBox(height: 12),
      Text(feedback.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(feedback.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        IconButton(onPressed: onDetail, icon: const Icon(Icons.visibility, color: Colors.blue)),
        if (canResolve) IconButton(onPressed: onResolve, icon: const Icon(Icons.check_circle, color: Colors.green)),
        if (canResolve) IconButton(onPressed: onReject, icon: const Icon(Icons.cancel, color: Colors.red)),
      ]),
    ])));
  }

  Widget _chip(String s) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(s, style: const TextStyle(fontSize: 10, color: Colors.blue)));
}
