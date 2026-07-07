import 'package:waste_collection_management_system/config/api_config.dart';
import 'package:waste_collection_management_system/data/models/citizen_reward.dart';

abstract class HistoryView {
  void onLoadingStateChanged(bool isLoading);
  void onHistoryLoaded(List<RewardTransaction> transactions);
  void onBalanceLoaded(int balance);
  void onReportsLoaded(List<WasteReportItem> reports);
  void onReportSelected(WasteReportItem report);
  void onError(String? message);
  void onRefreshComplete();
}

abstract class HistoryPresenter {
  void loadHistory();
  void loadReports();
  void refreshHistory();
  void dispose();
}

class WasteReportItem {
  final int reportId;
  final List<String> wasteTypes;
  final String? description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final String status;
  final DateTime? createdAt;
  final String? assignedCollectorName;
  final DateTime? collectedAt;

  WasteReportItem({
    required this.reportId,
    required this.wasteTypes,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
    required this.status,
    this.createdAt,
    this.assignedCollectorName,
    this.collectedAt,
  });

  // Trả về URL ảnh đầy đủ để hiển thị
  String? get displayImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    return ApiConfig.getFullImageUrl(imageUrl!);
  }

  factory WasteReportItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return WasteReportItem(reportId: 0, wasteTypes: [], status: 'Pending');
    }
    
    // Xử lý wasteTypes - backend trả về WasteTypeNames (List<string>)
    List<String> wasteTypesList = [];
    if (json['wasteTypeNames'] != null) {
      wasteTypesList = List<String>.from(json['wasteTypeNames']);
    } else if (json['wasteTypes'] != null) {
      wasteTypesList = List<String>.from(json['wasteTypes']);
    } else if (json['wasteTypeName'] != null) {
      wasteTypesList = [json['wasteTypeName'].toString()];
    }
    
    // Xử lý imageUrl - backend trả về ImageUrl (PascalCase)
    String? imageUrlVal;
    if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      imageUrlVal = json['imageUrl'].toString();
    } else if (json['ImageUrl'] != null && json['ImageUrl'].toString().isNotEmpty) {
      imageUrlVal = json['ImageUrl'].toString();
    } else if (json['reportImageUrl'] != null && json['reportImageUrl'].toString().isNotEmpty) {
      imageUrlVal = json['reportImageUrl'].toString();
    }
    
    // Xử lý reportId - backend trả về ReportId (PascalCase)
    int reportIdVal = 0;
    if (json['reportId'] != null) {
      reportIdVal = json['reportId'] is int ? json['reportId'] as int : int.tryParse(json['reportId'].toString()) ?? 0;
    } else if (json['id'] != null) {
      reportIdVal = json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0;
    }
    
    return WasteReportItem(
      reportId: reportIdVal,
      wasteTypes: wasteTypesList,
      description: json['description'] ?? json['reportDescription'],
      imageUrl: imageUrlVal,
      latitude: json['latitude']?.toDouble() ?? (json['Latitude'] != null ? double.tryParse(json['Latitude'].toString()) : null),
      longitude: json['longitude']?.toDouble() ?? (json['Longitude'] != null ? double.tryParse(json['Longitude'].toString()) : null),
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : (json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt'].toString()) : null),
      assignedCollectorName: json['assignedCollectorName'],
      collectedAt: json['collectedAt'] != null ? DateTime.parse(json['collectedAt'].toString()) : (json['CollectedAt'] != null ? DateTime.parse(json['CollectedAt'].toString()) : null),
    );
  }

  String get locationString {
    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}';
    }
    return 'Không có vị trí';
  }
}
