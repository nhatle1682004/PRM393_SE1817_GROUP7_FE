import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/auth_user.dart';
import 'package:waste_collection_management_system/presentation/login/login_screen.dart';
import 'package:waste_collection_management_system/presentation/notifications/notifications_screen.dart';
import 'package:waste_collection_management_system/services/auth_service.dart';
import 'package:waste_collection_management_system/widgets/notification_bell.dart';

class ShellDestination {
  final IconData icon;
  final String label;
  final Widget screen;

  const ShellDestination({
    required this.icon,
    required this.label,
    required this.screen,
  });
}

class RoleShellScaffold extends StatefulWidget {
  final String title;
  final AuthUser user;
  final List<ShellDestination> destinations;

  const RoleShellScaffold({
    super.key,
    required this.title,
    required this.user,
    required this.destinations,
  });

  @override
  State<RoleShellScaffold> createState() => _RoleShellScaffoldState();
}

class _RoleShellScaffoldState extends State<RoleShellScaffold> {
  int _selectedIndex = 0;

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final body = widget.destinations[_selectedIndex].screen;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          NotificationBell(onTap: _openNotifications),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (_) => [
              PopupMenuItem(enabled: false, child: Text(widget.user.fullName)),
              PopupMenuItem(
                enabled: false,
                child: Text(AuthUser.roleNameFromId(widget.user.roleId)),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.account_circle_outlined),
            ),
          ),
        ],
      ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: SafeArea(
                child: _MenuList(
                  destinations: widget.destinations,
                  selectedIndex: _selectedIndex,
                  onTap: _select,
                ),
              ),
            ),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 260,
              child: Material(
                color: Colors.white,
                child: SafeArea(
                  child: _MenuList(
                    destinations: widget.destinations,
                    selectedIndex: _selectedIndex,
                    onTap: _select,
                  ),
                ),
              ),
            ),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _select,
              destinations: widget.destinations
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  void _select(int index) {
    setState(() => _selectedIndex = index);
  }
}

class _MenuList extends StatelessWidget {
  final List<ShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _MenuList({
    required this.destinations,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final item = destinations[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            selected: selectedIndex == index,
            selectedTileColor: const Color(0xffdcfce7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            leading: Icon(item.icon),
            title: Text(item.label),
            onTap: () {
              if (Scaffold.maybeOf(context)?.isDrawerOpen == true) {
                Navigator.pop(context);
              }
              onTap(index);
            },
          ),
        );
      },
    );
  }
}
