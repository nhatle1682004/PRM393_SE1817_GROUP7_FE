import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:waste_collection_management_system/data/models/waste_report.dart';
import 'package:waste_collection_management_system/services/api_service.dart';
import 'package:waste_collection_management_system/services/feedback_service.dart';
import 'package:waste_collection_management_system/services/waste_report_service.dart';

class CitizenHistoryScreen extends StatefulWidget {
  const CitizenHistoryScreen({super.key});

  @override
  State<CitizenHistoryScreen> createState() => _CitizenHistoryScreenState();
}

class _CitizenHistoryScreenState extends State<CitizenHistoryScreen> {
  final _service = WasteReportService();
  final _feedback = FeedbackService();
  final _picker = ImagePicker();
  bool _loading = true;
  List<WasteReport> _reports = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _reports = await _service.getReports();
    } catch (e) {
      _show(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel(WasteReport report) async {
    await _service.cancelReport(report.reportId);
    await _load();
  }

  Future<void> _sendFeedback(WasteReport report) async {
    final controller = TextEditingController();
    final content = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Feedback report #${report.reportId}'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Nội dung feedback'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (content == null || content.isEmpty) return;

    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1400,
    );
    await _feedback.createFeedback(
      reportId: report.reportId,
      content: content,
      image: !kIsWeb && image != null ? File(image.path) : null,
      webImage: kIsWeb ? image : null,
    );
    _show('Đã gửi feedback.');
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
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        itemBuilder: (_, index) {
          final report = _reports[index];
          return Card(
            child: ListTile(
              leading: report.imageUrl.isEmpty
                  ? const Icon(Icons.image_not_supported)
                  : Image.network(
                      ApiService.buildFileUrl(report.imageUrl),
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
              title: Text('#${report.reportId} · ${report.status}'),
              subtitle: Text(
                '${report.description}\n${report.latitude}, ${report.longitude}\n${report.createdAt ?? ''}',
              ),
              isThreeLine: true,
              trailing: Wrap(
                spacing: 8,
                children: [
                  if (report.canCancel)
                    TextButton(
                      onPressed: () => _cancel(report),
                      child: const Text('Cancel'),
                    ),
                  if (report.canFeedback)
                    TextButton(
                      onPressed: () => _sendFeedback(report),
                      child: const Text('Feedback'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
