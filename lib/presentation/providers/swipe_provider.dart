import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shopping_swipe_app/data/models/product_model.dart';
import 'package:shopping_swipe_app/data/services/cart_persistence_service.dart';
import 'package:shopping_swipe_app/domain/usecases/get_products_usecase.dart';
import 'package:shopping_swipe_app/domain/usecases/update_user_preference_usecase.dart';
import 'package:shopping_swipe_app/domain/usecases/get_recommended_products_usecase.dart';
import 'package:shopping_swipe_app/presentation/providers/main_provider.dart';

// Swipe history entry for undo functionality
class SwipeHistoryEntry {
  final ProductModel product;
  final bool wasLiked;
  final DateTime timestamp;

  SwipeHistoryEntry({
    required this.product,
    required this.wasLiked,
    required this.timestamp,
  });
}

// State for the swipe screen
class SwipeState {
  final List<ProductModel> products;
 final bool isLoading;
  final String? error;
  final List<ProductModel> cartItems;
  final List<SwipeHistoryEntry> swipeHistory; // Track last 5 swipes for undo
  final int totalSwipedCount; // Track total products swiped
  final List<ProductModel> likedProducts; // Track ALL liked products for favorites

  const SwipeState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.cartItems = const [],
    this.swipeHistory = const [],
    this.totalSwipedCount = 0,
    this.likedProducts = const [],
  });

  SwipeState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    String? error,
    List<ProductModel>? cartItems,
    List<SwipeHistoryEntry>? swipeHistory,
    int? totalSwipedCount,
    List<ProductModel>? likedProducts,
  }) {
    return SwipeState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      cartItems: cartItems ?? this.cartItems,
      swipeHistory: swipeHistory ?? this.swipeHistory,
      totalSwipedCount: totalSwipedCount ?? this.totalSwipedCount,
      likedProducts: likedProducts ?? this.likedProducts,
    );
  }
}

// Provider for swipe state
final swipeProvider = StateNotifierProvider<SwipeNotifier, SwipeState>((ref) {
  final getProductsUsecase = ref.watch(getProductsUsecaseProvider);
  final updateUserPreferenceUsecase = ref.watch(updateUserPreferenceUsecaseProvider);
  final getRecommendedProductsUsecase = ref.watch(getRecommendedProductsUsecaseProvider);
  
  return SwipeNotifier(
    getProductsUsecase: getProductsUsecase,
    updateUserPreferenceUsecase: updateUserPreferenceUsecase,
    getRecommendedProductsUsecase: getRecommendedProductsUsecase,
  );
});

class SwipeNotifier extends StateNotifier<SwipeState> {
  final GetProductsUsecase getProductsUsecase;
  final UpdateUserPreferenceUsecase updateUserPreferenceUsecase;
  final GetRecommendedProductsUsecase getRecommendedProductsUsecase;
  final Logger _logger = Logger();
  final CartPersistenceService _persistenceService = CartPersistenceService();

  SwipeNotifier({
    required this.getProductsUsecase,
    required this.updateUserPreferenceUsecase,
    required this.getRecommendedProductsUsecase,
  }) : super(const SwipeState()) {
    // Load persisted data on initialization
    _loadPersistedData();
  }

  /// Load persisted cart and swipe count from local storage
  Future<void> _loadPersistedData() async {
    try {
      final cart = await _persistenceService.loadCart();
      final swipedCount = await _persistenceService.loadTotalSwipedCount();

      state = state.copyWith(
        cartItems: cart,
        totalSwipedCount: swipedCount,
      );

      _logger.i('Loaded persisted data: ${cart.length} cart items, $swipedCount swipes');
    } catch (e) {
      _logger.e('Failed to load persisted data: $e');
    }
  }

