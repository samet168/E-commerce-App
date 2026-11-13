class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String category;
  final double rating;
  final int deliveryTimeMins;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    this.rating = 4.8,
    this.deliveryTimeMins = 20,
    this.stock = 100,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercent {
    if (!hasDiscount || originalPrice == 0) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedOriginalPrice => originalPrice != null ? '\$${originalPrice!.toStringAsFixed(2)}' : '';

  bool get inStock => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      imageUrl: json['image_url']?.toString() ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
      category: json['category']?.toString() ?? 'General',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      deliveryTimeMins: json['delivery_time_mins'] is int ? json['delivery_time_mins'] : 20,
      stock: json['stock'] is int ? json['stock'] : 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'original_price': originalPrice,
      'image_url': imageUrl,
      'category': category,
      'rating': rating,
      'delivery_time_mins': deliveryTimeMins,
      'stock': stock,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Product && runtimeType == other.runtimeType && id == other.id);

  @override
  int get hashCode => id.hashCode;
}
