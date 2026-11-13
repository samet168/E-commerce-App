class Category {
  final int? id;
  final String name;
  final String? nameKhmer;
  final String? iconName;
  final int itemCount;

  Category({
    this.id,
    required this.name,
    this.nameKhmer,
    this.iconName,
    this.itemCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] : null,
      name: json['name']?.toString() ?? '',
      nameKhmer: json['name_khmer']?.toString(),
      iconName: json['icon_name']?.toString() ?? 'Layers',
      itemCount: json['item_count'] is int ? json['item_count'] : 0,
    );
  }
}
