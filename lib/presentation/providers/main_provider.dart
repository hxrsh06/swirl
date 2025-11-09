import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_swipe_app/data/datasources/remote/product_remote_data_source.dart';
import 'package:shopping_swipe_app/data/datasources/local/user_preference_local_data_source.dart';
import 'package:shopping_swipe_app/data/repositories/product_repository_impl.dart';
import 'package:shopping_swipe_app/data/repositories/user_preference_repository_impl.dart';
import 'package:shopping_swipe_app/domain/usecases/get_products_usecase.dart';
import 'package:shopping_swipe_app/domain/usecases/update_user_preference_usecase.dart';
import 'package:shopping_swipe_app/domain/usecases/get_user_preferences_usecase.dart';
import 'package:shopping_swipe_app/domain/usecases/get_liked_products_usecase.dart';
import 'package:shopping_swipe_app/domain/usecases/get_recommended_products_usecase.dart';

// Main provider to initialize all dependencies
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  // Using mock implementation for development
  return ProductRemoteDataSourceImpl();
});

final userPreferenceLocalDataSourceProvider = Provider<UserPreferenceLocalDataSource>((ref) {
  return UserPreferenceLocalDataSourceImpl();
});

final productRepositoryProvider = Provider((ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.watch(productRemoteDataSourceProvider),
  );
});

final userPreferenceRepositoryProvider = Provider((ref) {
  return UserPreferenceRepositoryImpl(
    localDataSource: ref.watch(userPreferenceLocalDataSourceProvider),
  );
});

final getProductsUsecaseProvider = Provider((ref) {
  return GetProductsUsecase(
    repository: ref.watch(productRepositoryProvider),
  );
});

final updateUserPreferenceUsecaseProvider = Provider((ref) {
  return UpdateUserPreferenceUsecase(
    repository: ref.watch(userPreferenceRepositoryProvider),
  );
});

final getUserPreferencesUsecaseProvider = Provider((ref) {
  return GetUserPreferencesUsecase(
    repository: ref.watch(userPreferenceRepositoryProvider),
  );
});

final getLikedProductsUsecaseProvider = Provider((ref) {
  return GetLikedProductsUsecase(
    repository: ref.watch(userPreferenceRepositoryProvider),
  );
});

final getRecommendedProductsUsecaseProvider = Provider((ref) {
  return GetRecommendedProductsUsecase(
    productRepository: ref.watch(productRepositoryProvider),
    userPreferenceRepository: ref.watch(userPreferenceRepositoryProvider),
  );
});
