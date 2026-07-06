import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/auth_user.dart';
import 'package:waste_collection_management_system/presentation/enterprise/dashboard/enterprise_dashboard_screen.dart';
import 'package:waste_collection_management_system/presentation/enterprise/dispatch/enterprise_dispatch_screen.dart';
import 'package:waste_collection_management_system/presentation/enterprise/rules/enterprise_rules_screen.dart';
import 'package:waste_collection_management_system/presentation/enterprise/settings/enterprise_settings_screen.dart';
import 'package:waste_collection_management_system/presentation/shells/role_shell_scaffold.dart';

class EnterpriseShell extends StatelessWidget {
  final AuthUser user;

  const EnterpriseShell({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return RoleShellScaffold(
      title: 'Enterprise',
      user: user,
      destinations: const [
        ShellDestination(
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          screen: EnterpriseDashboardScreen(),
        ),
        ShellDestination(
          icon: Icons.local_shipping_outlined,
          label: 'Dispatch',
          screen: EnterpriseDispatchScreen(),
        ),
        ShellDestination(
          icon: Icons.rule_outlined,
          label: 'Rules',
          screen: EnterpriseRulesScreen(),
        ),
        ShellDestination(
          icon: Icons.settings_outlined,
          label: 'Profile',
          screen: EnterpriseSettingsScreen(),
        ),
      ],
    );
  }
}
