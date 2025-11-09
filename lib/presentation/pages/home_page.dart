import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_swipe_app/data/models/product_model.dart';
import 'package:shopping_swipe_app/presentation/providers/swipe_provider.dart';
import 'package:shopping_swipe_app/presentation/widgets/swipe_card_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _showUndoButton = false;

  @override
 void initState() {
   super.initState();
   // Load initial products after build phase completes
   WidgetsBinding.instance.addPostFrameCallback((_) {
     ref.read(swipeProvider.notifier).loadProducts(userId: null);
   });
 }

  void _onSwipeComplete(ProductModel product, bool liked) {
    // Update preference
    ref.read(swipeProvider.notifier).updateProductPreference(product.id, liked);

    // Show undo button briefly
    setState(() {
      _showUndoButton = true;
    });

    // Hide undo button after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showUndoButton = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final swipeState = ref.watch(swipeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'LOGO.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search page
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
      ),
      body: swipeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : swipeState.products.isEmpty
              ? const Center(child: Text('No products available'))
              : SwipeCardWidget(
                  products: swipeState.products,
                  onSwipe: _onSwipeComplete,
                  onUpSwipe: (product) {
                    // Show product details
                    _showProductDetails(context, product);
                  },
                  onDownSwipe: (product) {
                    // Add to cart with snackbar feedback
                    ref.read(swipeProvider.notifier).addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        backgroundColor: Colors.green,
                        duration: const Duration(milliseconds: 800),
                        action: SnackBarAction(
                          label: 'View',
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.pushNamed(context, '/cart');
                          },
                        ),
                      ),
                    );
                  },
                ),
      // Floating undo button
      floatingActionButton: _showUndoButton && ref.read(swipeProvider.notifier).canUndo
          ? FloatingActionButton.extended(
              onPressed: () {
                final success = ref.read(swipeProvider.notifier).undoLastSwipe();
                if (success) {
                  setState(() {
                    _showUndoButton = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Swipe undone'),
                      duration: Duration(milliseconds: 600),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.undo),
              label: const Text('Undo'),
              backgroundColor: Colors.orange,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
 }

  void _showProductDetails(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ProductDetailSheet(product: product),
      ),
    );
  }
}

class ProductDetailSheet extends ConsumerWidget {
  final ProductModel product;

  const ProductDetailSheet({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(
                  product.imageUrls.isNotEmpty ? product.imageUrls[0] : '',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Product info
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            product.brand,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            '${product.currency} ${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          
          // Rating
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              Text('${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)'),
            ],
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            product.description,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Add to cart
                    ref.read(swipeProvider.notifier).addToCart(product);
                    Navigator.pop(context); // Close the modal
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Buy now - add to cart and navigate to checkout
                    ref.read(swipeProvider.notifier).addToCart(product);
                    Navigator.pop(context); // Close the modal
                    Navigator.pushNamed(context, '/cart'); // Navigate to cart
                  },
                  child: const Text('Buy Now'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}