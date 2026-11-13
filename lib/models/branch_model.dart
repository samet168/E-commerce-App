class Branch {
  final int id;
  final String code;
  final String name;
  final String address;
  final String phone;
  final String openingHours;
  final bool isActive;

  Branch({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.phone,
    this.openingHours = '07:00 AM - 10:00 PM',
    this.isActive = true,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      code: json['code']?.toString() ?? 'OMNI-01',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      openingHours: json['opening_hours']?.toString() ?? '07:00 AM - 10:00 PM',
      isActive: json['is_active'] == null ? true : (json['is_active'] == true || json['is_active'] == 1),
    );
  }
}
