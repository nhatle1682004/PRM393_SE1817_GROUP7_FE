import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/auth_user.dart';
import 'package:waste_collection_management_system/presentation/admin/admin_shell.dart';
import 'package:waste_collection_management_system/presentation/citizen/citizen_shell.dart';
import 'package:waste_collection_management_system/presentation/collector/collector_shell.dart';
import 'package:waste_collection_management_system/presentation/enterprise/enterprise_shell.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'package:waste_collection_management_system/services/storage_service.dart';

class AppRouter {
  const AppRouter._();

  static Future<Widget> initialScreen() async {
    final storage = StorageService();
    final token = await storage.getToken();
    final user = await storage.getUserProfile();
    if (token == null || token.isEmpty || user == null) {
      return const LoginScreen();
    }
    return screenForUser(user);
  }

  static Widget screenForUser(AuthUser user) {
    switch (user.roleId) {
      case 1:
        return CitizenShell(user: user);
      case 2:
        return EnterpriseShell(user: user);
      case 3:
        return CollectorShell(user: user);
      case 4:
        return AdminShell(user: user);
      default:
        return const LoginScreen();
    }
  }

  static void goToRoleHome(BuildContext context, AuthUser user) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screenForUser(user)),
      (_) => false,
    );
  }
}
