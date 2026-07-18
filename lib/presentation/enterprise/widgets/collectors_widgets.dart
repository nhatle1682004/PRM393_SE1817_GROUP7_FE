import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waste_collection_management_system/data/models/enterprise_models.dart';

DataRow buildCollectorDataRow({
  required EnterpriseCollector collector,
  required int index,
  required Function(EnterpriseCollector) onEdit,
  required Function(EnterpriseCollector) onDelete,
  required Function(EnterpriseCollector) onToggle,
}) {
  final active = collector.status == 'Active';
  final color = active ? Colors.green : Colors.grey;
  return DataRow(cells: [
    DataCell(Text('$index')),
    DataCell(Text(collector.fullName ?? 'N/A')),
    DataCell(Text(collector.email ?? 'N/A')),
    DataCell(Text(collector.phone ?? 'N/A')),
    DataCell(Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        active ? "Hoạt động" : "Tạm dừng",
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    )),
    DataCell(Row(children: [
      IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
        onPressed: () => onEdit(collector),
      ),
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
        onPressed: () => onDelete(collector),
      ),
      Switch(
        value: active,
        activeThumbColor: Colors.green,
        onChanged: (_) => onToggle(collector),
      ),
    ])),
  ]);
}

class CollectorFormSideSheet extends StatefulWidget {
  final EnterpriseCollector? collector;
  final List<dynamic> districts;
  final Function(dynamic data) onSubmit;

  const CollectorFormSideSheet({super.key, this.collector, required this.districts, required this.onSubmit});

  @override
  State<CollectorFormSideSheet> createState() => _CollectorFormSideSheetState();
}

class _CollectorFormSideSheetState extends State<CollectorFormSideSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _email, _phone, _pass;
  int? _districtId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.collector?.fullName);
    _email = TextEditingController(text: widget.collector?.email);
    _phone = TextEditingController(text: widget.collector?.phone);
    _pass = TextEditingController();
    _districtId = widget.collector?.managedDistrictId;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.collector != null;
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(isEdit ? 'Sửa thông tin' : 'Thêm nhân viên', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
            const Divider(),
            Expanded(
              child: ListView(children: [
                _field(_name, 'Họ tên', Icons.person, (v) => v!.isEmpty ? 'Nhập tên' : null),
                _field(_email, 'Email', Icons.email, (v) => v!.contains('@') ? null : 'Email lỗi'),
                _field(_phone, 'SĐT', Icons.phone, (v) => v!.length < 10 ? 'SĐT lỗi' : null, input: [FilteringTextInputFormatter.digitsOnly]),
                if (!isEdit) _field(_pass, 'Mật khẩu', Icons.lock, (v) => v!.length < 6 ? 'Ít nhất 6 ký tự' : null, obscure: true),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  value: _districtId,
                  decoration: _decor('Khu vực', Icons.map),
                  items: widget.districts.map<DropdownMenuItem<int>>((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                  onChanged: (v) => setState(() => _districtId = v),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading ? const CircularProgressIndicator() : Text(isEdit ? 'Cập nhật' : 'Thêm mới'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String l, IconData i, String? Function(String?)? v, {bool obscure = false, List<TextInputFormatter>? input}) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(controller: c, decoration: _decor(l, i), obscureText: obscure, validator: v, inputFormatters: input),
  );

  InputDecoration _decor(String l, IconData i) => InputDecoration(labelText: l, prefixIcon: Icon(i, color: Colors.green), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final data = widget.collector != null ? UpdateCollectorRequest(fullName: _name.text, email: _email.text, phone: _phone.text, status: widget.collector!.status, managedDistrictId: _districtId) : CreateCollectorRequest(fullName: _name.text, email: _email.text, phone: _phone.text, password: _pass.text, managedDistrictId: _districtId);
      await widget.onSubmit(data);
    } finally { if (mounted) setState(() => _loading = false); }
  }
}
