import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/auth_user.dart';
import 'package:waste_collection_management_system/presentation/citizen/dashboard/citizen_dashboard_screen.dart';
import 'package:waste_collection_management_system/presentation/citizen/history/citizen_history_screen.dart';
import 'package:waste_collection_management_system/presentation/citizen/report/create_report_screen.dart';
import 'package:waste_collection_management_system/presentation/citizen/rewards/citizen_rewards_screen.dart';
import 'package:waste_collection_management_system/presentation/citizen/settings/citizen_settings_screen.dart';
import 'package:waste_collection_management_system/presentation/shells/role_shell_scaffold.dart';

class CitizenShell extends StatelessWidget {
  final AuthUser user;

  const CitizenShell({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return RoleShellScaffold(
      title: 'Citizen',
      user: user,
      destinations: const [
        ShellDestination(
          icon: Icons.home_outlined,
          label: 'Home',
          screen: CitizenDashboardScreen(),
        ),
        ShellDestination(
          icon: Icons.add_circle_outline,
          label: 'Create Report',
          screen: CreateReportScreen(),
        ),
        ShellDestination(
          icon: Icons.card_giftcard_outlined,
          label: 'Rewards',
          screen: CitizenRewardsScreen(),
        ),
        ShellDestination(
          icon: Icons.history_outlined,
          label: 'History',
          screen: CitizenHistoryScreen(),
        ),
        ShellDestination(
          icon: Icons.settings_outlined,
          label: 'Profile',
          screen: CitizenSettingsScreen(),
        ),
      ],
    );
  }
}
