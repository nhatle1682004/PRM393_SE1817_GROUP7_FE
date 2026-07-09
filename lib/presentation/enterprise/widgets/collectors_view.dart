import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:waste_collection_management_system/data/models/district_model.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';
import 'package:waste_collection_management_system/config/api_config.dart';

class CollectorsView extends StatefulWidget {
  const CollectorsView({super.key});

  @override
  State<CollectorsView> createState() => _CollectorsViewState();
}

class _CollectorsViewState extends State<CollectorsView> {
  List<EnterpriseCollector> _collectors = [];
  bool _isLoading = true;
  String? _error;

  // Pagination state
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  // Filter state
  String _statusFilter = 'All'; // All, Active, Inactive
  String _availabilityFilter = 'All'; // All, Available, Busy

  @override
  void initState() {
    super.initState();
    _loadCollectors();
  }

  Future<void> _loadCollectors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final collectors = await EnterpriseApiService.getCollectors();
      if (mounted) {
        setState(() {
          _collectors = collectors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<EnterpriseCollector> get _filteredCollectors {
    return _collectors.where((c) {
      bool matchesStatus = true;
      if (_statusFilter == 'Active') matchesStatus = c.status == 'Active';
      if (_statusFilter == 'Inactive') matchesStatus = c.status != 'Active';

      bool matchesAvailability = true;
      if (_availabilityFilter == 'Available') matchesAvailability = c.isAvailable;
      if (_availabilityFilter == 'Busy') matchesAvailability = !c.isAvailable;

      return matchesStatus && matchesAvailability;
    }).toList();
  }

  List<EnterpriseCollector> get _pagedCollectors {
    final filtered = _filteredCollectors;
    int start = (_currentPage - 1) * _itemsPerPage;
    int end = start + _itemsPerPage;
    if (start >= filtered.length) return [];
    return filtered.sublist(
      start,
      end > filtered.length ? filtered.length : end,
    );
  }

  int get _totalPages => (_filteredCollectors.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 700;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: isMobile 
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilters(isMobile),
                  const SizedBox(height: 12),
                  _buildActions(isMobile),
                ],
              )
            : Row(
                children: [
                  _buildFilters(isMobile),
                  const Spacer(),
                  _buildActions(isMobile),
                ],
              ),
        );
      },
    );
  }

  Widget _buildFilters(bool isMobile) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildFilterDropdown(
          label: 'Trạng thái',
          value: _statusFilter,
          items: const [
            DropdownMenuItem(value: 'All', child: Text('Tất cả trạng thái')),
            DropdownMenuItem(value: 'Active', child: Text('Hoạt động')),
            DropdownMenuItem(value: 'Inactive', child: Text('Tạm dừng')),
          ],
          onChanged: (val) => setState(() {
            _statusFilter = val!;
            _currentPage = 1;
          }),
        ),
        _buildFilterDropdown(
          label: 'Sẵn sàng',
          value: _availabilityFilter,
          items: const [
            DropdownMenuItem(value: 'All', child: Text('Tất cả khả dụng')),
            DropdownMenuItem(value: 'Available', child: Text('Sẵn sàng')),
            DropdownMenuItem(value: 'Busy', child: Text('Đang bận')),
          ],
          onChanged: (val) => setState(() {
            _availabilityFilter = val!;
            _currentPage = 1;
          }),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
        ),
      ),
    );
  }

  Widget _buildActions(bool isMobile) {
    return Row(
      mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: isMobile ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showCollectorForm(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Thêm nhân viên'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _loadCollectors,
          icon: const Icon(Icons.refresh, color: Color(0xFF10B981)),
          tooltip: 'Làm mới',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
            padding: const EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_collectors.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Khối bảng dữ liệu trong Card
              Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981), width: 2.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Chống tràn ngang trên Mobile
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth - 4,
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFF0FDF4)),
                          dataRowMaxHeight: 64,
                          headingRowHeight: 56,
                          horizontalMargin: 20,
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text('STT', style: _headerStyle)),
                            DataColumn(label: Text('Tên nhân viên', style: _headerStyle)),
                            DataColumn(label: Text('Email', style: _headerStyle)),
                            DataColumn(label: Text('Số điện thoại', style: _headerStyle)),
                            DataColumn(label: Text('Trạng thái', style: _headerStyle)),
                            DataColumn(label: Text('Hành động', style: _headerStyle)),
                          ],
                          rows: _pagedCollectors.asMap().entries.map((entry) {
                            int index = entry.key;
                            EnterpriseCollector collector = entry.value;
                            int displayStt = ((_currentPage - 1) * _itemsPerPage) + index + 1;
                            return _buildDataRow(collector, displayStt);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Thanh điều hướng phân trang
              _buildPaginationControls(),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(EnterpriseCollector collector, int stt) {
    final bool isActive = collector.status == 'Active';
    return DataRow(
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('$stt', style: _contentStyle),
          ),
        ),
        DataCell(
          Text(collector.fullName ?? 'N/A', style: _contentStyle),
        ),
        DataCell(Text(collector.email ?? 'N/A', style: _contentStyle)),
        DataCell(Text(collector.phone ?? 'N/A', style: _contentStyle)),
        DataCell(_buildStatusBadge(isActive)),
        DataCell(_buildActionButtons(collector)),
      ],
    );
  }

  Widget _buildAvatar(String name, int stt) {
    final initials = name.split(' ').where((s) => s.isNotEmpty).take(2).map((s) => s[0]).join().toUpperCase();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? stt.toString() : initials,
          style: const TextStyle(
            color: Color(0xFF059669),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    final color = isActive ? const Color(0xFF10B981) : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        isActive ? "Hoạt động" : "Tạm dừng",
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildActionButtons(EnterpriseCollector collector) {
    final bool isActive = collector.status == 'Active';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
          onPressed: () => _showCollectorForm(collector: collector),
          tooltip: 'Sửa',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          onPressed: () => _deleteCollector(collector),
          tooltip: 'Xóa',
        ),
        const SizedBox(width: 4),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: isActive,
            activeColor: const Color(0xFF10B981),
            activeTrackColor: const Color(0xFF10B981).withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
            onChanged: (value) => _toggleCollectorStatus(collector),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls() {
    bool isFirstPage = _currentPage == 1;
    bool isLastPage = _currentPage == _totalPages || _totalPages == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNavButton(
          icon: Icons.chevron_left,
          isDisabled: isFirstPage,
          onTap: () => setState(() => _currentPage--),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Text(
            '$_currentPage',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        const SizedBox(width: 16),
        _buildNavButton(
          icon: Icons.chevron_right,
          isDisabled: isLastPage,
          onTap: () => setState(() => _currentPage++),
        ),
      ],
    );
  }

  Widget _buildNavButton({required IconData icon, required bool isDisabled, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Icon(icon, color: const Color(0xFF10B981)),
        ),
      ),
    );
  }

  // --- Common Widget Helpers ---

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error ?? 'Đã xảy ra lỗi'),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadCollectors, child: const Text('Thử lại')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Chưa có nhân viên nào', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // --- Logic Helpers (Forms, Dialogs) ---

  void _showBusinessErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Thông báo', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF10B981),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCollectorStatus(EnterpriseCollector collector) async {
    final bool isActive = collector.status == 'Active';
    final String title = isActive ? 'Tạm dừng nhân viên' : 'Kích hoạt nhân viên';
    final String content = isActive 
        ? 'Bạn có muốn tạm dừng hoạt động nhân viên ${collector.fullName}? Tài khoản này sẽ chuyển sang trạng thái "Tạm dừng".'
        : 'Bạn có muốn kích hoạt lại nhân viên ${collector.fullName}?';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.orange : const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: Text(isActive ? 'Tạm dừng' : 'Kích hoạt'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (isActive) {
          await EnterpriseApiService.softDeleteCollector(collector.collectorId);
        } else {
          await EnterpriseApiService.reactivateCollector(collector.collectorId);
        }

        // CẬP NHẬT LOCAL STATE NGAY LẬP TỨC ĐỂ UI PHẢN HỒI
        if (mounted) {
          setState(() {
            final index = _collectors.indexWhere((c) => c.collectorId == collector.collectorId);
            if (index != -1) {
              _collectors[index] = _collectors[index].copyWith(
                status: isActive ? 'Inactive' : 'Active'
              );
            }
          });

          CherryToast.success(
            title: const Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
            description: const Text('Cập nhật trạng thái thành công'),
            animationType: AnimationType.fromRight,
            animationDuration: const Duration(milliseconds: 1000),
            autoDismiss: true,
          ).show(context);
        }
      } catch (e) {
        if (mounted) {
          final errorMsg = e.toString().toLowerCase();
          // Kiểm tra xem có phải lỗi nghiệp vụ không
          if (errorMsg.contains('assigned') || 
              errorMsg.contains('report') || 
              errorMsg.contains('báo cáo') || 
              errorMsg.contains('lịch thu gom') ||
              errorMsg.contains('hoàn thành') ||
              errorMsg.contains('đang được gán')) {
            _showBusinessErrorDialog(e.toString());
          } else {
            CherryToast.error(
              title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
              description: Text('Lỗi: $e'),
              animationType: AnimationType.fromRight,
              animationDuration: const Duration(milliseconds: 1000),
              autoDismiss: true,
            ).show(context);
          }
        }
      }
    }
  }

  Future<void> _showCollectorForm({EnterpriseCollector? collector}) async {
    final isEditing = collector != null;
    final fullNameController = TextEditingController(text: collector?.fullName);
    final emailController = TextEditingController(text: collector?.email);
    final phoneController = TextEditingController(text: collector?.phone);
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;
    List<District> districts = [];
    int? selectedDistrictId = collector?.managedDistrictId;

    // Load districts for dropdown
    try {
      final response = await ApiService.get(ApiConfig.districts);
      if (response.data is List) {
        districts = (response.data as List).map((e) => District.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading districts: $e');
    }

    if (mounted) {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Close',
        barrierColor: Colors.black.withOpacity(0.4),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: MediaQuery.of(context).size.width > 500 ? 400 : MediaQuery.of(context).size.width * 0.85,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.24), blurRadius: 10, offset: const Offset(-5, 0))],
            ),
            child: Material(
              color: Colors.transparent,
              child: StatefulBuilder(
                builder: (context, setModalState) => Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isEditing ? 'Sửa thông tin' : 'Thêm nhân viên mới',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.grey),
                              style: IconButton.styleFrom(backgroundColor: Colors.grey.withOpacity(0.1)),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      
                      // Form Fields
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Thông tin cơ bản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 20),
                              _buildFormTextField(
                                controller: fullNameController,
                                label: 'Họ và tên',
                                icon: Icons.person_outline,
                                validator: (value) => value == null || value.isEmpty ? 'Vui lòng nhập họ tên' : null,
                              ),
                              const SizedBox(height: 18),
                              _buildFormTextField(
                                controller: emailController,
                                label: 'Email',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value == null || !value.contains('@') ? 'Email không hợp lệ' : null,
                              ),
                              const SizedBox(height: 18),
                              _buildFormTextField(
                                controller: phoneController,
                                label: 'Số điện thoại',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                                validator: (value) => value == null || value.length < 10 ? 'SĐT không hợp lệ' : null,
                              ),
                              
                              if (!isEditing) ...[
                                const SizedBox(height: 18),
                                _buildFormTextField(
                                  controller: passwordController,
                                  label: 'Mật khẩu',
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: (value) => value == null || value.length < 6 ? 'Mật khẩu ít nhất 6 ký tự' : null,
                                ),
                              ],

                              const SizedBox(height: 32),
                              const Text('Nghiệp vụ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<int>(
                                value: selectedDistrictId,
                                decoration: _inputDecoration('Khu vực phụ trách', Icons.map_outlined),
                                items: districts.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                                onChanged: (val) => setModalState(() => selectedDistrictId = val),
                                style: const TextStyle(fontSize: 14, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Footer Buttons
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: isSubmitting ? null : () async {
                                  if (formKey.currentState!.validate()) {
                                    setModalState(() => isSubmitting = true);
                                    try {
                                      if (isEditing) {
                                        await EnterpriseApiService.updateCollector(collector.collectorId, UpdateCollectorRequest(
                                          fullName: fullNameController.text,
                                          email: emailController.text,
                                          phone: phoneController.text,
                                          status: collector.status,
                                          managedDistrictId: selectedDistrictId,
                                        ));
                                      } else {
                                        await EnterpriseApiService.createCollector(CreateCollectorRequest(
                                          fullName: fullNameController.text.trim(),
                                          email: emailController.text.trim(),
                                          phone: phoneController.text.trim(),
                                          password: passwordController.text,
                                          managedDistrictId: selectedDistrictId,
                                        ));
                                      }
                                      if (mounted) {
                                        Navigator.pop(context);
                                        _loadCollectors();
                                        CherryToast.success(
                                          title: const Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
                                          description: Text(isEditing ? 'Cập nhật thành công' : 'Thêm nhân viên thành công'),
                                          animationType: AnimationType.fromRight,
                                          autoDismiss: true,
                                        ).show(context);
                                      }
                                    } catch (e) {
                                      setModalState(() => isSubmitting = false);
                                      if (mounted) {
                                        final errorMsg = e.toString();
                                        if (errorMsg.contains('assigned') || errorMsg.contains('report')) {
                                          _showBusinessErrorDialog(errorMsg);
                                        } else {
                                          CherryToast.error(
                                            title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
                                            description: Text(errorMsg),
                                            animationType: AnimationType.fromRight,
                                            autoDismiss: true,
                                          ).show(context);
                                        }
                                      }
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: isSubmitting 
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                                  : Text(isEditing ? 'Cập nhật' : 'Thêm mới', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Hủy bỏ', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
            child: child,
          );
        },
      );
    }
  }

  Widget _buildFormTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 14),
      decoration: _inputDecoration(label, icon),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF10B981)),
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5)),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF10B981), size: 20),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _deleteCollector(EnterpriseCollector collector) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa nhân viên ${collector.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Xóa')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await EnterpriseApiService.deleteCollector(collector.collectorId);
        _loadCollectors();
        if (mounted) {
          CherryToast.success(
            title: const Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
            description: const Text('Xóa nhân viên thành công'),
            animationType: AnimationType.fromRight,
            animationDuration: const Duration(milliseconds: 1000),
            autoDismiss: true,
          ).show(context);
        }
      } catch (e) {
        if (mounted) {
          final errorMsg = e.toString().toLowerCase();
          // Kiểm tra lỗi nghiệp vụ: không được xóa nếu đang xử lý báo cáo
          if (errorMsg.contains('assigned') || 
              errorMsg.contains('report') || 
              errorMsg.contains('báo cáo') || 
              errorMsg.contains('lịch thu gom') ||
              errorMsg.contains('hoàn thành') ||
              errorMsg.contains('đang được gán')) {
            _showBusinessErrorDialog(e.toString());
          } else if (errorMsg.contains('404')) {
            CherryToast.error(
              title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
              description: const Text('Lỗi: Không tìm thấy nhân viên hoặc đường dẫn API (404)'),
              animationType: AnimationType.fromRight,
              animationDuration: const Duration(milliseconds: 1000),
              autoDismiss: true,
            ).show(context);
          } else {
            CherryToast.error(
              title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
              description: Text('Lỗi: $e'),
              animationType: AnimationType.fromRight,
              animationDuration: const Duration(milliseconds: 1000),
              autoDismiss: true,
            ).show(context);
          }
        }
      }
    }
  }

  // --- Styles ---

  static const _headerStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Color(0xFF1F2937),
    fontSize: 14,
  );

  static const _contentStyle = TextStyle(
    color: Color(0xFF1F2937),
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}
