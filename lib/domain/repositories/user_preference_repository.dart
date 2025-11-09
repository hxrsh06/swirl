import 'package:shopping_swipe_app/data/models/user_preference_model.dart';

abstract class UserPreferenceRepository {
  Future<UserPreferenceModel> getUserPreferences(String userId);
  Future<void> saveUserPreferences(UserPreferenceModel preferences);
  Future<void> updateLikedProduct(String userId, String productId, bool liked);
  Future<List<String>> getLikedProductIds(String userId);
  Future<List<String>> getDislikedProductIds(String userId);
}