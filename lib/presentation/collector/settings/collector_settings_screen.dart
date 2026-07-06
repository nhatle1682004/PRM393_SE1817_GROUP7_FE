import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/presentation/profile/profile_screen.dart';
import 'package:waste_collection_management_system/services/user_service.dart';

class CollectorSettingsScreen extends StatefulWidget {
  const CollectorSettingsScreen({super.key});

  @override
  State<CollectorSettingsScreen> createState() =>
      _CollectorSettingsScreenState();
}

class _CollectorSettingsScreenState extends State<CollectorSettingsScreen> {
  final _users = UserService();
  bool _available = true;

  Future<void> _toggle(bool value) async {
    setState(() => _available = value);
    await _users.updateMyAvailability(value);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SwitchListTile(
          value: _available,
          onChanged: _toggle,
          title: const Text('Sẵn sàng nhận task'),
        ),
        const ProfileScreen(),
      ],
    );
  }
}
