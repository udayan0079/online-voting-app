class CandidateModel {
  final String id;
  final String name;
  final String companyId;
  final String photoUrl;
  final String logoUrl;
  final String symbolName;
  final String bio;
  final int voteCount;
  final double votePercentage;

  CandidateModel({
    required this.id,
    required this.name,
    required this.companyId,
    this.photoUrl = '',
    this.logoUrl = '',
    this.symbolName = '',
    this.bio = '',
    this.voteCount = 0,
    this.votePercentage = 0.0,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      companyId: (json['companyId'] ?? '').toString(),
      photoUrl: (json['photoUrl'] ?? '').toString(),
      logoUrl: (json['logoUrl'] ?? '').toString(),
      symbolName: (json['symbolName'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      voteCount: (json['voteCount'] is num)
          ? (json['voteCount'] as num).toInt()
          : int.tryParse(json['voteCount']?.toString() ?? '0') ?? 0,
      votePercentage: (json['votePercentage'] is num)
          ? (json['votePercentage'] as num).toDouble()
          : double.tryParse(json['votePercentage']?.toString() ?? '0.0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      'name': name,
      'companyId': companyId,
      'photoUrl': photoUrl,
      'logoUrl': logoUrl,
      'symbolName': symbolName,
      'bio': bio,
      'voteCount': voteCount,
      'votePercentage': votePercentage,
    };
  }
}
