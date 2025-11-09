import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_swipe_app/data/models/product_model.dart';
import 'package:shopping_swipe_app/presentation/providers/swipe_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Load search results if there's a query
    if (_searchQuery.isNotEmpty) {
      // In a real app, this would trigger a search usecase
      // For now, we'll use mock search functionality
      ref.read(swipeProvider.notifier).loadProducts();
    }

    final swipeState = ref.watch(swipeProvider);
    final products = swipeState.products;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search products...',
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text;
              });
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _searchQuery.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 100,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Search for products',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Enter a product name, brand, or category',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : swipeState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : products.isEmpty
                  ? const Center(child: Text('No products found'))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductItem(product, context);
                      },
                    ),
    );
  }

  Widget _buildProductItem(ProductModel product, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(
                product.imageUrls.isNotEmpty ? product.imageUrls[0] : '',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${product.brand} • ${product.currency} ${product.price.toStringAsFixed(2)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: () {
            // Add to cart
            ref.read(swipeProvider.notifier).addToCart(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} added to cart'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
        onTap: () {
          // Show product details
          _showProductDetails(context, product);
        },
      ),
    );
  }

  void _showProductDetails(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        maxChildSize: 0.8,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product image
                  Container(
                    height: 250,
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    product.brand,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    '${product.currency} ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
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
                            Navigator.pop(context);
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
                            // Buy now
                            ref.read(swipeProvider.notifier).addToCart(product);
                            Navigator.pop(context);
                            // Navigate to checkout
                            Navigator.pushNamed(context, '/cart');
                          },
                          child: const Text('Buy Now'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}