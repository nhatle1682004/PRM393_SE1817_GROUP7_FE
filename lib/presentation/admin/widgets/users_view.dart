import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/data/models/admin_user.dart';
import 'package:waste_collection_management_system/services/admin_api_service.dart';
import 'package:waste_collection_management_system/presentation/admin/widgets/pagination_controls.dart';
import 'users_widgets.dart';

class UsersView extends StatefulWidget {
  final VoidCallback onRefresh;
  const UsersView({super.key, required this.onRefresh});
  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  List<AdminUser> _users = [];
  bool _isLoading = true;
  String _search = '', _role = 'All';
  int _page = 0;
  final int _size = 10;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await AdminApiService.getAllUsers();
      if (mounted) setState(() { _users = res; _isLoading = false; });
    } catch (_) { if (mounted) setState(() => _isLoading = false); }
  }

  List<AdminUser> get _filtered => _users.where((u) => (u.fullName.toLowerCase().contains(_search.toLowerCase()) || u.email.toLowerCase().contains(_search.toLowerCase())) && (_role == 'All' || u.roleName == _role)).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final paged = filtered.skip(_page * _size).take(_size).toList();

    return Column(children: [
      _buildToolbar(),
      Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : (filtered.isEmpty ? const Center(child: Text('Không tìm thấy')) : ListView.builder(padding: const EdgeInsets.all(12), itemCount: paged.length, itemBuilder: (c, i) => UserCard(user: paged[i], enterpriseName: _entName(paged[i].enterpriseId), onEdit: () {}, onToggle: () => _toggle(paged[i]))))),
      PaginationControls(currentPage: _page, totalItems: filtered.length, pageSize: _size, onPageChanged: (p) => setState(() => _page = p)),
    ]);
  }

  Widget _buildToolbar() => Container(padding: const EdgeInsets.all(12), color: Colors.white, child: Row(children: [
    Expanded(child: TextField(onChanged: (v) => setState(() { _search = v; _page = 0; }), decoration: const InputDecoration(hintText: 'Tìm kiếm...', prefixIcon: Icon(Icons.search)))),
    const SizedBox(width: 12),
    DropdownButton<String>(value: _role, items: ['All', 'Admin', 'Citizen', 'Collector', 'Enterprise'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(), onChanged: (v) => setState(() { _role = v!; _page = 0; })),
  ]));

  String _entName(int? id) => id == null ? 'N/A' : (_users.any((u) => u.userId == id) ? _users.firstWhere((u) => u.userId == id).fullName : '#$id');

  Future<void> _toggle(AdminUser u) async {
    try {
      if (u.isActive) {
        await AdminApiService.deactivateUser(u.userId);
      } else {
        await AdminApiService.activateUser(u.userId);
      }
      _load();
      widget.onRefresh();
    } catch (_) {}
  }
}
