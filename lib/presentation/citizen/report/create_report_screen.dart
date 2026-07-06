import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:waste_collection_management_system/data/models/waste_type.dart';
import 'package:waste_collection_management_system/services/location_service.dart';
import 'package:waste_collection_management_system/services/waste_report_service.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _service = WasteReportService();
  final _locationService = LocationService();
  final _description = TextEditingController();
  final _picker = ImagePicker();
  List<WasteType> _types = const [];
  final Set<int> _selectedTypeIds = {};
  File? _image;
  XFile? _webImage;
  Position? _position;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _loadTypes() async {
    try {
      _types = await _service.getWasteTypes();
    } catch (e) {
      _show(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1400,
    );
    if (file == null) return;
    setState(() {
      _webImage = file;
      _image = kIsWeb ? null : File(file.path);
    });
  }

  Future<void> _locate() async {
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() => _position = position);
    } catch (e) {
      _show(e.toString());
    }
  }

  Future<void> _submit() async {
    if (_image == null && _webImage == null) return _show('Vui lòng chọn ảnh.');
    if (_position == null) return _show('Vui lòng lấy vị trí.');
    if (_selectedTypeIds.isEmpty)
      return _show('Vui lòng chọn ít nhất một loại rác.');
    final latitude = _position!.latitude;
    final longitude = _position!.longitude;
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return _show('Latitude/Longitude không hợp lệ.');
    }

    setState(() => _submitting = true);
    try {
      await _service.createReport(
        imageFile: _image,
        webImageFile: _webImage,
        latitude: latitude,
        longitude: longitude,
        description: _description.text.trim(),
        wasteTypeIds: _selectedTypeIds.toList(),
      );
      _description.clear();
      setState(() {
        _image = null;
        _webImage = null;
        _position = null;
        _selectedTypeIds.clear();
      });
      _show('Đã gửi báo cáo thành công.');
    } catch (e) {
      _show(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Tạo báo cáo rác',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _description,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Mô tả',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: _types.map((type) {
            final selected = _selectedTypeIds.contains(type.wasteTypeId);
            return FilterChip(
              label: Text('${type.name} (+${type.rewardPoints})'),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  selected
                      ? _selectedTypeIds.remove(type.wasteTypeId)
                      : _selectedTypeIds.add(type.wasteTypeId);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: Text(_webImage == null ? 'Chọn ảnh' : _webImage!.name),
            ),
            OutlinedButton.icon(
              onPressed: _locate,
              icon: const Icon(Icons.my_location),
              label: Text(
                _position == null
                    ? 'Lấy vị trí'
                    : '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          label: const Text('Gửi báo cáo'),
        ),
      ],
    );
  }
}
