import 'package:shopping_swipe_app/data/models/user_preference_model.dart';
import 'package:shopping_swipe_app/domain/repositories/user_preference_repository.dart';

class GetUserPreferencesUsecase {
  final UserPreferenceRepository repository;

  GetUserPreferencesUsecase({required this.repository});

  Future<UserPreferenceModel> call(String userId) {
    return repository.getUserPreferences(userId);
  }
}