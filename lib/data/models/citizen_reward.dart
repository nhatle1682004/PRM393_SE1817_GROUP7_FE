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
      rewardId: json['rewardId'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      points: json['points'] ?? 0,
      status: json['status'] ?? true,
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
      transactionId: json['transactionId'] ?? 0,
      userId: json['userId'] ?? 0,
      reportId: json['reportId'],
      points: json['points'] ?? 0,
      type: json['type'] ?? '',
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      status: json['status'] ?? '',
      sourceType: json['sourceType'],
      referenceId: json['referenceId']?.toString(),
      failureReason: json['failureReason'],
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
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
      totalPoints: json['totalPoints'] ?? json['balance'] ?? 0,
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

  RedeemRewardResponse({
    required this.success,
    this.message,
    this.remainingPoints,
    this.rewardId,
  });

  factory RedeemRewardResponse.fromJson(Map<String, dynamic> json) {
    return RedeemRewardResponse(
      success: json['success'] ?? false,
      message: json['message'],
      remainingPoints: json['remainingPoints'],
      rewardId: json['rewardId'],
    );
  }
}
