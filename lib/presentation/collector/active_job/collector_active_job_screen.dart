import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:waste_collection_management_system/data/models/assignment.dart';
import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/services/assignment_service.dart';
import 'package:waste_collection_management_system/services/collection_service.dart';

class CollectorActiveJobScreen extends StatefulWidget {
  const CollectorActiveJobScreen({super.key});

  @override
  State<CollectorActiveJobScreen> createState() =>
      _CollectorActiveJobScreenState();
}

class _CollectorActiveJobScreenState extends State<CollectorActiveJobScreen> {
  final _assignments = AssignmentService();
  final _collection = CollectionService();
  final _picker = ImagePicker();
  bool _loading = true;
  Assignment? _job;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _assignments.getMyAssignments();
      _job = items.where((a) => a.isActive).cast<Assignment?>().firstOrNull;
    } catch (e) {
      _show(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _action(Future<void> Function() call) async {
    try {
      await call();
      await _load();
    } catch (e) {
      _show(e.toString());
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
    final job = _job;
    if (job == null) {
      return const Center(child: Text('Không có job đang hoạt động.'));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (job.reportImageUrl.isNotEmpty)
          Image.network(
            ApiService.buildFileUrl(job.reportImageUrl),
            height: 220,
            fit: BoxFit.cover,
          ),
        const SizedBox(height: 16),
        Text(
          'Assignment #${job.assignmentId} · ${job.status}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(job.description),
        Text('Vị trí: ${job.latitude}, ${job.longitude}'),
        Text('Citizen: ${job.citizenName} ${job.citizenPhone}'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (job.status == 'Assigned')
              FilledButton(
                onPressed: () => _action(
                  () => _collection.startCollection(job.assignmentId),
                ),
                child: const Text('Start collection'),
              ),
            if (job.status == 'Assigned')
              OutlinedButton(
                onPressed: () => _action(
                  () => _collection.declineAssignment(
                    job.assignmentId,
                    'Collector declined',
                  ),
                ),
                child: const Text('Decline'),
              ),
            if (job.status == 'OnTheWay')
              FilledButton(
                onPressed: () => _arrived(job),
                child: const Text('Confirm arrived'),
              ),
            if (job.status == 'Arrived')
              FilledButton(
                onPressed: () => _complete(job),
                child: const Text('Complete'),
              ),
            if (job.status == 'Arrived')
              OutlinedButton(
                onPressed: () => _reportIssue(job),
                child: const Text('Report issue'),
              ),
          ],
        ),
      ],
    );
  }

  Future<XFile?> _pickImage() => _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
    maxWidth: 1400,
  );

  File? _mobileFile(XFile? file) =>
      !kIsWeb && file != null ? File(file.path) : null;

  XFile? _webFile(XFile? file) => kIsWeb ? file : null;

  Future<void> _arrived(Assignment job) async {
    final image = await _pickImage();
    if (image == null) return;
    await _action(
      () => _collection.arrived(
        assignmentId: job.assignmentId,
        beforeImage: _mobileFile(image),
        webBeforeImage: _webFile(image),
        note: 'Arrived',
      ),
    );
  }

  Future<void> _complete(Assignment job) async {
    final image = await _pickImage();
    if (image == null) return;
    final weight = await _askText(
      title: 'Khối lượng thực tế',
      initialValue: '1',
    );
    final actualWeight = double.tryParse(weight ?? '');
    if (actualWeight == null || actualWeight <= 0) {
      _show('Actual weight phải > 0.');
      return;
    }

    var wasteTypeId = job.wasteTypeIds.isNotEmpty ? job.wasteTypeIds.first : 0;
    if (wasteTypeId <= 0) {
      final wasteType = await _askText(title: 'WasteTypeId', initialValue: '1');
      wasteTypeId = int.tryParse(wasteType ?? '') ?? 0;
    }
    if (wasteTypeId <= 0) {
      _show('WasteTypeId phải > 0.');
      return;
    }

    await _action(
      () => _collection.complete(
        assignmentId: job.assignmentId,
        afterImage: _mobileFile(image),
        webAfterImage: _webFile(image),
        wasteTypeId: wasteTypeId,
        weight: actualWeight,
        note: 'Completed',
      ),
    );
  }

  Future<void> _reportIssue(Assignment job) async {
    final issueTypes = [
      'WasteNotFound',
      'WrongAddress',
      'WasteTypeMismatch',
      'CitizenUnavailable',
      'Other',
    ];
    final issueType = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Chọn issue type'),
        children: issueTypes
            .map(
              (type) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, type),
                child: Text(type),
              ),
            )
            .toList(),
      ),
    );
    if (issueType == null) return;
    final description = await _askText(
      title: 'Mô tả sự cố',
      initialValue: issueType,
    );
    if (description == null || description.isEmpty) return;
    final image = await _pickImage();
    await _action(
      () => _collection.reportIssue(
        assignmentId: job.assignmentId,
        issueType: issueType,
        issueDescription: description,
        issueImage: _mobileFile(image),
        webIssueImage: _webFile(image),
      ),
    );
  }

  Future<String?> _askText({
    required String title,
    String initialValue = '',
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}
