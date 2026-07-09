import 'dart:io';
import 'package:camera/camera.dart';
import '../../../../data/models/waste_type.dart';

abstract class ReportView {
  void onLocationUpdated(double lat, double lng, String? address);
  void onLocationLoading(bool isLoading);
  void onImageStateChanged(bool hasImage);
  void onImageFileUpdated(File? file);
  void onWebImageFileUpdated(XFile? file);
  void onSubmitting(bool isSubmitting);
  void onSuccess(String message);
  void onError(String error);
  void onWasteTypeToggled(String type, bool isSelected);
  void onShowImageSourceDialog();
  void onShowWebCamera(List<CameraDescription> cameras);
  void onWasteTypesLoaded(List<WasteType> types);
}

abstract class ReportPresenter {
  void toggleWasteType(String type);
  void pickImage();
  Future<void> pickFromCamera();
  Future<void> pickFromGallery();
  void onWebImageCaptured(XFile file);
  void getCurrentLocation();
  void onLocationSelected(double lat, double lng);
  void submitReport(String description, String? estimatedSize);
  void resetForm();
  void dispose();
}
