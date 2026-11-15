class DashboardStatsModel {
  final int totalWhitelisted;
  final int registeredVoters;
  final int pendingVoters;
  final int totalElections;
  final int activeElections;
  final int upcomingElections;
  final int completedElections;
  final int totalVotesCast;
  final double turnoutRate;

  DashboardStatsModel({
    this.totalWhitelisted = 0,
    this.registeredVoters = 0,
    this.pendingVoters = 0,
    this.totalElections = 0,
    this.activeElections = 0,
    this.upcomingElections = 0,
    this.completedElections = 0,
    this.totalVotesCast = 0,
    this.turnoutRate = 0.0,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final voters = json['voters'] ?? {};
    final elections = json['elections'] ?? {};
    final voting = json['voting'] ?? {};

    return DashboardStatsModel(
      totalWhitelisted: voters['totalWhitelisted'] ?? 0,
      registeredVoters: voters['registeredVoters'] ?? 0,
      pendingVoters: voters['pendingVoters'] ?? 0,
      totalElections: elections['total'] ?? 0,
      activeElections: elections['active'] ?? 0,
      upcomingElections: elections['upcoming'] ?? 0,
      completedElections: elections['completed'] ?? 0,
      totalVotesCast: voting['totalVotesCast'] ?? 0,
      turnoutRate: (voting['turnoutRate'] ?? 0.0) is num
          ? (voting['turnoutRate'] as num).toDouble()
          : double.tryParse(voting['turnoutRate'].toString()) ?? 0.0,
    );
  }
}
