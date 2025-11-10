import 'package:equatable/equatable.dart';
import 'package:shopping_swipe_app/data/models/product_model.dart';

/// Cart item model with quantity tracking
class CartItemModel extends Equatable {
  final ProductModel product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;

  const CartItemModel({
    required this.product,
    this.quantity = 1,
    this.selectedSize,
    this.selectedColor,
  });

  /// Calculate total price for this cart item
  double get totalPrice => product.price * quantity;

  /// Copy with method for immutable updates
  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }

  /// Create from JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      selectedSize: json['selectedSize'] as String?,
      selectedColor: json['selectedColor'] as String?,
    );
  }

  @override
  List<Object?> get props => [product.id, quantity, selectedSize, selectedColor];
}
