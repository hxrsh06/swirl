import 'package:shopping_swipe_app/domain/repositories/user_preference_repository.dart';

class GetLikedProductsUsecase {
  final UserPreferenceRepository repository;

 GetLikedProductsUsecase({required this.repository});

  Future<List<String>> call(String userId) {
    return repository.getLikedProductIds(userId);
  }
}