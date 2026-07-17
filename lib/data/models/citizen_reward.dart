class RewardVoucher {
  final int rewardId;
  final String name;
  final String? description;
  final int points;
  final bool status;

  RewardVoucher({
    required this.rewardId,
    required this.name,
    this.description,
    required this.points,
    required this.status,
  });

  factory RewardVoucher.fromJson(Map<String, dynamic> json) {
    return RewardVoucher(
      rewardId: _toInt(json['rewardId'] ?? json['RewardId']),
      name: (json['name'] ?? json['Name'] ?? '').toString(),
      description: (json['description'] ?? json['Description'])?.toString(),
      points: _toInt(json['points'] ?? json['Points']),
      status: json['status'] ?? json['Status'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rewardId': rewardId,
      'name': name,
      'description': description,
      'points': points,
      'status': status,
    };
  }
}

class RewardTransaction {
  final int transactionId;
  final int userId;
  final int? reportId;
  final int points;
  final String type;
  final String? description;
  final DateTime? createdAt;
  final String status;
  final String? sourceType;
  final String? referenceId;
  final String? failureReason;
  final DateTime? completedAt;

  RewardTransaction({
    required this.transactionId,
    required this.userId,
    this.reportId,
    required this.points,
    required this.type,
    this.description,
    this.createdAt,
    required this.status,
    this.sourceType,
    this.referenceId,
    this.failureReason,
    this.completedAt,
  });

  factory RewardTransaction.fromJson(Map<String, dynamic> json) {
    return RewardTransaction(
      transactionId: _toInt(json['transactionId'] ?? json['TransactionId']),
      userId: _toInt(json['userId'] ?? json['UserId']),
      reportId: _toNullableInt(json['reportId'] ?? json['ReportId']),
      points: _toInt(json['points'] ?? json['Points']),
      type: (json['type'] ?? json['Type'] ?? '').toString(),
      description: (json['description'] ?? json['Description'])?.toString(),
      createdAt: (json['createdAt'] ?? json['CreatedAt']) != null
          ? DateTime.tryParse((json['createdAt'] ?? json['CreatedAt']).toString())
          : null,
      status: (json['status'] ?? json['Status'] ?? '').toString(),
      sourceType: (json['sourceType'] ?? json['SourceType'])?.toString(),
      referenceId: (json['referenceId'] ?? json['ReferenceId'])?.toString(),
      failureReason: (json['failureReason'] ?? json['FailureReason'])?.toString(),
      completedAt: (json['completedAt'] ?? json['CompletedAt']) != null
          ? DateTime.tryParse((json['completedAt'] ?? json['CompletedAt']).toString())
          : null,
    );
  }

  bool get isEarned => type == 'Earned';
  bool get isRedeemed => type == 'Redeemed';

  String get typeLabel {
    switch (type) {
      case 'Earned':
        return 'Tích điểm';
      case 'Redeemed':
        return 'Đổi quà';
      default:
        return type;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'Completed':
        return 'Hoàn thành';
      case 'Pending':
        return 'Đang xử lý';
      case 'Failed':
        return 'Thất bại';
      case 'Cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}

class RewardBalance {
  final int totalPoints;

  RewardBalance({required this.totalPoints});

  factory RewardBalance.fromJson(Map<String, dynamic> json) {
    return RewardBalance(
      totalPoints: _toInt(
        json['totalPoints'] ??
            json['TotalPoints'] ??
            json['points'] ??
            json['Points'] ??
            json['balance'] ??
            json['Balance'],
      ),
    );
  }
}

class RedeemRewardRequest {
  final int rewardId;
  final int quantity;

  RedeemRewardRequest({
    required this.rewardId,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'rewardId': rewardId,
      'quantity': quantity,
    };
  }
}

class RedeemRewardResponse {
  final bool success;
  final String? message;
  final int? remainingPoints;
  final int? rewardId;
  final String? rewardName;
  final int? redeemedPoints;

  RedeemRewardResponse({
    required this.success,
    this.message,
    this.remainingPoints,
    this.rewardId,
    this.rewardName,
    this.redeemedPoints,
  });

  factory RedeemRewardResponse.fromJson(Map<String, dynamic> json) {
    final rewardId = _toNullableInt(json['rewardId'] ?? json['RewardId']);
    final remainingPoints = _toNullableInt(json['remainingPoints'] ?? json['RemainingPoints']);
    final rewardName = (json['rewardName'] ?? json['RewardName'])?.toString();

    return RedeemRewardResponse(
      success: json['success'] == true ||
          json['Success'] == true ||
          rewardId != null ||
          remainingPoints != null,
      message: (json['message'] ?? json['Message'])?.toString(),
      remainingPoints: remainingPoints,
      rewardId: rewardId,
      rewardName: rewardName,
      redeemedPoints: _toNullableInt(json['redeemedPoints'] ?? json['RedeemedPoints']),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
