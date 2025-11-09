import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_swipe_app/data/models/product_model.dart';
import 'package:logger/logger.dart';

/// Service for persisting cart items and swipe history to local storage
class CartPersistenceService {
  static const String _cartKey = 'shopping_cart';
  static const String _swipeHistoryKey = 'swipe_history';
  static const String _swipedProductIdsKey = 'swiped_product_ids';
  static const String _totalSwipedCountKey = 'total_swiped_count';

  final Logger _logger = Logger();

  /// Save cart items to local storage
  Future<bool> saveCart(List<ProductModel> cartItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = cartItems.map((item) => item.toJson()).toList();
      final success = await prefs.setString(_cartKey, jsonEncode(cartJson));
      _logger.d('Cart saved to local storage: ${cartItems.length} items');
      return success;
    } catch (e) {
      _logger.e('Failed to save cart: $e');
      return false;
    }
  }

  /// Load cart items from local storage
  Future<List<ProductModel>> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_cartKey);

      if (cartString == null || cartString.isEmpty) {
        _logger.d('No saved cart found');
        return [];
      }

      final List<dynamic> cartJson = jsonDecode(cartString);
      final cart = cartJson
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();

      _logger.d('Cart loaded from local storage: ${cart.length} items');
      return cart;
    } catch (e) {
      _logger.e('Failed to load cart: $e');
      return [];
    }
  }

  /// Clear cart from local storage
  Future<bool> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_cartKey);
      _logger.d('Cart cleared from local storage');
      return success;
    } catch (e) {
      _logger.e('Failed to clear cart: $e');
      return false;
    }
  }

  /// Save list of swiped product IDs to avoid showing them again
  Future<bool> saveSwipedProductIds(Set<String> productIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setStringList(_swipedProductIdsKey, productIds.toList());
      _logger.d('Saved ${productIds.length} swiped product IDs');
      return success;
    } catch (e) {
      _logger.e('Failed to save swiped product IDs: $e');
      return false;
    }
  }

  /// Load list of swiped product IDs
  Future<Set<String>> loadSwipedProductIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_swipedProductIdsKey) ?? [];
      _logger.d('Loaded ${ids.length} swiped product IDs');
      return ids.toSet();
    } catch (e) {
      _logger.e('Failed to load swiped product IDs: $e');
      return {};
    }
  }

  /// Save total swiped count
  Future<bool> saveTotalSwipedCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setInt(_totalSwipedCountKey, count);
      _logger.d('Saved total swiped count: $count');
      return success;
    } catch (e) {
      _logger.e('Failed to save total swiped count: $e');
      return false;
    }
  }

  /// Load total swiped count
  Future<int> loadTotalSwipedCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_totalSwipedCountKey) ?? 0;
      _logger.d('Loaded total swiped count: $count');
      return count;
    } catch (e) {
      _logger.e('Failed to load total swiped count: $e');
      return 0;
    }
  }

  /// Clear all persisted data
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
      await prefs.remove(_swipeHistoryKey);
      await prefs.remove(_swipedProductIdsKey);
      await prefs.remove(_totalSwipedCountKey);
      _logger.d('Cleared all persisted data');
      return true;
    } catch (e) {
      _logger.e('Failed to clear all data: $e');
      return false;
    }
  }
}
