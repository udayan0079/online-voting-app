class UserModel {
  final String id;
  final String name;
  final String companyId;
  final String email;
  final String role; // 'ADMIN' or 'VOTER'
  final String department;
  final String? orgId;

  UserModel({
    required this.id,
    required this.name,
    required this.companyId,
    required this.email,
    required this.role,
    this.department = '',
    this.orgId,
  });

  bool get isAdmin => role == 'ADMIN';
  bool get isVoter => role == 'VOTER';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      companyId: json['companyId'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'VOTER',
      department: json['department'] ?? '',
      orgId: json['orgId'] is Map ? json['orgId']['_id'] : json['orgId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'companyId': companyId,
      'email': email,
      'role': role,
      'department': department,
      'orgId': orgId,
    };
  }
}
