import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String brand;
  final String category;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final String currency;
  final Map<String, dynamic> attributes; // Color, size, etc.

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.brand,
    required this.category,
    required this.imageUrls,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.currency = 'USD',
    this.attributes = const {},
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price']?.toDouble() ?? 0.0,
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      imageUrls: (json['image_urls'] as List?)?.map((e) => e.toString()).toList() ?? [],
      rating: (json['rating'] is int) ? (json['rating'] as int).toDouble() : json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      currency: json['currency'] ?? 'USD',
      attributes: json['attributes'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'brand': brand,
      'category': category,
      'image_urls': imageUrls,
      'rating': rating,
      'review_count': reviewCount,
      'currency': currency,
      'attributes': attributes,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        brand,
        category,
        imageUrls,
        rating,
        reviewCount,
        currency,
        attributes,
      ];

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? brand,
    String? category,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
    String? currency,
    Map<String, dynamic>? attributes,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      currency: currency ?? this.currency,
      attributes: attributes ?? this.attributes,
    );
  }
}