  /// Loads products from the data source
  ///
  /// If [userId] is provided, attempts to load recommended products for the user.
  /// Falls back to general products if no recommendations are available.
  ///
  /// Throws exceptions if the loading operation fails or times out.
  Future<void> loadProducts({String? userId}) async {
    _logger.d('Loading products with userId: ${userId ?? "null"}');
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      List<ProductModel> products;
      
      // If user ID is provided, try to get recommended products
      if (userId != null) {
        _logger.d('Attempting to load recommended products for user: $userId');
        try {
          products = await getRecommendedProductsUsecase.call(userId).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Loading recommended products timed out after 10 seconds');
            },
          );

          // If no recommended products were found, fallback to general products
          if (products.isEmpty) {
            _logger.d('No recommended products found, falling back to general products');
            products = await getProductsUsecase.call().timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw TimeoutException('Loading products timed out after 10 seconds');
              },
            );
          }
        } catch (e) {
          _logger.w('Failed to load recommended products: $e, falling back to general products');
          // Fallback to general products
          products = await getProductsUsecase.call().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Loading products timed out after 10 seconds');
            },
          );
        }
      } else {
        _logger.d('Loading general products (no userId provided)');
        // Load general products if no user ID provided
        products = await getProductsUsecase.call().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Loading products timed out after 10 seconds');
          },
        );
      }

      // Validate that products list is not null and contains valid ProductModel objects
      if (products == null) {
        throw Exception('Products list is null');
      }
      
      // Validate each product in the list
      for (final product in products) {
        if (!_isValidProduct(product)) {
          throw Exception('Invalid product data found');
        }
      }

      _logger.i('Successfully loaded ${products.length} products');
      state = state.copyWith(products: products, isLoading: false);
    } catch (e, stack) {
      _logger.e('Error loading products: $e', error: e, stackTrace: stack);
      // Ensure we exit loading state even if there's an error
      String errorMessage = 'Failed to load products: ';
      if (e is TimeoutException) {
        errorMessage += 'Request timed out';
      } else {
        errorMessage += e.toString();
      }
      
      state = state.copyWith(isLoading: false, error: errorMessage, products: []);
    }
  }

  /// Updates the user's preference for a product (like/dislike)
  ///
  /// Validates user authentication and product ID before updating the preference.
  /// Removes the product from the current list and loads additional products if needed.
  ///
  /// [productId] The ID of the product to update preference for
  /// [liked] Whether the user liked (true) or disliked (false) the product
  Future<void> updateProductPreference(String productId, bool liked) async {
    _logger.d('Updating product preference for productId: $productId, liked: $liked');

    // SECURITY: Validate productId format to prevent injection attacks
    if (!_isValidProductId(productId)) {
      _logger.w('Invalid product ID format: $productId');
      state = state.copyWith(error: 'Invalid product ID format');
      return;
    }

    try {
      // Get user ID if available, otherwise use guest mode
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'guest';

      // Only try to save to backend if user is authenticated
      if (user != null) {
        await updateUserPreferenceUsecase(userId, productId, liked);
        _logger.d('Successfully updated preference for product $productId');
      } else {
        _logger.d('Guest mode: Skipping backend preference save for product $productId');
      }

      // Find the product before removing it
      final swipedProduct = state.products.firstWhere((p) => p.id == productId);

      // Add to swipe history for undo functionality (keep last 5)
      final newHistory = [
        SwipeHistoryEntry(
          product: swipedProduct,
          wasLiked: liked,
          timestamp: DateTime.now(),
        ),
        ...state.swipeHistory,
      ].take(5).toList();

      // If liked, add to permanent liked products list (avoid duplicates)
      List<ProductModel> updatedLikedProducts = state.likedProducts;
      if (liked && !state.likedProducts.any((p) => p.id == productId)) {
        updatedLikedProducts = [...state.likedProducts, swipedProduct];
      }

      // Remove the product from the list since it was swiped
      final updatedProducts = state.products.where((p) => p.id != productId).toList();

      final newSwipeCount = state.totalSwipedCount + 1;

      state = state.copyWith(
        products: updatedProducts,
        swipeHistory: newHistory,
        totalSwipedCount: newSwipeCount,
        likedProducts: updatedLikedProducts,
      );

      // Persist swipe count
      await _persistenceService.saveTotalSwipedCount(newSwipeCount);

      // Load a new product to replace the swiped one if needed
      if (updatedProducts.length < 5) { // Increased threshold to ensure smooth experience
        _logger.d('Loading additional products to maintain minimum count');
        await _loadAdditionalProducts();
      }
    } catch (e) {
      _logger.e('Failed to update product preference for $productId: $e');
      String errorMessage = 'Failed to update product preference: ';
      if (e is TimeoutException) {
        errorMessage += 'Request timed out';
      } else {
        errorMessage += e.toString();
      }
      state = state.copyWith(error: errorMessage);
    }
  }

  /// Validates product ID format to prevent injection attacks
  ///
  /// Product ID should be alphanumeric with possible special characters like hyphens or underscores
  /// and should not exceed 100 characters in length.
  ///
  /// [productId] The product ID to validate
  /// Returns true if the product ID is valid, false otherwise
  bool _isValidProductId(String productId) {
    final RegExp idRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    return idRegex.hasMatch(productId) && productId.length <= 100; // Prevent overly long IDs
  }

 Future<void> addToCart(ProductModel product) async {
   _logger.d('Adding product to cart: ${product.name}');
   // SECURITY: Validate product data before adding to cart
   if (!_isValidProduct(product)) {
     _logger.w('Invalid product data when adding to cart: ${product.name}');
     state = state.copyWith(error: 'Invalid product data');
     return;
   }

   try {
     final updatedCart = [...state.cartItems, product];
     state = state.copyWith(cartItems: updatedCart);
     _logger.d('Successfully added product to cart. Cart size: ${updatedCart.length}');

     // Persist cart to local storage
     await _persistenceService.saveCart(updatedCart);
   } catch (e) {
     _logger.e('Failed to add product to cart: $e');
     state = state.copyWith(error: 'Failed to add product to cart: ${e.toString()}');
   }
 }
 
 Future<void> removeFromCart(String productId) async {
   // SECURITY: Validate product ID before removing
   if (!_isValidProductId(productId)) {
     return;
   }

   final updatedCart = state.cartItems.where((item) => item.id != productId).toList();
   state = state.copyWith(cartItems: updatedCart);

   // Persist changes
   await _persistenceService.saveCart(updatedCart);
 }

 Future<void> clearCart() async {
   state = state.copyWith(cartItems: []);

   // Clear persisted cart
   await _persistenceService.clearCart();
 }
 
 double getCartTotal() {
   return state.cartItems.fold(0, (sum, item) => sum + item.price);
 }

  /// Validates product data to prevent malicious data injection
  ///
  /// Performs multiple checks on the product data including:
  /// - Required fields are not empty
  /// - Reasonable length limits for text fields
  /// - Valid price range
  /// - Valid image URLs
  ///
  /// [product] The product to validate
  /// Returns true if the product data is valid, false otherwise
  bool _isValidProduct(ProductModel product) {
    // Check for null values
    if (product.id.isEmpty ||
        product.name.isEmpty ||
        product.price < 0 ||
        product.imageUrls.isEmpty) {
      return false;
    }
    
    // Check for reasonable length limits
    if (product.id.length > 100 ||
        product.name.length > 200 ||
        product.description.length > 10000) {
      return false;
    }
    
    // Check for valid price range
    if (product.price > 100000 || product.price < 0) {
      return false;
    }
    
    // Validate image URLs
    for (String url in product.imageUrls) {
      if (!_isValidUrl(url)) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Validates URL format to ensure it's a proper HTTP or HTTPS URL
  ///
  /// [url] The URL string to validate
  /// Returns true if the URL is valid, false otherwise
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'https' || uri.scheme == 'http');
    } catch (e) {
      return false;
    }
  }

  /// Loads additional products to maintain the minimum count in the swipe deck
  ///
  /// This method is called when the current product list is getting low
  /// to ensure a smooth user experience without running out of products to swipe.
  Future<void> _loadAdditionalProducts() async {
    _logger.d('Loading additional products');
    try {
      // Load additional products without using offset to avoid potential issues
      final additionalProducts = await getProductsUsecase.call(limit: 10, offset: 0).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Loading additional products timed out after 10 seconds');
        },
      );
      
      // Validate the products list
      if (additionalProducts == null) {
        throw Exception('Additional products list is null');
      }
      
      // Take only the first few products to add to the current list
      final productsToAdd = additionalProducts.take(5).toList();
      
      // Filter out any products that are already in the current list to avoid duplicates
      final existingProductIds = state.products.map((p) => p.id).toSet();
      final uniqueProductsToAdd = productsToAdd.where((p) => !existingProductIds.contains(p.id)).toList();
      
      final updatedProducts = [...state.products, ...uniqueProductsToAdd];
      state = state.copyWith(products: updatedProducts);
      _logger.d('Successfully loaded ${uniqueProductsToAdd.length} additional products');
    } catch (e) {
      _logger.e('Failed to load additional products: $e');
      // Handle error but don't update state since original products are still valid
      // Consider logging to an error tracking service like Sentry in production
      // Add error to state so it can be displayed to the user if needed
      String errorMessage = 'Failed to load additional products: ';
      if (e is TimeoutException) {
        errorMessage += 'Request timed out';
      } else {
        errorMessage += e.toString();
      }
      // Only update the error state if there's no current error to avoid overwriting important messages
      if (state.error == null || state.error!.isEmpty) {
        state = state.copyWith(error: errorMessage);
      }
    }
  }

  /// Undo the last swipe action
  ///
  /// Brings back the last swiped product to the top of the stack
  /// and removes it from swipe history. Also decrements the swipe count.
  ///
  /// Returns true if undo was successful, false if no history available
  bool undoLastSwipe() {
    _logger.d('Attempting to undo last swipe');

    if (state.swipeHistory.isEmpty) {
      _logger.w('No swipe history available to undo');
      return false;
    }

    try {
      // Get the last swiped item
      final lastSwipe = state.swipeHistory.first;

      // Add the product back to the front of the list
      final updatedProducts = [lastSwipe.product, ...state.products];

      // Remove from history
      final updatedHistory = state.swipeHistory.skip(1).toList();

      // If it was liked, remove from liked products list
      List<ProductModel> updatedLikedProducts = state.likedProducts;
      if (lastSwipe.wasLiked) {
        updatedLikedProducts = state.likedProducts
            .where((p) => p.id != lastSwipe.product.id)
            .toList();
      }

      state = state.copyWith(
        products: updatedProducts,
        swipeHistory: updatedHistory,
        totalSwipedCount: state.totalSwipedCount > 0 ? state.totalSwipedCount - 1 : 0,
        likedProducts: updatedLikedProducts,
      );

      _logger.i('Successfully undid swipe for product: ${lastSwipe.product.name}');
      return true;
    } catch (e) {
      _logger.e('Failed to undo swipe: $e');
      state = state.copyWith(error: 'Failed to undo swipe');
      return false;
    }
  }

  /// Check if undo is available
  bool get canUndo => state.swipeHistory.isNotEmpty;

  /// Get recommended products based on liked items
  ///
  /// Returns products similar to the user's liked products based on:
  /// - Same category
  /// - Same brand
  /// - Similar price range
  /// - High ratings
  ///
  /// Returns a list of recommended products (excluding already liked products)
  List<ProductModel> getRecommendedProducts() {
    if (state.likedProducts.isEmpty) {
      return [];
    }

    // Get all available products (from current products list)
    final availableProducts = state.products;

    // Extract preferences from liked products
    final likedBrands = state.likedProducts.map((p) => p.brand).toSet();
    final likedCategories = state.likedProducts.map((p) => p.category).toSet();
    final likedProductIds = state.likedProducts.map((p) => p.id).toSet();

    // Calculate average price of liked products
    final avgLikedPrice = state.likedProducts.fold<double>(
      0, (sum, p) => sum + p.price
    ) / state.likedProducts.length;

    // Score each available product based on similarity to liked items
    final scoredProducts = availableProducts.where((product) {
      // Don't recommend already liked products
      return !likedProductIds.contains(product.id);
    }).map((product) {
      double score = 0;

      // Same brand gets high score
      if (likedBrands.contains(product.brand)) {
        score += 50;
      }

      // Same category gets high score
      if (likedCategories.contains(product.category)) {
        score += 40;
      }

      // Similar price range (within 30%)
      final priceDiff = (product.price - avgLikedPrice).abs() / avgLikedPrice;
      if (priceDiff <= 0.3) {
        score += 30;
      }

      // High rating products
      if (product.rating >= 4.0) {
        score += 20;
      }

      return MapEntry(product, score);
    }).toList();

    // Sort by score (highest first) and take top recommendations
    scoredProducts.sort((a, b) => b.value.compareTo(a.value));

    // Return top 10 recommended products with score > 0
    return scoredProducts
        .where((entry) => entry.value > 0)
        .take(10)
        .map((entry) => entry.key)
        .toList();
  }
}
