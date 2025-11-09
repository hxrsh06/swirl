import 'package:equatable/equatable.dart';

class UserPreferenceModel extends Equatable {
  final String userId;
  final Map<String, dynamic> preferences;
  final List<String> likedProductIds;
  final List<String> dislikedProductIds;
  final Map<String, dynamic> categoryPreferences;
  final Map<String, dynamic> brandPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserPreferenceModel({
    required this.userId,
    this.preferences = const {},
    this.likedProductIds = const [],
    this.dislikedProductIds = const [],
    this.categoryPreferences = const {},
    this.brandPreferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferenceModel.fromJson(Map<String, dynamic> json) {
    return UserPreferenceModel(
      userId: json['user_id'] ?? '',
      preferences: json['preferences'] ?? {},
      likedProductIds: (json['liked_product_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
      dislikedProductIds: (json['disliked_product_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
      categoryPreferences: json['category_preferences'] ?? {},
      brandPreferences: json['brand_preferences'] ?? {},
      createdAt: DateTime.tryParse(json['created_at']) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'preferences': preferences,
      'liked_product_ids': likedProductIds,
      'disliked_product_ids': dislikedProductIds,
      'category_preferences': categoryPreferences,
      'brand_preferences': brandPreferences,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        userId,
        preferences,
        likedProductIds,
        dislikedProductIds,
        categoryPreferences,
        brandPreferences,
        createdAt,
        updatedAt,
      ];

  UserPreferenceModel copyWith({
    String? userId,
    Map<String, dynamic>? preferences,
    List<String>? likedProductIds,
    List<String>? dislikedProductIds,
    Map<String, dynamic>? categoryPreferences,
    Map<String, dynamic>? brandPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferenceModel(
      userId: userId ?? this.userId,
      preferences: preferences ?? this.preferences,
      likedProductIds: likedProductIds ?? this.likedProductIds,
      dislikedProductIds: dislikedProductIds ?? this.dislikedProductIds,
      categoryPreferences: categoryPreferences ?? this.categoryPreferences,
      brandPreferences: brandPreferences ?? this.brandPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}