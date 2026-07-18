import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../services/api_service.dart';
import '../../../../config/api_config.dart';
import '../../../../data/models/waste_type.dart';
import 'report_contract.dart';

class ReportPresenterImpl implements ReportPresenter {
  final ReportView _view;
  final Set<String> _selectedTypes = {};
  File? _imageFile;
  XFile? _webImageFile;
  double? _lat, _lng;
  final ImagePicker _imagePicker = ImagePicker();
  List<WasteType> _wasteTypes = [];

  ReportPresenterImpl(this._view) {
    _loadWasteTypes();
  }

  Future<void> _loadWasteTypes() async {
    try {
      final data = await ApiService.getWasteTypes();
      if (data.isNotEmpty) {
        _wasteTypes = data.map((e) => WasteType.fromJson(e)).toList();
      } else {
        _wasteTypes = _getDefaultWasteTypes();
      }
      _view.onWasteTypesLoaded(_wasteTypes);
    } catch (e) {
      // API thất bại - vẫn cố gắng parse dữ liệu trả về
      _wasteTypes = _getDefaultWasteTypes();
      _view.onWasteTypesLoaded(_wasteTypes);
    }
  }

  List<WasteType> _getDefaultWasteTypes() {
    return [
      WasteType(id: 1, name: 'Organic', nameVi: 'Hữu cơ', icon: Icons.eco, color: const Color(0xFFEF4444)),
      WasteType(id: 2, name: 'Plastic', nameVi: 'Nhựa', icon: Icons.local_drink, color: const Color(0xFF3B82F6)),
      WasteType(id: 3, name: 'Paper', nameVi: 'Giấy', icon: Icons.description, color: const Color(0xFFF59E0B)),
      WasteType(id: 4, name: 'Metal', nameVi: 'Kim loại', icon: Icons.hardware, color: const Color(0xFF8B5CF6)),
      WasteType(id: 5, name: 'Glass', nameVi: 'Thủy tinh', icon: Icons.wine_bar, color: const Color(0xFF10B981)),
      WasteType(id: 6, name: 'E-Waste', nameVi: 'Điện tử', icon: Icons.memory, color: const Color(0xFF6366F1)),
      WasteType(id: 7, name: 'Hazardous', nameVi: 'Nguy hại', icon: Icons.warning, color: const Color(0xFFDC2626)),
      WasteType(id: 8, name: 'Other', nameVi: 'Khác', icon: Icons.more_horiz, color: const Color(0xFF6B7280)),
    ];
  }

  @override
  void toggleWasteType(String typeNameVi) {
    bool isSelected;
    if (_selectedTypes.contains(typeNameVi)) {
      _selectedTypes.remove(typeNameVi);
      isSelected = false;
    } else {
      _selectedTypes.add(typeNameVi);
      isSelected = true;
    }
    _view.onWasteTypeToggled(typeNameVi, isSelected);
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
            await _predictWasteTypeFromImage();
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
        await _predictWasteTypeFromImage();
      }
    } catch (e) {
      _view.onError("Không thể chọn hình ảnh");
    }
  }

  @override
  void onWebImageCaptured(XFile file) {
    _webImageFile = file;
    _view.onImageStateChanged(true);
    _view.onWebImageFileUpdated(file);
    _predictWasteTypeFromImage();
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

      _view.onLocationLoading(true);
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _lat = position.latitude;
      _lng = position.longitude;
      _view.onLocationUpdated(_lat!, _lng!, null);
    } catch (e) {
      // Fallback to default location if GPS fails
      _lat = 10.776889;
      _lng = 106.700806;
      _view.onLocationUpdated(_lat!, _lng!, null);
    } finally {
      _view.onLocationLoading(false);
    }
  }

  @override
  void submitReport(String description, String? estimatedSize) async {
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
      // Chuyển đổi tên loại rác (đang ở dạng tiếng Việt) sang ID dựa trên dữ liệu đã tải
      final wasteTypeIds = _selectedTypes.map((nameVi) {
        final type = _wasteTypes.firstWhere(
          (t) => t.nameVi == nameVi || t.name == nameVi,
          orElse: () => _wasteTypes.first,
        );
        return type.id;
      }).toList();

      final response = await ApiService.uploadMultipart(
        ApiConfig.wasteReports,
        imageFile: _imageFile,
        webImageFile: _webImageFile,
        latitude: _lat!,
        longitude: _lng!,
        description: description,
        estimatedSize: estimatedSize,
        wasteTypeIds: wasteTypeIds,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _selectedTypes.clear(); // Reset dữ liệu trong presenter
        _imageFile = null;
        _webImageFile = null;
        _lat = null;
        _lng = null;
        
        _view.onSuccess("Báo cáo của bạn đã được gửi thành công!");
      } else {
        _view.onError("Gửi báo cáo thất bại (${response.statusCode})");
      }
    } catch (e) {
      debugPrint('Submit report error: $e');
      _view.onError("Lỗi khi gửi báo cáo: $e");
    } finally {
      _view.onSubmitting(false);
    }
  }

  Future<void> _predictWasteTypeFromImage() async {
    if (_imageFile == null && _webImageFile == null) {
      return;
    }

    _view.onAiPredictionLoading(true);
    try {
      final response = await ApiService.predictWasteImage(
        imageFile: _imageFile,
        webImageFile: _webImageFile,
      );

      final data = response.data;
      if (data is! Map) {
        return;
      }

      final label = data['label']?.toString() ?? '';
      final confidence = data['confidence'] is num
          ? (data['confidence'] as num).toDouble()
          : double.tryParse(data['confidence']?.toString() ?? '') ?? 0;
      final suggestedType = _resolvePredictedWasteType(label);
      if (suggestedType == null || suggestedType.isEmpty) {
        return;
      }

      _selectedTypes.clear();
      _selectedTypes.add(suggestedType);
      _view.onAiPredictionSuggested(suggestedType, label, confidence);
    } catch (e) {
      _view.onError("AI chua the phan tich anh nay. Ban van co the chon loai rac thu cong.");
    } finally {
      _view.onAiPredictionLoading(false);
    }
  }

  String? _resolvePredictedWasteType(String label) {
    if (_wasteTypes.isEmpty) {
      return null;
    }

    final normalized = label.toLowerCase().trim();
    final expectedId = switch (normalized) {
      'food waste' => 1,
      'plastic' => 2,
      'paper' || 'cardboard' => 3,
      'metal' => 4,
      'glass' => 5,
      'battery' => 7,
      'clothes' || 'shoes' || 'trash' => 8,
      _ => null,
    };

    if (expectedId != null) {
      final matches = _wasteTypes.where((type) => type.id == expectedId);
      if (matches.isNotEmpty) {
        return matches.first.nameVi;
      }
    }

    final directMatches = _wasteTypes.where((type) {
      final name = type.name.toLowerCase();
      final nameVi = type.nameVi.toLowerCase();
      return name.contains(normalized) || normalized.contains(name) || nameVi.contains(normalized);
    });

    return directMatches.isNotEmpty ? directMatches.first.nameVi : _wasteTypes.last.nameVi;
  }

  @override
  void onLocationSelected(double lat, double lng) {
    _lat = lat;
    _lng = lng;
    _view.onLocationUpdated(_lat!, _lng!, null);
  }

  @override
  void resetForm() {
    _selectedTypes.clear();
    _imageFile = null;
    _webImageFile = null;
    _lat = null;
    _lng = null;
  }

  @override
  void dispose() {
    // Cleanup if needed
  }
}
