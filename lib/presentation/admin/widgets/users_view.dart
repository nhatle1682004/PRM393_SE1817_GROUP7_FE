import 'package:flutter/material.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/constants/app_roles.dart';
import 'package:waste_collection_management_system/data/models/admin_user.dart';
import 'package:waste_collection_management_system/data/models/district_model.dart';
import 'package:waste_collection_management_system/services/admin_api_service.dart';
import 'package:waste_collection_management_system/services/api_service.dart';

class UsersView extends StatefulWidget {
  final VoidCallback onRefresh;

  const UsersView({super.key, required this.onRefresh});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  List<AdminUser> _users = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedRole = 'All';

  final List<String> _roles = [
    'All',
    'Admin',
    'Citizen',
    'Collector',
    'Enterprise',
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await AdminApiService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<AdminUser> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch =
          user.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole =
          _selectedRole == 'All' || user.roleName == _selectedRole;
      return matchesSearch && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Column(
      children: [
        _buildToolbar(isMobile),
        Expanded(child: _buildContent(isMobile)),
      ],
    );
  }

  Widget _buildToolbar(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm người dùng...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isMobile ? 10 : 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildRoleFilter(isMobile),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showCreateUserDialog(),
                icon: const Icon(Icons.add, size: 20),
                label: Text(isMobile ? '' : 'Thêm người dùng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.all(isMobile ? 12 : 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilter(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isDense: true,
          items: _roles
              .map((role) => DropdownMenuItem(value: role, child: Text(role)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedRole = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsers,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text(
                'Thử lại',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, color: Colors.grey.shade400, size: 64),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy người dùng nào',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) => _buildUserCard(_filteredUsers[index]),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildUsersTable(),
    );
  }

  Widget _buildUsersTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                _buildTableHeader('Người dùng', flex: 3),
                _buildTableHeader('Email', flex: 2),
                _buildTableHeader('Vai trò', flex: 1),
                _buildTableHeader('Trạng thái', flex: 1),
                _buildTableHeader('Hành động', flex: 1),
              ],
            ),
          ),
          ..._filteredUsers.map((user) => _buildUserRow(user)),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildUserRow(AdminUser user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _getRoleColor(
                    user.roleName,
                  ).withValues(alpha: 0.1),
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: _getRoleColor(user.roleName),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.totalPoints != null)
                        Text(
                          '${user.totalPoints} điểm',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(user.email, overflow: TextOverflow.ellipsis),
          ),
          Expanded(flex: 1, child: _buildRoleChip(user.roleName)),
          Expanded(flex: 1, child: _buildStatusChip(user.isActive)),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: const Color(0xFF3B82F6),
                  onPressed: () => _showEditUserDialog(user),
                  tooltip: 'Sửa',
                ),
                IconButton(
                  icon: Icon(
                    user.isActive ? Icons.block : Icons.check_circle_outline,
                    size: 20,
                  ),
                  color: user.isActive
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                  onPressed: () => _toggleUserStatus(user),
                  tooltip: user.isActive ? 'Vô hiệu hóa' : 'Kích hoạt',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AdminUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _getRoleColor(
                  user.roleName,
                ).withValues(alpha: 0.1),
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: _getRoleColor(user.roleName),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _buildRoleChip(user.roleName),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusChip(user.isActive),
              const Spacer(),
              if (user.totalPoints != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stars,
                        size: 14,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.totalPoints} điểm',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showEditUserDialog(user),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Sửa'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
                ),
              ),
              TextButton.icon(
                onPressed: () => _toggleUserStatus(user),
                icon: Icon(
                  user.isActive ? Icons.block : Icons.check_circle_outline,
                  size: 18,
                ),
                label: Text(user.isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
                style: TextButton.styleFrom(
                  foregroundColor: user.isActive
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: _getRoleColor(role),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Hoạt động' : 'Khóa',
            style: TextStyle(
              color: isActive
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFFDC2626);
      case 'citizen':
        return const Color(0xFF3B82F6);
      case 'collector':
        return const Color(0xFF10B981);
      case 'enterprise':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Future<List<District>> _loadDistricts() async {
    try {
      final response = await ApiService.get(ApiConfig.districts);
      if (response.data is List) {
        return (response.data as List)
            .map((e) => District.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading districts: $e');
    }
    return [];
  }

  bool _shouldShowDistrictField(String roleName) {
    return roleName.toLowerCase() == 'enterprise';
  }

  bool _shouldShowEnterpriseField(String roleName) {
    return roleName.toLowerCase() == 'collector';
  }

  List<AdminUser> get _enterpriseUsers {
    return _users
        .where((user) => user.roleName.toLowerCase() == 'enterprise')
        .toList();
  }

  Future<void> _showCreateUserDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'Citizen';
    int? selectedDistrictId;
    int? selectedEnterpriseId;
    final districts = await _loadDistricts();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm người dùng mới'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ tên',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setDialogState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Vai trò',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: ['Admin', 'Citizen', 'Collector', 'Enterprise']
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedRole = value;
                            if (!_shouldShowDistrictField(value)) {
                              selectedDistrictId = null;
                            }
                            if (!_shouldShowEnterpriseField(value)) {
                              selectedEnterpriseId = null;
                            }
                          });
                        }
                      },
                    ),
                    if (_shouldShowDistrictField(selectedRole)) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        initialValue:
                            districts.any(
                              (district) => district.id == selectedDistrictId,
                            )
                            ? selectedDistrictId
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Quận phụ trách',
                          prefixIcon: Icon(Icons.map_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: districts
                            .map(
                              (district) => DropdownMenuItem(
                                value: district.id,
                                child: Text(district.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => selectedDistrictId = value),
                      ),
                    ],
                    if (_shouldShowEnterpriseField(selectedRole)) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        initialValue:
                            _enterpriseUsers.any(
                              (enterprise) =>
                                  enterprise.userId == selectedEnterpriseId,
                            )
                            ? selectedEnterpriseId
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Doanh nghiệp phụ trách',
                          prefixIcon: Icon(Icons.business_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: _enterpriseUsers
                            .map(
                              (enterprise) => DropdownMenuItem(
                                value: enterprise.userId,
                                child: Text(enterprise.fullName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => selectedEnterpriseId = value),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng điền đầy đủ thông tin'),
                  ),
                );
                return;
              }
              if (_shouldShowDistrictField(selectedRole) &&
                  selectedDistrictId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng chọn quận phụ trách')),
                );
                return;
              }
              if (_shouldShowEnterpriseField(selectedRole) &&
                  selectedEnterpriseId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng chọn doanh nghiệp phụ trách'),
                  ),
                );
                return;
              }

              try {
                await AdminApiService.createUser(
                  CreateUserRequest(
                    email: emailController.text,
                    fullName: nameController.text,
                    password: passwordController.text,
                    roleId: _getRoleId(selectedRole),
                    managedDistrictId: _shouldShowDistrictField(selectedRole)
                        ? selectedDistrictId
                        : null,
                    enterpriseId: _shouldShowEnterpriseField(selectedRole)
                        ? selectedEnterpriseId
                        : null,
                  ),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadUsers();
                  widget.onRefresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thêm người dùng thành công')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Thêm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditUserDialog(AdminUser user) async {
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    String selectedRole = user.roleName;
    int? selectedDistrictId = user.managedDistrictId;
    int? selectedEnterpriseId = user.enterpriseId;
    final districts = await _loadDistricts();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa thông tin người dùng'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ tên',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setDialogState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Vai trò',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: ['Admin', 'Citizen', 'Collector', 'Enterprise']
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedRole = value;
                            if (!_shouldShowDistrictField(value)) {
                              selectedDistrictId = null;
                            }
                            if (!_shouldShowEnterpriseField(value)) {
                              selectedEnterpriseId = null;
                            }
                          });
                        }
                      },
                    ),
                    if (_shouldShowDistrictField(selectedRole)) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        initialValue:
                            districts.any(
                              (district) => district.id == selectedDistrictId,
                            )
                            ? selectedDistrictId
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Quận phụ trách',
                          prefixIcon: Icon(Icons.map_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: districts
                            .map(
                              (district) => DropdownMenuItem(
                                value: district.id,
                                child: Text(district.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => selectedDistrictId = value),
                      ),
                    ],
                    if (_shouldShowEnterpriseField(selectedRole)) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        initialValue:
                            _enterpriseUsers.any(
                              (enterprise) =>
                                  enterprise.userId == selectedEnterpriseId,
                            )
                            ? selectedEnterpriseId
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Doanh nghiệp phụ trách',
                          prefixIcon: Icon(Icons.business_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: _enterpriseUsers
                            .map(
                              (enterprise) => DropdownMenuItem(
                                value: enterprise.userId,
                                child: Text(enterprise.fullName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setDialogState(() => selectedEnterpriseId = value),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_shouldShowDistrictField(selectedRole) &&
                  selectedDistrictId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng chọn quận phụ trách')),
                );
                return;
              }
              if (_shouldShowEnterpriseField(selectedRole) &&
                  selectedEnterpriseId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng chọn doanh nghiệp phụ trách'),
                  ),
                );
                return;
              }

              try {
                await AdminApiService.updateUser(
                  user.userId,
                  UpdateUserRequest(
                    email: emailController.text,
                    fullName: nameController.text,
                    roleId: _getRoleId(selectedRole),
                    managedDistrictId: _shouldShowDistrictField(selectedRole)
                        ? selectedDistrictId
                        : null,
                    enterpriseId: _shouldShowEnterpriseField(selectedRole)
                        ? selectedEnterpriseId
                        : null,
                  ),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadUsers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cập nhật thành công')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserStatus(AdminUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          user.isActive ? 'Vô hiệu hóa người dùng' : 'Kích hoạt người dùng',
        ),
        content: Text(
          user.isActive
              ? 'Bạn có chắc muốn vô hiệu hóa người dùng "${user.fullName}"?'
              : 'Bạn có chắc muốn kích hoạt người dùng "${user.fullName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF10B981),
            ),
            child: Text(
              user.isActive ? 'Vô hiệu hóa' : 'Kích hoạt',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (user.isActive) {
          await AdminApiService.deactivateUser(user.userId);
        } else {
          await AdminApiService.activateUser(user.userId);
        }
        _loadUsers();
        widget.onRefresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                user.isActive
                    ? 'Đã vô hiệu hóa người dùng'
                    : 'Đã kích hoạt người dùng',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }

  int _getRoleId(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return AppRoles.admin;
      case 'citizen':
        return AppRoles.citizen;
      case 'collector':
        return AppRoles.collector;
      case 'enterprise':
        return AppRoles.enterprise;
      default:
        return AppRoles.citizen;
    }
  }
}
