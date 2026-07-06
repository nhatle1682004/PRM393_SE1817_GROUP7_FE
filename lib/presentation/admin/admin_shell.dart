import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/auth_user.dart';
import 'package:waste_collection_management_system/presentation/admin/feedbacks/admin_feedbacks_screen.dart';
import 'package:waste_collection_management_system/presentation/admin/overview/admin_overview_screen.dart';
import 'package:waste_collection_management_system/presentation/admin/settings/admin_settings_screen.dart';
import 'package:waste_collection_management_system/presentation/admin/users/admin_users_screen.dart';
import 'package:waste_collection_management_system/presentation/shells/role_shell_scaffold.dart';

class AdminShell extends StatelessWidget {
  final AuthUser user;

  const AdminShell({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return RoleShellScaffold(
      title: 'Admin',
      user: user,
      destinations: const [
        ShellDestination(
          icon: Icons.insights_outlined,
          label: 'Overview',
          screen: AdminOverviewScreen(),
        ),
        ShellDestination(
          icon: Icons.people_outline,
          label: 'Users',
          screen: AdminUsersScreen(),
        ),
        ShellDestination(
          icon: Icons.feedback_outlined,
          label: 'Feedbacks',
          screen: AdminFeedbacksScreen(),
        ),
        ShellDestination(
          icon: Icons.settings_outlined,
          label: 'Profile',
          screen: AdminSettingsScreen(),
        ),
      ],
    );
  }
}
