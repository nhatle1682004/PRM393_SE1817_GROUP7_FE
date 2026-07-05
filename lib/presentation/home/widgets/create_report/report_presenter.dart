import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../services/api_service.dart';
import '../../../../config/api_config.dart';
import 'report_contract.dart';

class ReportPresenterImpl implements ReportPresenter {
  final ReportView _view;
  final Set<String> _selectedTypes = {};
  File? _imageFile;
  XFile? _webImageFile;
  double? _lat, _lng;
  final ImagePicker _imagePicker = ImagePicker();

  ReportPresenterImpl(this._view);

  @override
  void toggleWasteType(String type) {
    bool isSelected;
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
      isSelected = false;
    } else {
      _selectedTypes.add(type);
      isSelected = true;
    }
    _view.onWasteTypeToggled(type, isSelected);
  }

  @override
  void pickImage() {
    _view.onShowImageSourceDialog();
  }

  @override
  Future<void> pickFromCamera() async {
    try {
      if (kIsWeb) {
        // Trên Web, kiểm tra camera trước
        try {
          final List<CameraDescription> cameras = await availableCameras();
          if (cameras.isEmpty) {
            _view.onError("Không tìm thấy camera. Vui lòng chọn ảnh từ thư viện.");
            return;
          }
          _view.onShowWebCamera(cameras);
        } catch (e) {
          _view.onError("Camera không khả dụng trên thiết bị này.");
          await pickFromGallery();
        }
      } else {
        // Trên Mobile, kiểm tra platform trước khi dùng camera
        try {
          final List<CameraDescription> cameras = await availableCameras();
          if (cameras.isEmpty) {
            // Emulator không có camera, chuyển sang gallery
            await pickFromGallery();
            return;
          }
          
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1024,
            maxHeight: 1024,
            imageQuality: 85,
          );
          
          if (image != null) {
            _imageFile = File(image.path);
            _view.onImageStateChanged(true);
            _view.onImageFileUpdated(_imageFile);
          }
        } catch (e) {
          // Camera không khả dụng, thử gallery
          await pickFromGallery();
        }
      }
    } catch (e) {
      // Fallback cuối cùng: dùng gallery
      await pickFromGallery();
    }
  }

  @override
  Future<void> pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        if (!kIsWeb) {
          _imageFile = File(image.path);
          _view.onImageFileUpdated(_imageFile);
        } else {
          _webImageFile = image;
          _view.onWebImageFileUpdated(image);
        }
        _view.onImageStateChanged(true);
      }
    } catch (e) {
      _view.onError("Không thể chọn hình ảnh");
    }
  }

  @override
  void onWebImageCaptured(XFile file) {
    _webImageFile = file;
    _view.onImageStateChanged(true);
  }

  @override
  void getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _view.onError("Dịch vụ vị trí đang tắt");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _view.onError("Quyền truy cập vị trí bị từ chối");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _view.onError("Quyền truy cập vị trí bị từ chối vĩnh viễn");
        return;
      }

      _view.onSubmitting(true);
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _lat = position.latitude;
      _lng = position.longitude;
      _view.onLocationUpdated(_lat!, _lng!);
    } catch (e) {
      // Fallback to default location if GPS fails
      _lat = 10.776889;
      _lng = 106.700806;
      _view.onLocationUpdated(_lat!, _lng!);
    } finally {
      _view.onSubmitting(false);
    }
  }

  @override
  void submitReport(String description) async {
    if (_selectedTypes.isEmpty) {
      _view.onError("Vui lòng chọn ít nhất một loại rác");
      return;
    }

    if (_imageFile == null && _webImageFile == null) {
      _view.onError("Vui lòng thêm hình ảnh rác thải");
      return;
    }

    if (_lat == null || _lng == null) {
      _view.onError("Vui lòng chọn vị trí");
      return;
    }

    _view.onSubmitting(true);

    try {
      // Map waste type names to IDs (in real app, this should come from API)
      final wasteTypeIds = _mapWasteTypeNamesToIds(_selectedTypes.toList());

      // Call API with multipart form data
      final response = await ApiService.uploadMultipart(
        ApiConfig.wasteReports,
        imageFile: _imageFile,
        webImageFile: _webImageFile,
        latitude: _lat!,
        longitude: _lng!,
        description: description,
        wasteTypeIds: wasteTypeIds,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _view.onSuccess("Báo cáo đã được gửi thành công!");
      } else {
        _view.onError("Gửi báo cáo thất bại");
      }
    } catch (e) {
      _view.onError("Lỗi khi gửi báo cáo: ${e.toString()}");
    } finally {
      _view.onSubmitting(false);
    }
  }

  List<int> _mapWasteTypeNamesToIds(List<String> names) {
    // This is a mapping based on common waste types
    // In production, this should come from API or be configured
    final Map<String, int> wasteTypeMapping = {
      'Nhựa': 1,
      'Plastic': 1,
      'Giấy': 2,
      'Paper': 2,
      'Kim loại': 3,
      'Metal': 3,
      'Thủy tinh': 4,
      'Glass': 4,
      'Hữu cơ': 5,
      'Organic': 5,
      'Điện tử': 6,
      'E-Waste': 6,
    };

    return names.map((name) => wasteTypeMapping[name] ?? 1).toList();
  }

  @override
  void dispose() {
    // Cleanup if needed
  }
}
