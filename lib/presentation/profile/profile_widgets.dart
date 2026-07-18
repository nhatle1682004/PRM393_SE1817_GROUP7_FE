import 'package:flutter/material.dart';

class ProfileAvatarCard extends StatelessWidget {
  final String name, initials;
  final VoidCallback onEdit;
  const ProfileAvatarCard({super.key, required this.name, required this.initials, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(32), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children: [
      CircleAvatar(radius: 44, backgroundColor: Colors.green, child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
      const SizedBox(width: 28),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const Text('Hiệp sĩ Môi trường', style: TextStyle(color: Colors.green))])),
      ElevatedButton(onPressed: onEdit, child: const Text('Sửa')),
    ]));
  }
}

class InfoRow extends StatelessWidget {
  final String label, value;
  const InfoRow({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20), child: Row(children: [SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey))), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)))]));
}
