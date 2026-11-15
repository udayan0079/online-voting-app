class WhitelistModel {
  final String id;
  final String companyId;
  final String name;
  final String department;
  final bool isRegistered;
  final DateTime? createdAt;

  WhitelistModel({
    required this.id,
    required this.companyId,
    this.name = '',
    this.department = '',
    this.isRegistered = false,
    this.createdAt,
  });

  factory WhitelistModel.fromJson(Map<String, dynamic> json) {
    return WhitelistModel(
      id: json['id'] ?? json['_id'] ?? '',
      companyId: json['companyId'] ?? '',
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      isRegistered: json['isRegistered'] == true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
