import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_swipe_app/data/models/user_preference_model.dart';

abstract class UserPreferenceLocalDataSource {
  Future<UserPreferenceModel> getUserPreferences(String userId);
  Future<void> saveUserPreferences(UserPreferenceModel preferences);
  Future<void> updateLikedProduct(String userId, String productId, bool liked);
  Future<List<String>> getLikedProductIds(String userId);
  Future<List<String>> getDislikedProductIds(String userId);
}

class UserPreferenceLocalDataSourceImpl implements UserPreferenceLocalDataSource {
  static const String _preferencesKey = 'user_preferences';
  
  @override
  Future<UserPreferenceModel> getUserPreferences(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_preferencesKey}_$userId');
    
    if (jsonString != null) {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return UserPreferenceModel.fromJson(jsonMap);
    } else {
      // Return default preferences if none exist
      return UserPreferenceModel(
        userId: userId,
        preferences: {},
        likedProductIds: [],
        dislikedProductIds: [],
        categoryPreferences: {},
        brandPreferences: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> saveUserPreferences(UserPreferenceModel preferences) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(preferences.toJson());
    await prefs.setString('${_preferencesKey}_${preferences.userId}', jsonString);
    await prefs.setString('${_preferencesKey}_${preferences.userId}_updated', preferences.updatedAt.toIso8601String());
  }

  @override
  Future<void> updateLikedProduct(String userId, String productId, bool liked) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_preferencesKey}_$userId');
    
    UserPreferenceModel userPrefs;
    if (jsonString != null) {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      userPrefs = UserPreferenceModel.fromJson(jsonMap);
    } else {
      userPrefs = UserPreferenceModel(
        userId: userId,
        preferences: {},
        likedProductIds: [],
        dislikedProductIds: [],
        categoryPreferences: {},
        brandPreferences: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    
    List<String> likedIds = List.from(userPrefs.likedProductIds);
    List<String> dislikedIds = List.from(userPrefs.dislikedProductIds);
    
    if (liked) {
      if (!likedIds.contains(productId)) {
        likedIds.add(productId);
      }
      dislikedIds.remove(productId); // Remove from disliked if it was there
    } else {
      if (!dislikedIds.contains(productId)) {
        dislikedIds.add(productId);
      }
      likedIds.remove(productId); // Remove from liked if it was there
    }
    
    final updatedPrefs = userPrefs.copyWith(
      likedProductIds: likedIds,
      dislikedProductIds: dislikedIds,
      updatedAt: DateTime.now(),
    );
    
    await saveUserPreferences(updatedPrefs);
  }

  @override
  Future<List<String>> getLikedProductIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_preferencesKey}_$userId');
    
    if (jsonString != null) {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final userPrefs = UserPreferenceModel.fromJson(jsonMap);
      return userPrefs.likedProductIds;
    } else {
      return [];
    }
  }

  @override
  Future<List<String>> getDislikedProductIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_preferencesKey}_$userId');
    
    if (jsonString != null) {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final userPrefs = UserPreferenceModel.fromJson(jsonMap);
      return userPrefs.dislikedProductIds;
    } else {
      return [];
    }
  }
}