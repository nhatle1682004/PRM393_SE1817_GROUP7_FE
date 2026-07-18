import 'package:flutter/material.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:waste_collection_management_system/data/models/district_model.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';
import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/services/enterprise_api_service.dart';
import 'package:waste_collection_management_system/config/api_config.dart';
import 'collectors_widgets.dart';

class CollectorsView extends StatefulWidget {
  const CollectorsView({super.key});
  @override
  State<CollectorsView> createState() => _CollectorsViewState();
}

class _CollectorsViewState extends State<CollectorsView> {
  List<EnterpriseCollector> _collectors = [];
  List<District> _districts = [];
  bool _isLoading = true;
  int _page = 1;
  final int _size = 10;
  String _status = 'All', _avail = 'All';

  @override
  void initState() { super.initState(); _load(); _loadDistricts(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await EnterpriseApiService.getCollectors();
      if (mounted) setState(() { _collectors = res; _isLoading = false; });
    } catch (_) { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _loadDistricts() async {
    try {
      final res = await ApiService.get(ApiConfig.districts);
      if (res.data is List) _districts = (res.data as List).map((e) => District.fromJson(e)).toList();
    } catch (_) {}
  }

  List<EnterpriseCollector> get _filtered => _collectors.where((c) {
    if (_status != 'All' && (c.status == 'Active') != (_status == 'Active')) return false;
    if (_avail != 'All' && c.isAvailable != (_avail == 'Available')) return false;
    return true;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final paged = filtered.skip((_page - 1) * _size).take(_size).toList();
    final totalPages = (filtered.length / _size).ceil();

    return Column(children: [
      _buildHeader(),
      Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : (filtered.isEmpty ? const Center(child: Text('Không có dữ liệu')) : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Card(child: SizedBox(width: double.infinity, child: DataTable(columns: const [DataColumn(label: Text('STT')), DataColumn(label: Text('Họ tên')), DataColumn(label: Text('Email')), DataColumn(label: Text('SĐT')), DataColumn(label: Text('Trạng thái')), DataColumn(label: Text('Hành động'))], rows: paged.asMap().entries.map((e) => buildCollectorDataRow(collector: e.value, index: (_page - 1) * _size + e.key + 1, onEdit: (c) => _showForm(collector: c), onDelete: _delete, onToggle: _toggle)).toList()))),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: _page > 1 ? () => setState(() => _page--) : null),
          Text('$_page / $totalPages'),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: _page < totalPages ? () => setState(() => _page++) : null),
        ]),
      ])))),
    ]);
  }

  Widget _buildHeader() => Container(padding: const EdgeInsets.all(12), color: Colors.white, child: Row(children: [
    _drop('Trạng thái', _status, ['All', 'Active', 'Inactive'], (v) => setState(() => _status = v!)),
    const SizedBox(width: 12),
    _drop('Khả dụng', _avail, ['All', 'Available', 'Busy'], (v) => setState(() => _avail = v!)),
    const Spacer(),
    ElevatedButton(onPressed: () => _showForm(), child: const Text('Thêm nhân viên')),
    IconButton(onPressed: _load, icon: const Icon(Icons.refresh, color: Colors.green)),
  ]));

  Widget _drop(String l, String v, List<String> items, Function(String?) onC) => DropdownButton<String>(value: v, items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(), onChanged: onC);

  void _showForm({EnterpriseCollector? collector}) => showGeneralDialog(context: context, pageBuilder: (c, a, s) => Align(alignment: Alignment.centerRight, child: CollectorFormSideSheet(collector: collector, districts: _districts, onSubmit: (data) async {
    try {
      if (collector == null) {
        await EnterpriseApiService.createCollector(data);
      } else {
        await EnterpriseApiService.updateCollector(collector.collectorId, data);
      }
      if (!mounted) return;
      Navigator.pop(context);
      _load();
    } catch (e) {
      if (!mounted) return;
      CherryToast.error(title: Text('$e')).show(context);
    }
  })));

  Future<void> _delete(EnterpriseCollector c) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Xóa?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Không')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Có'))]));
    if (ok == true) {
      try {
        await EnterpriseApiService.deleteCollector(c.collectorId);
        _load();
      } catch (e) {
        if (!mounted) return;
        CherryToast.error(title: Text('$e')).show(context);
      }
    }
  }

  Future<void> _toggle(EnterpriseCollector c) async {
    try {
      if (c.status == 'Active') {
        await EnterpriseApiService.softDeleteCollector(c.collectorId);
      } else {
        await EnterpriseApiService.reactivateCollector(c.collectorId);
      }
      _load();
    } catch (e) {
      if (!mounted) return;
      CherryToast.error(title: Text('$e')).show(context);
    }
  }
}
