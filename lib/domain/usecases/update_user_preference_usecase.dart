import 'package:shopping_swipe_app/domain/repositories/user_preference_repository.dart';

class UpdateUserPreferenceUsecase {
  final UserPreferenceRepository repository;

  UpdateUserPreferenceUsecase({required this.repository});

  Future<void> call(String userId, String productId, bool liked) {
    return repository.updateLikedProduct(userId, productId, liked);
  }
}