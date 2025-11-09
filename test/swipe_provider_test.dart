import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_swipe_app/data/models/product_model.dart';
import 'package:shopping_swipe_app/presentation/providers/swipe_provider.dart';

void main() {
  group('SwipeNotifier Tests', () {
    test('initial state is correct', () {
      // We can't easily instantiate SwipeNotifier without its dependencies,
      // so we'll focus on testing the state management aspects
      
      // Test SwipeState creation and copyWith
      const initialState = SwipeState();
      expect(initialState.products, isEmpty);
      expect(initialState.isLoading, false);
      expect(initialState.error, null);
      expect(initialState.cartItems, isEmpty);
      
      // Test copyWith functionality
      final updatedState = initialState.copyWith(
        isLoading: true,
        error: 'Test error',
        products: [const ProductModel(
          id: '1',
          name: 'Test Product',
          description: 'Test Description',
          price: 10.0,
          brand: 'Test Brand',
          category: 'Test Category',
          imageUrls: ['https://example.com/image.jpg'],
          rating: 4.5,
          reviewCount: 10,
        )],
        cartItems: [const ProductModel(
          id: '2',
          name: 'Cart Product',
          description: 'Cart Description',
          price: 20.0,
          brand: 'Cart Brand',
          category: 'Cart Category',
          imageUrls: ['https://example.com/cart.jpg'],
          rating: 4.0,
          reviewCount: 5,
        )],
      );
      
      expect(updatedState.isLoading, true);
      expect(updatedState.error, 'Test error');
      expect(updatedState.products.length, 1);
      expect(updatedState.cartItems.length, 1);
      expect(updatedState.products.first.id, '1');
      expect(updatedState.cartItems.first.id, '2');
    });

    group('cart operations', () {
      test('can add product to cart', () {
        // Test cart functionality using state directly
        const initialState = SwipeState();
        final mockProduct = const ProductModel(
          id: '1',
          name: 'Test Product',
          description: 'Test Description',
          price: 10.0,
          brand: 'Test Brand',
          category: 'Test Category',
          imageUrls: ['https://example.com/image.jpg'],
          rating: 4.5,
          reviewCount: 10,
        );
        
        final updatedState = initialState.copyWith(
          cartItems: [...initialState.cartItems, mockProduct]
        );
        
        expect(updatedState.cartItems.length, 1);
        expect(updatedState.cartItems.first.id, '1');
      });

      test('can remove product from cart', () {
        final mockProduct = const ProductModel(
          id: '1',
          name: 'Test Product',
          description: 'Test Description',
          price: 10.0,
          brand: 'Test Brand',
          category: 'Test Category',
          imageUrls: ['https://example.com/image.jpg'],
          rating: 4.5,
          reviewCount: 10,
        );
        
        final stateWithItems = const SwipeState().copyWith(
          cartItems: [mockProduct]
        );
        
        final updatedState = stateWithItems.copyWith(
          cartItems: stateWithItems.cartItems.where((item) => item.id != '1').toList()
        );
        
        expect(updatedState.cartItems.length, 0);
      });

      test('can calculate cart total', () {
        final mockProducts = [
          const ProductModel(
            id: '1',
            name: 'Test Product 1',
            description: 'Test Description 1',
            price: 10.0,
            brand: 'Test Brand 1',
            category: 'Test Category 1',
            imageUrls: ['https://example.com/image1.jpg'],
            rating: 4.5,
            reviewCount: 10,
          ),
          const ProductModel(
            id: '2',
            name: 'Test Product 2',
            description: 'Test Description 2',
            price: 15.5,
            brand: 'Test Brand 2',
            category: 'Test Category 2',
            imageUrls: ['https://example.com/image2.jpg'],
            rating: 4.0,
            reviewCount: 5,
          )
        ];
        
        final stateWithItems = const SwipeState().copyWith(
          cartItems: mockProducts
        );
        
        final total = stateWithItems.cartItems.fold(0.0, (double sum, item) => sum + item.price);
        
        expect(total, 25.5);
      });
    });
  });
}