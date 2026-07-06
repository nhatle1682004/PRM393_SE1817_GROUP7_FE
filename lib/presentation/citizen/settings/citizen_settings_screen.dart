import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/presentation/profile/change_password_screen.dart';
import 'package:waste_collection_management_system/presentation/profile/profile_screen.dart';

class CitizenSettingsScreen extends StatelessWidget {
  const CitizenSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const ProfileScreen(),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
          ),
          icon: const Icon(Icons.lock_outline),
          label: const Text('Đổi mật khẩu'),
        ),
      ],
    );
  }
}
