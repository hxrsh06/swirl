import 'package:shopping_swipe_app/data/datasources/local/user_preference_local_data_source.dart';
import 'package:shopping_swipe_app/data/models/user_preference_model.dart';
import 'package:shopping_swipe_app/domain/repositories/user_preference_repository.dart';

class UserPreferenceRepositoryImpl implements UserPreferenceRepository {
  final UserPreferenceLocalDataSource localDataSource;

  UserPreferenceRepositoryImpl({required this.localDataSource});

  @override
 Future<UserPreferenceModel> getUserPreferences(String userId) {
    return localDataSource.getUserPreferences(userId);
  }

  @override
  Future<void> saveUserPreferences(UserPreferenceModel preferences) {
    return localDataSource.saveUserPreferences(preferences);
  }

  @override
  Future<void> updateLikedProduct(String userId, String productId, bool liked) {
    return localDataSource.updateLikedProduct(userId, productId, liked);
  }

  @override
  Future<List<String>> getLikedProductIds(String userId) {
    return localDataSource.getLikedProductIds(userId);
  }

  @override
  Future<List<String>> getDislikedProductIds(String userId) {
    return localDataSource.getDislikedProductIds(userId);
  }
}