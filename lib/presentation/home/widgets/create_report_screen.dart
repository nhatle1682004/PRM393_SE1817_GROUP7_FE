import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'create_report/report_contract.dart';
import 'create_report/report_presenter.dart';
import 'create_report/widgets/web_camera_dialog.dart';
import 'create_report/banner_widgets.dart';
import 'create_report/photo_card.dart';
import 'create_report/location_card.dart';
import 'create_report/form_widgets.dart';
import 'create_report/estimated_size_card.dart';
import '../../../../data/models/waste_type.dart';

class CreateReportScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  const CreateReportScreen({super.key, this.onSuccess});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> implements ReportView {
  late ReportPresenter _presenter;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final Set<String> _selectedTypes = {};
  String? _selectedSize;
  double? _lat, _lng;
  String? _currentAddress;
  bool _isSubmitting = false;
  bool _isLocationLoading = false;
  File? _imageFile;
  XFile? _webPickedFile;
  List<WasteType> _wasteTypes = [];

  @override
  void initState() {
    super.initState();
    _presenter = ReportPresenterImpl(this);
  }

  @override
  void onLocationUpdated(double lat, double lng, String? address) {
    if (mounted) {
      setState(() {
        _lat = lat;
        _lng = lng;
        _currentAddress = address;
      });
    }
  }

  @override
  void onLocationLoading(bool isLoading) {
    if (mounted) {
      setState(() => _isLocationLoading = isLoading);
    }
  }
  @override
  void onImageStateChanged(bool hasImage) {}
  @override
  void onImageFileUpdated(File? file) { if (mounted) setState(() => _imageFile = file); }
  @override
  void onWebImageFileUpdated(XFile? file) { if (mounted) setState(() => _webPickedFile = file); }
  @override
  void onSubmitting(bool isSubmitting) {
    if (mounted) {
      setState(() => _isSubmitting = isSubmitting);
    }
  }

