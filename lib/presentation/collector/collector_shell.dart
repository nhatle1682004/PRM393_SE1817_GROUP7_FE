import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/auth_user.dart';
import 'package:waste_collection_management_system/presentation/collector/active_job/collector_active_job_screen.dart';
import 'package:waste_collection_management_system/presentation/collector/history/collector_task_history_screen.dart';
import 'package:waste_collection_management_system/presentation/collector/settings/collector_settings_screen.dart';
import 'package:waste_collection_management_system/presentation/shells/role_shell_scaffold.dart';

class CollectorShell extends StatelessWidget {
  final AuthUser user;

  const CollectorShell({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return RoleShellScaffold(
      title: 'Collector',
      user: user,
      destinations: const [
        ShellDestination(
          icon: Icons.work_outline,
          label: 'Active Job',
          screen: CollectorActiveJobScreen(),
        ),
        ShellDestination(
          icon: Icons.history_outlined,
          label: 'History',
          screen: CollectorTaskHistoryScreen(),
        ),
        ShellDestination(
          icon: Icons.settings_outlined,
          label: 'Profile',
          screen: CollectorSettingsScreen(),
        ),
      ],
    );
  }
}
