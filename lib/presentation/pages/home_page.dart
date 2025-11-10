import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'package:shopping_swipe_app/data/models/product_model.dart';
import 'package:shopping_swipe_app/presentation/providers/swipe_provider.dart';
import 'package:shopping_swipe_app/presentation/widgets/swipe_card_widget.dart';
import 'package:shopping_swipe_app/presentation/widgets/skeleton_loading.dart';
import 'package:shopping_swipe_app/presentation/widgets/animated_empty_state.dart';
import 'package:shopping_swipe_app/presentation/utils/page_transitions.dart';
import 'package:shopping_swipe_app/presentation/pages/cart_page.dart';
import 'package:shopping_swipe_app/presentation/pages/search_page.dart';
import 'package:shopping_swipe_app/presentation/pages/notifications_page.dart';
import 'package:shopping_swipe_app/presentation/constants/app_spacing.dart';

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
        leading: IconButton(
          icon: Icon(Icons.notifications_outlined, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            // Navigate to notifications page with smooth transition
            Navigator.push(context, PageTransitions.slideFromRightTransition(page: const NotificationsPage()));
          },
        ),
        title: Image.asset(
          'LOGO.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              // Navigate to search page with smooth transition
              Navigator.push(context, PageTransitions.slideFromRightTransition(page: const SearchPage()));
            },
          ),
        ],
      ),
      body: swipeState.isLoading
          ? const SkeletonSwipeStack()
          : swipeState.products.isEmpty
              ? NoProductsEmptyState(
                  onExplore: () {
                    ref.read(swipeProvider.notifier).loadProducts(userId: null);
                  },
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(swipeProvider.notifier).loadProducts(userId: null);
                  },
                  child: SwipeCardWidget(
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
                        content: Row(
                          children: [
                            Icon(Icons.shopping_cart, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('${product.name} added to cart'),
                          ],
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        duration: const Duration(milliseconds: 1000),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        action: SnackBarAction(
                          label: 'View',
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.push(context, PageTransitions.slideFromRightTransition(page: const CartPage()));
                          },
                        ),
                      ),
                    );
                  },
                ),
                ),
      // Floating undo button
      floatingActionButton: _showUndoButton && ref.read(swipeProvider.notifier).canUndo
          ? Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: FloatingActionButton.extended(
                onPressed: () {
                  final success = ref.read(swipeProvider.notifier).undoLastSwipe();
                  if (success) {
                    setState(() {
                      _showUndoButton = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.undo, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text('Swipe undone'),
                          ],
                        ),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        duration: const Duration(milliseconds: 800),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.undo),
                label: const Text('Undo'),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
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

// Loading state widget
class LoadingState extends StatelessWidget {
  const LoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(8),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading products...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

// Empty state widget
class EmptyState extends StatelessWidget {
  const EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No products available',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new items',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductDetailSheet extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductDetailSheet({Key? key, required this.product}) : super(key: key);

  @override
  ConsumerState<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends ConsumerState<ProductDetailSheet> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product image carousel
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: widget.product.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                    HapticFeedback.selectionClick();
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.product.imageUrls[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Dot indicators
              if (widget.product.imageUrls.length > 1)
                Positioned(
                  bottom: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.product.imageUrls.asMap().entries.map((entry) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == entry.key
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white.withOpacity(0.6),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Product info
          Text(
            widget.product.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),

          Text(
            widget.product.brand,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            '${widget.product.currency} ${widget.product.price.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),

          // Rating
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '${widget.product.rating.toStringAsFixed(1)} (${widget.product.reviewCount} reviews)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            widget.product.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Haptic feedback
                    HapticFeedback.mediumImpact();
                    // Add to cart
                    ref.read(swipeProvider.notifier).addToCart(widget.product);
                    Navigator.pop(context); // Close the modal
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.shopping_cart, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('${widget.product.name} added to cart'),
                          ],
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        duration: const Duration(milliseconds: 1000),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Haptic feedback
                    HapticFeedback.mediumImpact();
                    // Buy now - add to cart and navigate to checkout
                    ref.read(swipeProvider.notifier).addToCart(widget.product);
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