  @override
  void onSuccess(String msg) {
    if (!mounted) return;
    
    // Hiển thị dialog thông báo thành công
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gửi Báo Cáo Thành Công!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              msg,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Cảm ơn bạn đã đóng góp cho môi trường xanh!',
              style: TextStyle(fontSize: 13, color: Color(0xFF059669), fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _presenter.resetForm();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Tiếp Tục Báo Cáo', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    // Reset toàn bộ dữ liệu form
    setState(() {
      _descController.clear();
      _notesController.clear();
      _selectedTypes.clear();
      _selectedSize = null;
      _lat = null;
      _lng = null;
      _currentAddress = null;
      _imageFile = null;
      _webPickedFile = null;
    });
  }

  @override
  void onError(String err) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      print('Error snackbar error: $e');
    }
  }

  @override
  void onWasteTypeToggled(String type, bool isSelected) => setState(() {
    isSelected ? _selectedTypes.add(type) : _selectedTypes.remove(type);
  });

  @override
  void onShowWebCamera(List<CameraDescription> cameras) async {
    final XFile? capturedImage = await showDialog<XFile>(
      context: context,
      builder: (context) => WebCameraDialog(cameras: cameras),
    );
    if (capturedImage != null) {
      setState(() => _webPickedFile = capturedImage);
      _presenter.onWebImageCaptured(capturedImage);
    }
  }

  @override
  void onShowImageSourceDialog() => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => _ImageSourceSheet(
      onCamera: () { Navigator.pop(context); _presenter.pickFromCamera(); },
      onGallery: () { Navigator.pop(context); _presenter.pickFromGallery(); },
    ),
  );

  @override
  void onWasteTypesLoaded(List<WasteType> types) {
    if (mounted) {
      setState(() => _wasteTypes = types);
    }
  }

  @override
  void dispose() {
    _presenter.dispose();
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: isMobile ? _buildMobileAppBar() : null,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : (isTablet ? 20 : 24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile) const DesktopHeaderBanner(),
                if (!isMobile) SizedBox(height: isTablet ? 20 : 28),
                if (isMobile) const MobileHeaderBanner(),
                if (isMobile) const SizedBox(height: 20),
                _buildResponsiveLayout(isMobile: isMobile, isTablet: isTablet),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildMobileAppBar() => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)), 
      onPressed: () {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    ),
    title: const Text('Báo Cáo Rác Thải', style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w700)),
    centerTitle: true,
  );

  Widget _buildResponsiveLayout({required bool isMobile, required bool isTablet}) {
    if (isMobile) return _buildMobileLayout();
    if (isTablet) return _buildTabletLayout();
    return _buildDesktopLayout();
  }

  Widget _buildMobileLayout() => Column(children: [
    PhotoCard(isMobile: true, imageFile: _imageFile, webPickedFile: _webPickedFile, selectedTypes: _selectedTypes, onPickImage: () => _presenter.pickImage(), onToggleWasteType: (type) => _presenter.toggleWasteType(type), wasteTypes: _wasteTypes),
    const SizedBox(height: 16),
    LocationCard(
      isMobile: true,
      lat: _lat,
      lng: _lng,
      currentAddress: _currentAddress,
      isLocationLoading: _isLocationLoading,
      onGetLocation: () => _presenter.getCurrentLocation(),
      onLocationSelected: (lat, lng, addr) => _presenter.onLocationSelected(lat, lng),
      onAddressUpdated: (addr) => setState(() => _currentAddress = addr),
    ),
    const SizedBox(height: 16),
    DescriptionCard(isMobile: true, controller: _descController),
    const SizedBox(height: 16),
    EstimatedSizeCard(isMobile: true, selectedSize: _selectedSize, onSizeSelected: (size) => setState(() => _selectedSize = size)),
    const SizedBox(height: 16),
    DescriptionCard(isMobile: true, controller: _notesController, hintText: 'Thêm ghi chú khác (nếu có)...', title: 'Ghi chú thêm', icon: Icons.note_add),
    const SizedBox(height: 24),
    SubmitButton(isSubmitting: _isSubmitting, onPressed: () => _presenter.submitReport(_descController.text, _selectedSize)),
  ]);

  Widget _buildTabletLayout() => Column(children: [
    Row(children: [
      Expanded(child: PhotoCard(isMobile: false, imageFile: _imageFile, webPickedFile: _webPickedFile, selectedTypes: _selectedTypes, onPickImage: () => _presenter.pickImage(), onToggleWasteType: (type) => _presenter.toggleWasteType(type), wasteTypes: _wasteTypes)),
      const SizedBox(width: 16),
      Expanded(child: LocationCard(
        isMobile: false,
        lat: _lat,
        lng: _lng,
        currentAddress: _currentAddress,
        isLocationLoading: _isLocationLoading,
        onGetLocation: () => _presenter.getCurrentLocation(),
        onLocationSelected: (lat, lng, addr) => _presenter.onLocationSelected(lat, lng),
        onAddressUpdated: (addr) => setState(() => _currentAddress = addr),
      )),
    ]),
    const SizedBox(height: 16),
    EstimatedSizeCard(isMobile: false, selectedSize: _selectedSize, onSizeSelected: (size) => setState(() => _selectedSize = size)),
    const SizedBox(height: 16),
    DescriptionCard(isMobile: false, controller: _descController),
    const SizedBox(height: 24),
    SubmitButton(isSubmitting: _isSubmitting, onPressed: () => _presenter.submitReport(_descController.text, _selectedSize)),
  ]);

  Widget _buildDesktopLayout() => Column(children: [
    Row(children: [
      Expanded(flex: 6, child: PhotoCard(isMobile: false, imageFile: _imageFile, webPickedFile: _webPickedFile, selectedTypes: _selectedTypes, onPickImage: () => _presenter.pickImage(), onToggleWasteType: (type) => _presenter.toggleWasteType(type), wasteTypes: _wasteTypes)),
      const SizedBox(width: 20),
      Expanded(flex: 5, child: LocationCard(
        isMobile: false,
        lat: _lat,
        lng: _lng,
        currentAddress: _currentAddress,
        isLocationLoading: _isLocationLoading,
        onGetLocation: () => _presenter.getCurrentLocation(),
        onLocationSelected: (lat, lng, addr) => _presenter.onLocationSelected(lat, lng),
        onAddressUpdated: (addr) => setState(() => _currentAddress = addr),
      )),
    ]),
    const SizedBox(height: 20),
    EstimatedSizeCard(isMobile: false, selectedSize: _selectedSize, onSizeSelected: (size) => setState(() => _selectedSize = size)),
    const SizedBox(height: 20),
    DescriptionCard(isMobile: false, controller: _descController),
    const SizedBox(height: 24),
    SubmitButton(isSubmitting: _isSubmitting, onPressed: () => _presenter.submitReport(_descController.text, _selectedSize)),
  ]);
}

class _ImageSourceSheet extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  const _ImageSourceSheet({required this.onCamera, required this.onGallery});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 24),
      const Text('Chọn nguồn ảnh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: _SourceOption(icon: Icons.camera_alt, label: 'Chụp ảnh', color: const Color(0xFF10B981), onTap: onCamera)),
        const SizedBox(width: 16),
        Expanded(child: _SourceOption(icon: Icons.photo_library, label: 'Thư viện', color: const Color(0xFF3B82F6), onTap: onGallery)),
      ]),
      const SizedBox(height: 20),
    ]),
  );
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SourceOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 40),
        const SizedBox(height: 12),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      ]),
    ),
  );
}
