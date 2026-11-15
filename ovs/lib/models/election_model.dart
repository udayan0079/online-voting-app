import 'candidate_model.dart';

class ElectionModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final List<CandidateModel> candidates;
  final int totalVotes;
  final String status; // 'UPCOMING', 'ACTIVE', 'COMPLETED'
  final bool hasVoted;
  final String? voteReceipt;
  final bool isManualClosed;
  final CandidateModel? winner;
  final bool isTie;

  ElectionModel({
    required this.id,
    required this.title,
    required this.category,
    this.description = '',
    required this.startTime,
    required this.endTime,
    required this.candidates,
    this.totalVotes = 0,
    required this.status,
    this.hasVoted = false,
    this.voteReceipt,
    this.isManualClosed = false,
    this.winner,
    this.isTie = false,
  });

  bool get isActive => status == 'ACTIVE';
  bool get isUpcoming => status == 'UPCOMING';
  bool get isCompleted => status == 'COMPLETED';

  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isBefore(startTime)) {
      return startTime.difference(now);
    }
    if (now.isBefore(endTime)) {
      return endTime.difference(now);
    }
    return Duration.zero;
  }

  factory ElectionModel.fromJson(Map<String, dynamic> json) {
    final candidatesList = (json['candidates'] as List? ?? [])
        .map((c) => CandidateModel.fromJson(c))
        .toList();

    CandidateModel? winnerCandidate;
    if (json['resultSummary'] != null && json['resultSummary']['winner'] != null) {
      winnerCandidate = CandidateModel.fromJson(json['resultSummary']['winner']);
    }

    String? receipt;
    if (json['userVoteRecord'] != null && json['userVoteRecord']['receipt'] != null) {
      receipt = json['userVoteRecord']['receipt'];
    }

    return ElectionModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
      candidates: candidatesList,
      totalVotes: (json['totalVotes'] ?? 0) is int ? json['totalVotes'] : int.tryParse(json['totalVotes'].toString()) ?? 0,
      status: (json['status'] ?? 'UPCOMING').toString().toUpperCase(),
      hasVoted: json['hasVoted'] == true,
      voteReceipt: receipt,
      isManualClosed: json['isManualClosed'] == true,
      winner: winnerCandidate,
      isTie: json['resultSummary']?['isTie'] == true,
    );
  }
}
