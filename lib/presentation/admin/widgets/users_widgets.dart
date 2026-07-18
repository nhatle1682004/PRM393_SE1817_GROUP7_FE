import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/admin_user.dart';

class UserCard extends StatelessWidget {
  final AdminUser user;
  final String enterpriseName;
  final VoidCallback onEdit, onToggle;
  const UserCard({super.key, required this.user, required this.enterpriseName, required this.onEdit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Row(children: [
        CircleAvatar(child: Text(user.fullName[0])),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)), Text(user.email, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
        _RoleChip(role: user.roleName),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        _StatusChip(active: user.isActive),
        if (user.roleName.toLowerCase() == 'collector') Text(' DN: $enterpriseName', style: const TextStyle(fontSize: 12)),
        const Spacer(),
        TextButton(onPressed: onEdit, child: const Text('Sửa')),
        TextButton(onPressed: onToggle, child: Text(user.isActive ? 'Khóa' : 'Mở', style: TextStyle(color: user.isActive ? Colors.red : Colors.green))),
      ]),
    ])));
  }
}

class _RoleChip extends StatelessWidget {
  final String role;
  const _RoleChip({required this.role});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(role, style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)));
}

class _StatusChip extends StatelessWidget {
  final bool active;
  const _StatusChip({required this.active});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: (active ? Colors.green : Colors.red).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Text(active ? 'Hoạt động' : 'Khóa', style: TextStyle(fontSize: 10, color: active ? Colors.green : Colors.red, fontWeight: FontWeight.bold)));
}
