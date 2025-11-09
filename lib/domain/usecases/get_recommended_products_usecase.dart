import 'package:shopping_swipe_app/data/models/product_model.dart';
import 'package:shopping_swipe_app/domain/repositories/product_repository.dart';
import 'package:shopping_swipe_app/domain/repositories/user_preference_repository.dart';

class GetRecommendedProductsUsecase {
  final ProductRepository productRepository;
  final UserPreferenceRepository userPreferenceRepository;

  GetRecommendedProductsUsecase({
    required this.productRepository,
    required this.userPreferenceRepository,
  });

  Future<List<ProductModel>> call(String userId) async {
    // Get user preferences
    final userPreferences = await userPreferenceRepository.getUserPreferences(userId);
    
    // Get liked and disliked product IDs
    final likedProductIds = await userPreferenceRepository.getLikedProductIds(userId);
    final dislikedProductIds = await userPreferenceRepository.getDislikedProductIds(userId);
    
    // This is a simplified recommendation algorithm
    // In a real app, you would use a more sophisticated ML model
    
    // First, get products based on user's category preferences
    if (userPreferences.categoryPreferences.isNotEmpty) {
      // Find the most preferred category
      String? preferredCategory;
      double maxPreference = 0;
      for (final entry in userPreferences.categoryPreferences.entries) {
        if (entry.value > maxPreference) {
          maxPreference = entry.value;
          preferredCategory = entry.key;
        }
      }
      
      if (preferredCategory != null) {
        try {
          final recommendedProducts = await productRepository.getProductsByCategory(preferredCategory);
          // Filter out already liked/disliked products
          return recommendedProducts
              .where((product) => 
                  !likedProductIds.contains(product.id) && 
                  !dislikedProductIds.contains(product.id))
              .take(10)
              .toList();
        } catch (e) {
          // If category-based recommendation fails, fall back to general recommendation
        }
      }
    }
    
    // Get products based on brand preferences
    if (userPreferences.brandPreferences.isNotEmpty) {
      // Find the most preferred brand
      String? preferredBrand;
      double maxPreference = 0;
      for (final entry in userPreferences.brandPreferences.entries) {
        if (entry.value > maxPreference) {
          maxPreference = entry.value;
          preferredBrand = entry.key;
        }
      }
      
      if (preferredBrand != null) {
        try {
          final recommendedProducts = await productRepository.getProductsByBrand(preferredBrand);
          // Filter out already liked/disliked products
          return recommendedProducts
              .where((product) => 
                  !likedProductIds.contains(product.id) && 
                  !dislikedProductIds.contains(product.id))
              .take(10)
              .toList();
        } catch (e) {
          // If brand-based recommendation fails, fall back to general recommendation
        }
      }
    }
    
    // Fallback: get general products
    final allProducts = await productRepository.getProducts(limit: 20);
    return allProducts
        .where((product) => 
            !likedProductIds.contains(product.id) && 
            !dislikedProductIds.contains(product.id))
        .take(10)
        .toList();
  }
}