class OrganizationModel {
  final String id;
  final String name;
  final String orgCode;
  final String address;
  final String description;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.orgCode,
    this.address = '',
    this.description = '',
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      orgCode: (json['orgCode'] ?? '').toString().toUpperCase(),
      address: json['address'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'orgCode': orgCode,
      'address': address,
      'description': description,
    };
  }
}
