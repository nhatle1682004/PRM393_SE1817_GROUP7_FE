class AdminReward {
  final int rewardId;
  final String name;
  final String? description;
  final int points;
  final bool status;
  final int totalRedeemed;

  AdminReward({
    required this.rewardId,
    required this.name,
    this.description,
    required this.points,
    this.status = true,
    this.totalRedeemed = 0,
  });

  factory AdminReward.fromJson(Map<String, dynamic> json) {
    return AdminReward(
      rewardId: json['rewardId'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      points: json['points'] ?? 0,
      status: json['status'] ?? true,
      totalRedeemed: json['totalRedeemed'] ?? 0,
    );
  }
}

class AdminRewardTransaction {
  final int transactionId;
  final int userId;
  final String userName;
  final int? rewardId;
  final String? rewardName;
  final int points;
  final String type;
  final String description;
  final String status;
  final DateTime? createdAt;
  final DateTime? completedAt;

  AdminRewardTransaction({
    required this.transactionId,
    required this.userId,
    required this.userName,
    this.rewardId,
    this.rewardName,
    required this.points,
    required this.type,
    required this.description,
    this.status = 'Pending',
    this.createdAt,
    this.completedAt,
  });

  factory AdminRewardTransaction.fromJson(Map<String, dynamic> json) {
    return AdminRewardTransaction(
      transactionId: json['transactionId'] ?? 0,
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      rewardId: json['rewardId'],
      rewardName: json['rewardName'],
      points: json['points'] ?? 0,
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
    );
  }
}
