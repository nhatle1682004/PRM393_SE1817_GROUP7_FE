import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:waste_collection_management_system/data/models/waste_type.dart';
import 'package:waste_collection_management_system/presentation/admin/widgets/pagination_controls.dart';
import 'package:waste_collection_management_system/services/admin_api_service.dart';

class WasteTypesView extends StatefulWidget {
  const WasteTypesView({super.key});

  @override
  State<WasteTypesView> createState() => _WasteTypesViewState();
}

class _WasteTypesViewState extends State<WasteTypesView> {
  List<WasteType> _types = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  String _status = 'All';
  int _page = 0;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  List<WasteType> get _filtered {
    final query = _search.toLowerCase();
    return _types.where((type) {
      final matchesSearch = type.name.toLowerCase().contains(query) ||
          type.nameVi.toLowerCase().contains(query) ||
          (type.description?.toLowerCase().contains(query) ?? false);
      final matchesStatus = _status == 'All' ||
          (_status == 'Active' && type.isActive) ||
          (_status == 'Inactive' && !type.isActive);
      return matchesSearch && matchesStatus;
    }).toList();
  }

  List<WasteType> get _paged {
    final start = _page * _pageSize;
    if (start >= _filtered.length) return [];
    final end = start + _pageSize > _filtered.length ? _filtered.length : start + _pageSize;
    return _filtered.sublist(start, end);
  }

  Future<void> _loadTypes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final types = await AdminApiService.getWasteTypes();
      if (!mounted) return;
      setState(() {
        _types = types;
        _page = 0;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _toolbar(),
        Expanded(child: _content()),
      ],
    );
  }

  Widget _toolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() {
                _search = value;
                _page = 0;
              }),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm loại rác...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: _status,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('Tất cả')),
              DropdownMenuItem(value: 'Active', child: Text('Hoạt động')),
              DropdownMenuItem(value: 'Inactive', child: Text('Đã tắt')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _status = value;
                _page = 0;
              });
            },
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _showWasteTypeDialog(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tạo loại rác'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: _loadTypes, icon: const Icon(Icons.refresh), tooltip: 'Tải lại'),
        ],
      ),
    );
  }

  Widget _content() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
    if (_error != null) return _errorView();
    if (_filtered.isEmpty) return Center(child: Text('Không tìm thấy loại rác nào', style: TextStyle(color: Colors.grey.shade600)));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _header(),
                  ..._paged.map(_row),
                ],
              ),
            ),
          ),
        ),
        PaginationControls(
          currentPage: _page,
          totalItems: _filtered.length,
          pageSize: _pageSize,
          onPageChanged: (page) => setState(() => _page = page),
        ),
      ],
    );
  }

  Widget _header() {
    const style = TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B));
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF8FAFC),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('Tên loại rác', style: style)),
          Expanded(flex: 3, child: Text('Mô tả', style: style)),
          Expanded(child: Text('Điểm', style: style)),
          Expanded(child: Text('Trạng thái', style: style)),
          SizedBox(width: 96, child: Text('Hành động', style: style)),
        ],
      ),
    );
  }

  Widget _row(WasteType type) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(type.icon ?? Icons.delete_outline, color: type.color ?? const Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(child: Text(type.nameVi.isEmpty ? type.name : type.nameVi, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(flex: 3, child: Text(type.description ?? '-', overflow: TextOverflow.ellipsis)),
          Expanded(child: Text('${type.rewardPoints}')),
          Expanded(child: _chip(type.isActive ? 'Hoạt động' : 'Đã tắt', type.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
          SizedBox(
            width: 96,
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Sửa',
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: const Color(0xFF3B82F6),
                  onPressed: () => _showWasteTypeDialog(type: type),
                ),
                IconButton(
                  tooltip: 'Xóa',
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: const Color(0xFFEF4444),
                  onPressed: () => _deleteWasteType(type),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showWasteTypeDialog({WasteType? type}) async {
    final isEdit = type != null;
    final nameController = TextEditingController(text: type?.name ?? '');
    final descriptionController = TextEditingController(text: type?.description ?? '');
    final pointsController = TextEditingController(text: type?.rewardPoints.toString() ?? '');
    bool isActive = type?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Sửa loại rác' : 'Tạo loại rác'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên loại rác', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: descriptionController, maxLines: 2, decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: pointsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Điểm thưởng', border: OutlineInputBorder())),
                if (isEdit)
                  SwitchListTile(
                    value: isActive,
                    onChanged: (value) => setDialogState(() => isActive = value),
                    title: const Text('Đang hoạt động'),
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                final points = int.tryParse(pointsController.text.trim());
                if (nameController.text.trim().isEmpty || points == null || points < 0) {
                  CherryToast.warning(
                    title: const Text('Thông báo'),
                    description: const Text('Vui lòng nhập tên và điểm hợp lệ'),
                    animationType: AnimationType.fromRight,
                    autoDismiss: true,
                  ).show(context);
                  return;
                }
                try {
                  if (isEdit) {
                    await AdminApiService.updateWasteType(
                      type.id,
                      UpdateWasteTypeRequest(
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                        rewardPoints: points,
                        isActive: isActive,
                      ),
                    );
                  } else {
                    await AdminApiService.createWasteType(
                      CreateWasteTypeRequest(
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                        rewardPoints: points,
                      ),
                    );
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                    await _loadTypes();
                    if (context.mounted) {
                      CherryToast.success(
                        title: const Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
                        description: Text(isEdit ? 'Đã cập nhật loại rác' : 'Đã tạo loại rác'),
                        animationType: AnimationType.fromRight,
                        autoDismiss: true,
                      ).show(context);
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    CherryToast.error(
                      title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
                      description: Text('Lỗi: $e'),
                      animationType: AnimationType.fromRight,
                      autoDismiss: true,
                    ).show(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: Text(isEdit ? 'Lưu' : 'Tạo', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteWasteType(WasteType type) async {
    final name = type.nameVi.isEmpty ? type.name : type.nameVi;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa loại rác'),
        content: Text('Bạn có chắc muốn xóa/tắt "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await AdminApiService.deleteWasteType(type.id);
      await _loadTypes();
      if (mounted) {
        CherryToast.success(
          title: const Text('Thành công', style: TextStyle(fontWeight: FontWeight.bold)),
          description: const Text('Đã xóa/tắt loại rác'),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        CherryToast.error(
          title: const Text('Lỗi', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text('Lỗi: $e'),
          animationType: AnimationType.fromRight,
          autoDismiss: true,
        ).show(context);
      }
    }
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 48),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loadTypes, child: const Text('Thử lại')),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }
}
