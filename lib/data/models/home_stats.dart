class HomeStats {
  final String totalPoints;
  final String reportsSubmitted;
  final String rewardEvents;
  final String userName;
  final String userEmail;

  HomeStats({
    this.totalPoints = '0',
    this.reportsSubmitted = '0',
    this.rewardEvents = '0',
    this.userName = '',
    this.userEmail = '',
  });

  HomeStats copyWith({
    String? totalPoints,
    String? reportsSubmitted,
    String? rewardEvents,
    String? userName,
    String? userEmail,
  }) {
    return HomeStats(
      totalPoints: totalPoints ?? this.totalPoints,
      reportsSubmitted: reportsSubmitted ?? this.reportsSubmitted,
      rewardEvents: rewardEvents ?? this.rewardEvents,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}
