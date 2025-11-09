import 'package:shopping_swipe_app/data/models/product_model.dart';

abstract class MLRepository {
  Future<void> initializeModel();
  Future<List<ProductModel>> getRecommendationsForUser(
    String userId, 
    List<ProductModel> availableProducts,
    List<String> likedProductIds,
    List<String> dislikedProductIds,
  );
  Future<void> updateModelWithFeedback(String userId, String productId, bool liked);
}