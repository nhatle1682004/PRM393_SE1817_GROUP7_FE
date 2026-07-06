import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/auth_user.dart';
import 'package:waste_collection_management_system/services/user_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _service = UserService();
  bool _loading = true;
  List<AuthUser> _users = const [];
  int? _roleFilter;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _users = await _service.getUsers();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final visible = _users.where((user) {
      final search = _search.toLowerCase();
      return (_roleFilter == null || user.roleId == _roleFilter) &&
          (search.isEmpty ||
              user.fullName.toLowerCase().contains(search) ||
              user.email.toLowerCase().contains(search));
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Tìm theo tên/email',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _search = value),
              ),
            ),
            DropdownButton<int?>(
              value: _roleFilter,
              hint: const Text('Lọc role'),
              items: const [
                DropdownMenuItem<int?>(value: null, child: Text('Tất cả role')),
                DropdownMenuItem<int?>(value: 1, child: Text('Citizen')),
                DropdownMenuItem<int?>(value: 2, child: Text('Enterprise')),
                DropdownMenuItem<int?>(value: 3, child: Text('Collector')),
                DropdownMenuItem<int?>(value: 4, child: Text('Admin')),
              ],
              onChanged: (value) => setState(() => _roleFilter = value),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...visible.map(
          (user) => Card(
            child: ListTile(
              title: Text(user.fullName),
              subtitle: Text(
                '${user.email} · ${AuthUser.roleNameFromId(user.roleId)} · ${user.status.isEmpty ? 'Unknown' : user.status}\n${user.createdAt ?? ''}',
              ),
              isThreeLine: true,
              trailing: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      await _service.deactivateUser(user.userId);
                      await _load();
                    },
                    child: const Text('Deactivate'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      await _service.activateUser(user.userId);
                      await _load();
                    },
                    child: const Text('Activate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
