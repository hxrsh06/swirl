import 'package:shopping_swipe_app/data/models/product_model.dart';
import 'package:shopping_swipe_app/domain/repositories/user_preference_repository.dart';

class ProcessAddToCartUsecase {
  final UserPreferenceRepository userPreferenceRepository;

  ProcessAddToCartUsecase({required this.userPreferenceRepository});

  Future<void> call(String userId, ProductModel product) async {
    // In a real app, you would add the item to a cart repository
    // For this example, we'll update user preferences to track cart items
    
    // Get current user preferences
    final userPreferences = await userPreferenceRepository.getUserPreferences(userId);
    
    // Add product to cart (in a real app, you'd have a separate cart repository)
    final updatedCartItems = {...userPreferences.preferences['cart_items'] ?? {}, product.id: product.toJson()};
    
    final updatedPreferences = userPreferences.copyWith(
      preferences: {
        ...userPreferences.preferences,
        'cart_items': updatedCartItems,
        'last_updated': DateTime.now().toIso8601String(),
      },
      updatedAt: DateTime.now(),
    );
    
    await userPreferenceRepository.saveUserPreferences(updatedPreferences);
 }
}