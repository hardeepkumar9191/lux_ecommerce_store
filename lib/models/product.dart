// models/product.dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final String category;
  final Map<String, dynamic> customOptions;
  final bool isCustomizable;
  final int stockQuantity;
  final double rating;
  final List<String> materials;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    this.customOptions = const {},
    this.isCustomizable = false,
    this.stockQuantity = 0,
    this.rating = 0.0,
    this.materials = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      images: List<String>.from(json['images']),
      category: json['category'],
      customOptions: json['customOptions'] ?? {},
      isCustomizable: json['isCustomizable'] ?? false,
      stockQuantity: json['stockQuantity'] ?? 0,
      rating: json['rating']?.toDouble() ?? 0.0,
      materials: List<String>.from(json['materials'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'customOptions': customOptions,
      'isCustomizable': isCustomizable,
      'stockQuantity': stockQuantity,
      'rating': rating,
      'materials': materials,
    };
  }
}