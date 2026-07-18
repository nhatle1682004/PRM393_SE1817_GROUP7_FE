import 'package:flutter/material.dart';

class ProfileAvatarSection extends StatelessWidget {
  final String name;
  final bool isWide;
  const ProfileAvatarSection({super.key, required this.name, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((s) => s.isNotEmpty ? s[0] : '').join().toUpperCase();
    final size = isWide ? 88.0 : 72.0;
    return isWide ? Row(children: [
      _avatar(size, initials),
      const SizedBox(width: 28),
      _info(name, true),
    ]) : Column(children: [
      _avatar(size, initials),
      const SizedBox(height: 16),
      _info(name, false),
    ]);
  }

  Widget _avatar(double s, String i) => Container(width: s, height: s, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle), child: Center(child: Text(i, style: TextStyle(color: Colors.white, fontSize: s/3, fontWeight: FontWeight.bold))));
  Widget _info(String n, bool wide) => Column(crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [
    Text(n, style: TextStyle(fontSize: wide ? 24 : 20, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: const Text('Hiệp sĩ Môi trường', style: TextStyle(color: Colors.green, fontSize: 12))),
  ]);
}

class SettingCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const SettingCard({super.key, required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.2))), child: Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 22)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    ])));
  }
}
