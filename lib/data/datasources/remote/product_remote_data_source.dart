import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopping_swipe_app/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({int limit, int offset});
  Future<List<ProductModel>> searchProducts(String query);
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> getProductsByCategory(String category);
  Future<List<ProductModel>> getProductsByBrand(String brand);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final http.Client? client;
  final String? baseUrl;

  ProductRemoteDataSourceImpl({
    this.client,
    this.baseUrl,
  }) {
    // SECURITY: Enforce HTTPS for production API calls
    if (baseUrl != null && !baseUrl!.startsWith('https://') && !baseUrl!.startsWith('http://localhost')) {
      throw ArgumentError('Only HTTPS URLs are allowed for API endpoints (or localhost for development)');
    }
  }

  @override
  Future<List<ProductModel>> getProducts({int limit = 20, int offset = 0}) async {
    // If client and baseUrl are provided, make real API call
    if (client != null && baseUrl != null) {
      try {
        final response = await client!.get(
          Uri.parse('$baseUrl/products?limit=$limit&offset=$offset'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body)['data'];
          return data.map((json) => ProductModel.fromJson(json)).toList();
        } else {
          throw Exception('Failed to load products: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error getting products: $e');
      }
    } else {
      // For development purposes, return mock data instead of making API calls
      return _getMockProducts().skip(offset).take(limit).toList();
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    // If client and baseUrl are provided, make real API call
    if (client != null && baseUrl != null) {
      try {
        // SECURITY FIX: Validate and sanitize the query parameter
        if (!_isValidSearchQuery(query)) {
          throw Exception('Invalid search query: contains forbidden characters');
        }
        
        // SECURITY FIX: Use query parameters instead of string concatenation
        final uri = Uri.parse('$baseUrl/products/search').replace(
          queryParameters: {'q': query},
        );

        final response = await client!.get(
          uri,
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body)['data'];
          return data.map((json) => ProductModel.fromJson(json)).toList();
        } else {
          throw Exception('Failed to search products: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error searching products: $e');
      }
    } else {
      // For development purposes, return mock data instead of making API calls
      final allProducts = _getMockProducts();
      return allProducts
          .where((product) => product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              product.brand.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    // SECURITY: Validate the product ID format to prevent injection attacks
    if (!_isValidProductId(id)) {
      throw Exception('Invalid product ID format');
    }
    
    // If client and baseUrl are provided, make real API call
    if (client != null && baseUrl != null) {
      try {
        final response = await client!.get(
          Uri.parse('$baseUrl/products/$id'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body)['data'];
          return ProductModel.fromJson(data);
        } else {
          throw Exception('Failed to get product: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error getting product: $e');
      }
    } else {
      // For development purposes, return mock data instead of making API calls
      final allProducts = _getMockProducts();
      return allProducts.firstWhere((product) => product.id == id);
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    // SECURITY: Validate the category format to prevent injection attacks
    if (!_isValidCategory(category)) {
      throw Exception('Invalid category format');
    }
    
    // If client and baseUrl are provided, make real API call
    if (client != null && baseUrl != null) {
      try {
        final response = await client!.get(
          Uri.parse('$baseUrl/products/category/$category'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body)['data'];
          return data.map((json) => ProductModel.fromJson(json)).toList();
        } else {
          throw Exception('Failed to get products by category: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error getting products by category: $e');
      }
    } else {
      // For development purposes, return mock data instead of making API calls
      final allProducts = _getMockProducts();
      return allProducts.where((product) => product.category.toLowerCase().contains(category.toLowerCase())).toList();
    }
  }

  @override
  Future<List<ProductModel>> getProductsByBrand(String brand) async {
    // If client and baseUrl are provided, make real API call
    if (client != null && baseUrl != null) {
      try {
        final response = await client!.get(
          Uri.parse('$baseUrl/products/brand/$brand'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 30));

        // BUG FIX: Was 20, should be 200
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body)['data'];
          return data.map((json) => ProductModel.fromJson(json)).toList();
        } else {
          throw Exception('Failed to get products by brand: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error getting products by brand: $e');
      }
    } else {
      // For development purposes, return mock data instead of making API calls
      final allProducts = _getMockProducts();
      return allProducts.where((product) => product.brand.toLowerCase().contains(brand.toLowerCase())).toList();
    }
  }
  
  // SECURITY: Validate product ID format to prevent injection attacks
  bool _isValidProductId(String id) {
    // Product ID should be alphanumeric with possible special characters like hyphens or underscores
    final RegExp idRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    return idRegex.hasMatch(id) && id.length <= 100; // Prevent overly long IDs
  }
  
  // SECURITY: Validate search query to prevent injection attacks
  bool _isValidSearchQuery(String query) {
    // Query should not contain dangerous characters
    final RegExp queryRegex = RegExp(r'^[a-zA-Z0-9\s\-_&.,!?@#()]+$');
    return queryRegex.hasMatch(query) && query.length <= 100; // Prevent overly long queries
  }
  
  // SECURITY: Validate category format to prevent injection attacks
  bool _isValidCategory(String category) {
    // Category should be alphanumeric with possible special characters like hyphens or underscores
    final RegExp categoryRegex = RegExp(r'^[a-zA-Z0-9\s_-]+$');
    return categoryRegex.hasMatch(category) && category.length <= 50; // Prevent overly long categories
  }
  
  // SECURITY: Validate brand format to prevent injection attacks
  bool _isValidBrand(String brand) {
    // Brand should be alphanumeric with possible special characters like hyphens or underscores
    final RegExp brandRegex = RegExp(r'^[a-zA-Z0-9\s_-]+$');
    return brandRegex.hasMatch(brand) && brand.length <= 50; // Prevent overly long brands
  }
}

List<ProductModel> _getMockProducts() {
  return [
    // Men's T-Shirts and Tops
    ProductModel(
      id: 'm1',
      name: 'Classic White Cotton T-Shirt',
      description: 'Premium 100% cotton crew neck t-shirt. Comfortable, breathable, and perfect for everyday wear.',
      price: 24.99,
      brand: 'H&M',
      category: 'Men\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 234,
      currency: '\$',
      attributes: {'color': 'White', 'size': 'M', 'material': 'Cotton', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm2',
      name: 'Striped Casual Polo Shirt',
      description: 'Stylish striped polo shirt with button collar. Perfect for smart casual occasions.',
      price: 39.99,
      brand: 'Tommy Hilfiger',
      category: 'Men\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=800&h=800&fit=crop',
      ],
      rating: 4.3,
      reviewCount: 156,
      currency: '\$',
      attributes: {'color': 'Navy/White', 'size': 'L', 'material': 'Cotton Blend', 'fit': 'Slim'},
    ),
    ProductModel(
      id: 'm3',
      name: 'Graphic Print T-Shirt',
      description: 'Trendy graphic print t-shirt with modern design. Made from soft, comfortable fabric.',
      price: 29.99,
      brand: 'Zara',
      category: 'Men\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=800&h=800&fit=crop',
      ],
      rating: 4.1,
      reviewCount: 189,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'M', 'material': 'Cotton', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm4',
      name: 'V-Neck Plain T-Shirt',
      description: 'Essential v-neck t-shirt in solid color. Versatile and comfortable for daily wear.',
      price: 19.99,
      brand: 'Uniqlo',
      category: 'Men\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1622445275576-721325c15110?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 312,
      currency: '\$',
      attributes: {'color': 'Grey', 'size': 'S', 'material': 'Cotton', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm5',
      name: 'Long Sleeve Henley Shirt',
      description: 'Classic henley shirt with button placket. Perfect for layering in cooler weather.',
      price: 34.99,
      brand: 'Gap',
      category: 'Men\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 98,
      currency: '\$',
      attributes: {'color': 'Burgundy', 'size': 'M', 'material': 'Cotton', 'fit': 'Regular'},
    ),

    // Men's Shirts
    ProductModel(
      id: 'm6',
      name: 'Slim Fit Oxford Shirt',
      description: 'Classic oxford button-down shirt. Perfect for office or formal occasions.',
      price: 49.99,
      brand: 'Ralph Lauren',
      category: 'Men\'s Shirts',
      imageUrls: [
        'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 267,
      currency: '\$',
      attributes: {'color': 'Light Blue', 'size': 'M', 'material': 'Cotton', 'fit': 'Slim'},
    ),
    ProductModel(
      id: 'm7',
      name: 'Linen Casual Shirt',
      description: 'Breathable linen shirt perfect for summer. Relaxed fit with natural texture.',
      price: 54.99,
      brand: 'Zara',
      category: 'Men\'s Shirts',
      imageUrls: [
        'https://images.unsplash.com/photo-1603252109303-2751441dd157?w=800&h=800&fit=crop',
      ],
      rating: 4.2,
      reviewCount: 143,
      currency: '\$',
      attributes: {'color': 'White', 'size': 'L', 'material': 'Linen', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm8',
      name: 'Checkered Flannel Shirt',
      description: 'Cozy flannel shirt with classic check pattern. Great for casual wear.',
      price: 44.99,
      brand: 'Levi\'s',
      category: 'Men\'s Shirts',
      imageUrls: [
        'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 201,
      currency: '\$',
      attributes: {'color': 'Red/Black', 'size': 'M', 'material': 'Cotton Flannel', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm9',
      name: 'Formal Dress Shirt',
      description: 'Crisp white dress shirt for formal events. Non-iron fabric for easy care.',
      price: 59.99,
      brand: 'Calvin Klein',
      category: 'Men\'s Shirts',
      imageUrls: [
        'https://images.unsplash.com/photo-1602810319428-019690571b5b?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 178,
      currency: '\$',
      attributes: {'color': 'White', 'size': 'M', 'material': 'Cotton Blend', 'fit': 'Slim'},
    ),
    ProductModel(
      id: 'm10',
      name: 'Denim Chambray Shirt',
      description: 'Versatile chambray shirt with classic denim look. Can be dressed up or down.',
      price: 46.99,
      brand: 'Gap',
      category: 'Men\'s Shirts',
      imageUrls: [
        'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800&h=800&fit=crop',
      ],
      rating: 4.3,
      reviewCount: 165,
      currency: '\$',
      attributes: {'color': 'Light Blue', 'size': 'L', 'material': 'Denim', 'fit': 'Regular'},
    ),

    // Men's Pants and Jeans
    ProductModel(
      id: 'm11',
      name: 'Classic Straight Leg Jeans',
      description: 'Timeless straight leg jeans in dark wash. Comfortable and durable.',
      price: 69.99,
      brand: 'Levi\'s',
      category: 'Men\'s Jeans',
      imageUrls: [
        'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800&h=800&fit=crop',
      ],
      rating: 4.8,
      reviewCount: 456,
      currency: '\$',
      attributes: {'color': 'Dark Blue', 'size': '32x32', 'material': 'Denim', 'fit': 'Straight'},
    ),
    ProductModel(
      id: 'm12',
      name: 'Slim Fit Black Jeans',
      description: 'Modern slim fit jeans in classic black. Perfect for casual and semi-formal occasions.',
      price: 64.99,
      brand: 'H&M',
      category: 'Men\'s Jeans',
      imageUrls: [
        'https://images.unsplash.com/photo-1624378515195-6bbdb73dff1a?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 289,
      currency: '\$',
      attributes: {'color': 'Black', 'size': '30x32', 'material': 'Stretch Denim', 'fit': 'Slim'},
    ),
    ProductModel(
      id: 'm13',
      name: 'Chino Pants',
      description: 'Classic khaki chino pants. Versatile and comfortable for work or casual wear.',
      price: 54.99,
      brand: 'Dockers',
      category: 'Men\'s Pants',
      imageUrls: [
        'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 334,
      currency: '\$',
      attributes: {'color': 'Khaki', 'size': '32x30', 'material': 'Cotton Twill', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm14',
      name: 'Athletic Joggers',
      description: 'Comfortable joggers with elastic waistband. Perfect for workouts or lounging.',
      price: 39.99,
      brand: 'Nike',
      category: 'Men\'s Pants',
      imageUrls: [
        'https://images.unsplash.com/photo-1555689502-c4b22d76c56f?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 412,
      currency: '\$',
      attributes: {'color': 'Grey', 'size': 'M', 'material': 'Polyester', 'fit': 'Tapered'},
    ),
    ProductModel(
      id: 'm15',
      name: 'Cargo Pants',
      description: 'Utility cargo pants with multiple pockets. Durable and functional.',
      price: 59.99,
      brand: 'Carhartt',
      category: 'Men\'s Pants',
      imageUrls: [
        'https://images.unsplash.com/photo-1624378515429-670804fe9e16?w=800&h=800&fit=crop',
      ],
      rating: 4.3,
      reviewCount: 187,
      currency: '\$',
      attributes: {'color': 'Olive', 'size': '34x32', 'material': 'Cotton Canvas', 'fit': 'Relaxed'},
    ),

    // Men's Outerwear
    ProductModel(
      id: 'm16',
      name: 'Classic Denim Jacket',
      description: 'Timeless denim jacket with button front. A wardrobe essential.',
      price: 79.99,
      brand: 'Levi\'s',
      category: 'Men\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 389,
      currency: '\$',
      attributes: {'color': 'Medium Blue', 'size': 'M', 'material': 'Denim', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm17',
      name: 'Bomber Jacket',
      description: 'Stylish bomber jacket with ribbed cuffs and hem. Perfect for spring and fall.',
      price: 89.99,
      brand: 'Zara',
      category: 'Men\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 245,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'L', 'material': 'Polyester', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm18',
      name: 'Puffer Jacket',
      description: 'Warm puffer jacket with hood. Insulated for cold weather.',
      price: 129.99,
      brand: 'The North Face',
      category: 'Men\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800&h=800&fit=crop',
      ],
      rating: 4.8,
      reviewCount: 512,
      currency: '\$',
      attributes: {'color': 'Navy', 'size': 'M', 'material': 'Nylon', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm19',
      name: 'Leather Jacket',
      description: 'Genuine leather motorcycle jacket. Timeless style with modern edge.',
      price: 249.99,
      brand: 'AllSaints',
      category: 'Men\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1521223890158-f9f7c3d5d504?w=800&h=800&fit=crop',
      ],
      rating: 4.9,
      reviewCount: 167,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'M', 'material': 'Leather', 'fit': 'Slim'},
    ),
    ProductModel(
      id: 'm20',
      name: 'Windbreaker Jacket',
      description: 'Lightweight windbreaker with packable design. Great for outdoor activities.',
      price: 49.99,
      brand: 'Nike',
      category: 'Men\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&h=800&fit=crop',
      ],
      rating: 4.2,
      reviewCount: 298,
      currency: '\$',
      attributes: {'color': 'Red', 'size': 'L', 'material': 'Nylon', 'fit': 'Regular'},
    ),

    // Men's Shoes
    ProductModel(
      id: 'm21',
      name: 'Classic White Sneakers',
      description: 'Clean white leather sneakers. Versatile and comfortable for everyday wear.',
      price: 79.99,
      brand: 'Adidas',
      category: 'Men\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 567,
      currency: '\$',
      attributes: {'color': 'White', 'size': '10', 'material': 'Leather', 'type': 'Sneakers'},
    ),
    ProductModel(
      id: 'm22',
      name: 'Running Shoes',
      description: 'High-performance running shoes with cushioned sole. Perfect for athletes.',
      price: 119.99,
      brand: 'Nike',
      category: 'Men\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&h=800&fit=crop',
      ],
      rating: 4.8,
      reviewCount: 789,
      currency: '\$',
      attributes: {'color': 'Black/White', 'size': '11', 'material': 'Mesh', 'type': 'Athletic'},
    ),
    ProductModel(
      id: 'm23',
      name: 'Canvas Slip-On Shoes',
      description: 'Casual slip-on shoes with canvas upper. Easy to wear and comfortable.',
      price: 44.99,
      brand: 'Vans',
      category: 'Men\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 423,
      currency: '\$',
      attributes: {'color': 'Navy', 'size': '9', 'material': 'Canvas', 'type': 'Casual'},
    ),
    ProductModel(
      id: 'm24',
      name: 'Leather Oxford Shoes',
      description: 'Classic oxford dress shoes. Perfect for formal occasions and office wear.',
      price: 139.99,
      brand: 'Clarks',
      category: 'Men\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 234,
      currency: '\$',
      attributes: {'color': 'Brown', 'size': '10', 'material': 'Leather', 'type': 'Formal'},
    ),
    ProductModel(
      id: 'm25',
      name: 'High-Top Sneakers',
      description: 'Stylish high-top sneakers with premium construction. Great for street style.',
      price: 89.99,
      brand: 'Converse',
      category: 'Men\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 512,
      currency: '\$',
      attributes: {'color': 'Black', 'size': '10.5', 'material': 'Canvas', 'type': 'Sneakers'},
    ),

    // Women's Dresses
    ProductModel(
      id: 'w1',
      name: 'Floral Summer Dress',
      description: 'Light and breezy floral dress perfect for summer days. Feminine and comfortable.',
      price: 59.99,
      brand: 'Zara',
      category: 'Women\'s Dresses',
      imageUrls: [
        'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 345,
      currency: '\$',
      attributes: {'color': 'Floral Print', 'size': 'M', 'material': 'Cotton', 'length': 'Midi'},
    ),
    ProductModel(
      id: 'w2',
      name: 'Little Black Dress',
      description: 'Classic little black dress. Elegant and versatile for any occasion.',
      price: 79.99,
      brand: 'H&M',
      category: 'Women\'s Dresses',
      imageUrls: [
        'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=800&h=800&fit=crop',
      ],
      rating: 4.8,
      reviewCount: 567,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'S', 'material': 'Polyester', 'length': 'Mini'},
    ),
    ProductModel(
      id: 'w3',
      name: 'Maxi Wrap Dress',
      description: 'Flowing maxi wrap dress with tie waist. Perfect for both casual and formal settings.',
      price: 69.99,
      brand: 'Mango',
      category: 'Women\'s Dresses',
      imageUrls: [
        'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 289,
      currency: '\$',
      attributes: {'color': 'Red', 'size': 'M', 'material': 'Rayon', 'length': 'Maxi'},
    ),
    ProductModel(
      id: 'w4',
      name: 'Casual Shirt Dress',
      description: 'Relaxed shirt dress with button front. Comfortable and stylish for everyday wear.',
      price: 49.99,
      brand: 'Gap',
      category: 'Women\'s Dresses',
      imageUrls: [
        'https://images.unsplash.com/photo-1596783074918-c84cb06531ca?w=800&h=800&fit=crop',
      ],
      rating: 4.3,
      reviewCount: 198,
      currency: '\$',
      attributes: {'color': 'Blue', 'size': 'L', 'material': 'Cotton', 'length': 'Midi'},
    ),
    ProductModel(
      id: 'w5',
      name: 'Cocktail Dress',
      description: 'Elegant cocktail dress with lace detail. Perfect for evening events.',
      price: 129.99,
      brand: 'Asos',
      category: 'Women\'s Dresses',
      imageUrls: [
        'https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 234,
      currency: '\$',
      attributes: {'color': 'Navy', 'size': 'M', 'material': 'Lace', 'length': 'Knee'},
    ),

    // Women's Tops
    ProductModel(
      id: 'w6',
      name: 'Silk Blouse',
      description: 'Luxurious silk blouse with elegant drape. Perfect for office or special occasions.',
      price: 64.99,
      brand: 'Massimo Dutti',
      category: 'Women\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1564859228273-274232fdb516?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 178,
      currency: '\$',
      attributes: {'color': 'Cream', 'size': 'S', 'material': 'Silk', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w7',
      name: 'Cotton T-Shirt',
      description: 'Basic cotton t-shirt in various colors. Soft and comfortable for daily wear.',
      price: 19.99,
      brand: 'Uniqlo',
      category: 'Women\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 456,
      currency: '\$',
      attributes: {'color': 'White', 'size': 'M', 'material': 'Cotton', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w8',
      name: 'Off-Shoulder Top',
      description: 'Trendy off-shoulder top with elastic neckline. Stylish and feminine.',
      price: 34.99,
      brand: 'Forever 21',
      category: 'Women\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=800&h=800&fit=crop',
      ],
      rating: 4.2,
      reviewCount: 267,
      currency: '\$',
      attributes: {'color': 'Pink', 'size': 'S', 'material': 'Cotton Blend', 'fit': 'Fitted'},
    ),
    ProductModel(
      id: 'w9',
      name: 'Lace Camisole',
      description: 'Delicate lace camisole perfect for layering or wearing alone.',
      price: 29.99,
      brand: 'H&M',
      category: 'Women\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1590735213920-68192a487bc2?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 312,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'M', 'material': 'Lace', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w10',
      name: 'Striped Crop Top',
      description: 'Casual striped crop top. Perfect for pairing with high-waisted bottoms.',
      price: 24.99,
      brand: 'Zara',
      category: 'Women\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1578932750294-f5075e85f44a?w=800&h=800&fit=crop',
      ],
      rating: 4.3,
      reviewCount: 189,
      currency: '\$',
      attributes: {'color': 'Blue/White', 'size': 'S', 'material': 'Cotton', 'fit': 'Cropped'},
    ),

    // Women's Bottoms
    ProductModel(
      id: 'w11',
      name: 'High-Waisted Skinny Jeans',
      description: 'Flattering high-waisted skinny jeans. Stretch denim for comfort.',
      price: 69.99,
      brand: 'Levi\'s',
      category: 'Women\'s Jeans',
      imageUrls: [
        'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 623,
      currency: '\$',
      attributes: {'color': 'Dark Blue', 'size': '28', 'material': 'Stretch Denim', 'fit': 'Skinny'},
    ),
    ProductModel(
      id: 'w12',
      name: 'Wide Leg Pants',
      description: 'Flowing wide leg pants with elastic waist. Comfortable and stylish.',
      price: 54.99,
      brand: 'Mango',
      category: 'Women\'s Pants',
      imageUrls: [
        'https://images.unsplash.com/photo-1594633313593-bab3825d0caf?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 234,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'M', 'material': 'Polyester', 'fit': 'Wide'},
    ),
    ProductModel(
      id: 'w13',
      name: 'Denim Shorts',
      description: 'Classic denim shorts with distressed details. Perfect for summer.',
      price: 39.99,
      brand: 'American Eagle',
      category: 'Women\'s Shorts',
      imageUrls: [
        'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 445,
      currency: '\$',
      attributes: {'color': 'Light Blue', 'size': '6', 'material': 'Denim', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w14',
      name: 'Pencil Skirt',
      description: 'Classic pencil skirt for office wear. Sleek and professional.',
      price: 44.99,
      brand: 'Banana Republic',
      category: 'Women\'s Skirts',
      imageUrls: [
        'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 187,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'S', 'material': 'Polyester', 'length': 'Knee'},
    ),
    ProductModel(
      id: 'w15',
      name: 'A-Line Mini Skirt',
      description: 'Flirty A-line mini skirt. Fun and versatile for casual wear.',
      price: 34.99,
      brand: 'H&M',
      category: 'Women\'s Skirts',
      imageUrls: [
        'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=800&h=800&fit=crop',
      ],
      rating: 4.3,
      reviewCount: 298,
      currency: '\$',
      attributes: {'color': 'Burgundy', 'size': 'M', 'material': 'Cotton', 'length': 'Mini'},
    ),

    // Women's Outerwear
    ProductModel(
      id: 'w16',
      name: 'Trench Coat',
      description: 'Classic trench coat with belt. Timeless and elegant.',
      price: 149.99,
      brand: 'Burberry',
      category: 'Women\'s Coats',
      imageUrls: [
        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&h=800&fit=crop',
      ],
      rating: 4.9,
      reviewCount: 312,
      currency: '\$',
      attributes: {'color': 'Beige', 'size': 'M', 'material': 'Cotton', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w17',
      name: 'Wool Blend Coat',
      description: 'Warm wool blend coat with button closure. Perfect for winter.',
      price: 179.99,
      brand: 'J.Crew',
      category: 'Women\'s Coats',
      imageUrls: [
        'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 267,
      currency: '\$',
      attributes: {'color': 'Camel', 'size': 'S', 'material': 'Wool Blend', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w18',
      name: 'Leather Biker Jacket',
      description: 'Edgy leather biker jacket with asymmetric zip. Cool and stylish.',
      price: 199.99,
      brand: 'AllSaints',
      category: 'Women\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=800&fit=crop',
      ],
      rating: 4.8,
      reviewCount: 189,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'M', 'material': 'Leather', 'fit': 'Fitted'},
    ),
    ProductModel(
      id: 'w19',
      name: 'Denim Jacket',
      description: 'Classic denim jacket. A versatile wardrobe staple.',
      price: 69.99,
      brand: 'Levi\'s',
      category: 'Women\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 534,
      currency: '\$',
      attributes: {'color': 'Light Blue', 'size': 'M', 'material': 'Denim', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w20',
      name: 'Puffer Vest',
      description: 'Lightweight puffer vest perfect for layering. Warm and practical.',
      price: 59.99,
      brand: 'Uniqlo',
      category: 'Women\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 356,
      currency: '\$',
      attributes: {'color': 'Navy', 'size': 'S', 'material': 'Nylon', 'fit': 'Regular'},
    ),

    // Women's Shoes
    ProductModel(
      id: 'w21',
      name: 'Classic Black Pumps',
      description: 'Timeless black pumps with mid heel. Perfect for office and formal events.',
      price: 89.99,
      brand: 'Nine West',
      category: 'Women\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 423,
      currency: '\$',
      attributes: {'color': 'Black', 'size': '7', 'material': 'Leather', 'heel': '3 inches'},
    ),
    ProductModel(
      id: 'w22',
      name: 'White Canvas Sneakers',
      description: 'Clean white canvas sneakers. Comfortable and versatile.',
      price: 54.99,
      brand: 'Vans',
      category: 'Women\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1560769629-975ec94e6a86?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 678,
      currency: '\$',
      attributes: {'color': 'White', 'size': '8', 'material': 'Canvas', 'type': 'Sneakers'},
    ),
    ProductModel(
      id: 'w23',
      name: 'Ankle Boots',
      description: 'Stylish ankle boots with block heel. Perfect for fall and winter.',
      price: 119.99,
      brand: 'Steve Madden',
      category: 'Women\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 345,
      currency: '\$',
      attributes: {'color': 'Brown', 'size': '7.5', 'material': 'Leather', 'heel': '2 inches'},
    ),
    ProductModel(
      id: 'w24',
      name: 'Strappy Sandals',
      description: 'Elegant strappy sandals with slim heel. Perfect for summer events.',
      price: 74.99,
      brand: 'Zara',
      category: 'Women\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 234,
      currency: '\$',
      attributes: {'color': 'Nude', 'size': '8', 'material': 'Synthetic', 'heel': '4 inches'},
    ),
    ProductModel(
      id: 'w25',
      name: 'Ballet Flats',
      description: 'Comfortable ballet flats for everyday wear. Classic and feminine.',
      price: 49.99,
      brand: 'Sam Edelman',
      category: 'Women\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1603808033192-082d6919d3e1?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 512,
      currency: '\$',
      attributes: {'color': 'Black', 'size': '7', 'material': 'Leather', 'type': 'Flats'},
    ),

    // Additional Men's Items
    ProductModel(
      id: 'm26',
      name: 'Sports Performance T-Shirt',
      description: 'Moisture-wicking performance tee for workouts and sports.',
      price: 34.99,
      brand: 'Nike',
      category: 'Men\'s Athletic Wear',
      imageUrls: [
        'https://images.unsplash.com/photo-1622445275576-721325c15110?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 445,
      currency: '\$',
      attributes: {'color': 'Navy', 'size': 'L', 'material': 'Polyester', 'fit': 'Athletic'},
    ),
    ProductModel(
      id: 'm27',
      name: 'Compression Shorts',
      description: 'Athletic compression shorts for training and running.',
      price: 44.99,
      brand: 'Under Armour',
      category: 'Men\'s Athletic Wear',
      imageUrls: [
        'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 367,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'M', 'material': 'Spandex', 'fit': 'Compression'},
    ),
    ProductModel(
      id: 'm28',
      name: 'Swim Trunks',
      description: 'Quick-dry swim trunks with mesh lining. Perfect for beach and pool.',
      price: 39.99,
      brand: 'Speedo',
      category: 'Men\'s Swimwear',
      imageUrls: [
        'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800&h=800&fit=crop',
      ],
      rating: 4.3,
      reviewCount: 289,
      currency: '\$',
      attributes: {'color': 'Blue', 'size': 'M', 'material': 'Nylon', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm29',
      name: 'Hooded Sweatshirt',
      description: 'Comfortable cotton hoodie with kangaroo pocket. Perfect for casual wear.',
      price: 54.99,
      brand: 'Champion',
      category: 'Men\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 623,
      currency: '\$',
      attributes: {'color': 'Grey', 'size': 'L', 'material': 'Cotton', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm30',
      name: 'Crew Neck Sweatshirt',
      description: 'Classic crew neck sweatshirt. Soft and comfortable.',
      price: 44.99,
      brand: 'H&M',
      category: 'Men\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 398,
      currency: '\$',
      attributes: {'color': 'Navy', 'size': 'M', 'material': 'Cotton Blend', 'fit': 'Regular'},
    ),

    // Additional Women's Items
    ProductModel(
      id: 'w26',
      name: 'Yoga Leggings',
      description: 'High-waisted yoga leggings with four-way stretch. Perfect for workouts.',
      price: 49.99,
      brand: 'Lululemon',
      category: 'Women\'s Athletic Wear',
      imageUrls: [
        'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=800&h=800&fit=crop',
      ],
      rating: 4.8,
      reviewCount: 789,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'M', 'material': 'Spandex', 'fit': 'Compression'},
    ),
    ProductModel(
      id: 'w27',
      name: 'Sports Bra',
      description: 'High-support sports bra for intense workouts. Comfortable and secure.',
      price: 39.99,
      brand: 'Nike',
      category: 'Women\'s Athletic Wear',
      imageUrls: [
        'https://images.unsplash.com/photo-1518459384564-89e93e24eb31?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 534,
      currency: '\$',
      attributes: {'color': 'Pink', 'size': 'M', 'material': 'Polyester', 'support': 'High'},
    ),
    ProductModel(
      id: 'w28',
      name: 'Bikini Set',
      description: 'Two-piece bikini set with adjustable straps. Perfect for beach days.',
      price: 44.99,
      brand: 'Aerie',
      category: 'Women\'s Swimwear',
      imageUrls: [
        'https://images.unsplash.com/photo-1551488831-00167b16eac5?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 412,
      currency: '\$',
      attributes: {'color': 'Coral', 'size': 'S', 'material': 'Nylon', 'style': 'Two-piece'},
    ),
    ProductModel(
      id: 'w29',
      name: 'Knit Sweater',
      description: 'Cozy knit sweater perfect for fall and winter. Soft and warm.',
      price: 64.99,
      brand: 'Mango',
      category: 'Women\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 345,
      currency: '\$',
      attributes: {'color': 'Cream', 'size': 'M', 'material': 'Wool Blend', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w30',
      name: 'Cardigan Sweater',
      description: 'Versatile cardigan with button front. Great for layering.',
      price: 54.99,
      brand: 'Gap',
      category: 'Women\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 267,
      currency: '\$',
      attributes: {'color': 'Grey', 'size': 'L', 'material': 'Acrylic', 'fit': 'Regular'},
    ),

    // More Men's Clothing
    ProductModel(
      id: 'm31',
      name: 'Track Pants',
      description: 'Athletic track pants with side stripes. Comfortable for sports and lounging.',
      price: 49.99,
      brand: 'Adidas',
      category: 'Men\'s Pants',
      imageUrls: [
        'https://images.unsplash.com/photo-1555689502-c4b22d76c56f?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 456,
      currency: '\$',
      attributes: {'color': 'Black/White', 'size': 'L', 'material': 'Polyester', 'fit': 'Athletic'},
    ),
    ProductModel(
      id: 'm32',
      name: 'Ripped Jeans',
      description: 'Distressed jeans with ripped knees. Modern and edgy style.',
      price: 74.99,
      brand: 'Zara',
      category: 'Men\'s Jeans',
      imageUrls: [
        'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800&h=800&fit=crop',
      ],
      rating: 4.2,
      reviewCount: 312,
      currency: '\$',
      attributes: {'color': 'Light Blue', 'size': '32x32', 'material': 'Denim', 'fit': 'Slim'},
    ),
    ProductModel(
      id: 'm33',
      name: 'Formal Suit Pants',
      description: 'Classic dress pants for formal occasions. Tailored fit.',
      price: 89.99,
      brand: 'Hugo Boss',
      category: 'Men\'s Pants',
      imageUrls: [
        'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=800&h=800&fit=crop',
      ],
      rating: 4.8,
      reviewCount: 234,
      currency: '\$',
      attributes: {'color': 'Black', 'size': '34x32', 'material': 'Wool Blend', 'fit': 'Tailored'},
    ),
    ProductModel(
      id: 'm34',
      name: 'Corduroy Pants',
      description: 'Retro corduroy pants with soft texture. Comfortable and stylish.',
      price: 64.99,
      brand: 'J.Crew',
      category: 'Men\'s Pants',
      imageUrls: [
        'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 189,
      currency: '\$',
      attributes: {'color': 'Brown', 'size': '32x30', 'material': 'Corduroy', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm35',
      name: 'Basketball Shorts',
      description: 'Lightweight basketball shorts with mesh fabric. Perfect for sports.',
      price: 34.99,
      brand: 'Nike',
      category: 'Men\'s Shorts',
      imageUrls: [
        'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 567,
      currency: '\$',
      attributes: {'color': 'Red', 'size': 'L', 'material': 'Mesh', 'fit': 'Athletic'},
    ),

    // More Women's Clothing
    ProductModel(
      id: 'w31',
      name: 'Pleated Midi Skirt',
      description: 'Elegant pleated midi skirt. Perfect for both casual and formal settings.',
      price: 59.99,
      brand: 'Zara',
      category: 'Women\'s Skirts',
      imageUrls: [
        'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 378,
      currency: '\$',
      attributes: {'color': 'Navy', 'size': 'M', 'material': 'Polyester', 'length': 'Midi'},
    ),
    ProductModel(
      id: 'w32',
      name: 'Mom Jeans',
      description: 'High-waisted mom jeans with relaxed fit. Trendy and comfortable.',
      price: 64.99,
      brand: 'H&M',
      category: 'Women\'s Jeans',
      imageUrls: [
        'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 534,
      currency: '\$',
      attributes: {'color': 'Light Blue', 'size': '27', 'material': 'Denim', 'fit': 'Relaxed'},
    ),
    ProductModel(
      id: 'w33',
      name: 'Palazzo Pants',
      description: 'Flowy palazzo pants with wide legs. Comfortable and elegant.',
      price: 49.99,
      brand: 'Mango',
      category: 'Women\'s Pants',
      imageUrls: [
        'https://images.unsplash.com/photo-1594633313593-bab3825d0caf?w=800&h=800&fit=crop',
      ],
      rating: 4.3,
      reviewCount: 267,
      currency: '\$',
      attributes: {'color': 'Beige', 'size': 'S', 'material': 'Rayon', 'fit': 'Wide'},
    ),
    ProductModel(
      id: 'w34',
      name: 'Bodycon Dress',
      description: 'Figure-hugging bodycon dress. Perfect for nights out.',
      price: 44.99,
      brand: 'Forever 21',
      category: 'Women\'s Dresses',
      imageUrls: [
        'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 423,
      currency: '\$',
      attributes: {'color': 'Red', 'size': 'S', 'material': 'Spandex', 'length': 'Mini'},
    ),
    ProductModel(
      id: 'w35',
      name: 'Jumpsuit',
      description: 'Stylish one-piece jumpsuit with waist tie. Effortless and chic.',
      price: 79.99,
      brand: 'Asos',
      category: 'Women\'s Jumpsuits',
      imageUrls: [
        'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 312,
      currency: '\$',
      attributes: {'color': 'Green', 'size': 'M', 'material': 'Linen', 'fit': 'Regular'},
    ),

    // Additional Men's Outerwear
    ProductModel(
      id: 'm36',
      name: 'Peacoat',
      description: 'Classic wool peacoat with double-breasted design. Timeless winter essential.',
      price: 159.99,
      brand: 'J.Crew',
      category: 'Men\'s Coats',
      imageUrls: [
        'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 234,
      currency: '\$',
      attributes: {'color': 'Navy', 'size': 'L', 'material': 'Wool', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm37',
      name: 'Parka Jacket',
      description: 'Insulated parka with fur-trimmed hood. Warm and weather-resistant.',
      price: 189.99,
      brand: 'Canada Goose',
      category: 'Men\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800&h=800&fit=crop',
      ],
      rating: 4.9,
      reviewCount: 445,
      currency: '\$',
      attributes: {'color': 'Olive', 'size': 'M', 'material': 'Nylon', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm38',
      name: 'Varsity Jacket',
      description: 'Retro varsity jacket with contrast sleeves. Cool and casual.',
      price: 94.99,
      brand: 'Champion',
      category: 'Men\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 298,
      currency: '\$',
      attributes: {'color': 'Navy/White', 'size': 'L', 'material': 'Wool Blend', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm39',
      name: 'Rain Jacket',
      description: 'Waterproof rain jacket with hood. Essential for wet weather.',
      price: 69.99,
      brand: 'Columbia',
      category: 'Men\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 367,
      currency: '\$',
      attributes: {'color': 'Yellow', 'size': 'M', 'material': 'Nylon', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm40',
      name: 'Blazer',
      description: 'Tailored blazer for formal occasions. Sharp and sophisticated.',
      price: 149.99,
      brand: 'Hugo Boss',
      category: 'Men\'s Blazers',
      imageUrls: [
        'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800&h=800&fit=crop',
      ],
      rating: 4.8,
      reviewCount: 289,
      currency: '\$',
      attributes: {'color': 'Charcoal', 'size': 'M', 'material': 'Wool', 'fit': 'Tailored'},
    ),

    // Additional Women's Outerwear
    ProductModel(
      id: 'w36',
      name: 'Blazer Jacket',
      description: 'Professional blazer for office wear. Sleek and polished.',
      price: 99.99,
      brand: 'Banana Republic',
      category: 'Women\'s Blazers',
      imageUrls: [
        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 345,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'M', 'material': 'Polyester', 'fit': 'Fitted'},
    ),
    ProductModel(
      id: 'w37',
      name: 'Cape Coat',
      description: 'Elegant cape-style coat. Unique and fashionable.',
      price: 139.99,
      brand: 'Zara',
      category: 'Women\'s Coats',
      imageUrls: [
        'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 198,
      currency: '\$',
      attributes: {'color': 'Grey', 'size': 'S', 'material': 'Wool', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w38',
      name: 'Faux Fur Coat',
      description: 'Luxurious faux fur coat. Glamorous and warm.',
      price: 169.99,
      brand: 'H&M',
      category: 'Women\'s Coats',
      imageUrls: [
        'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 267,
      currency: '\$',
      attributes: {'color': 'White', 'size': 'M', 'material': 'Faux Fur', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w39',
      name: 'Quilted Jacket',
      description: 'Lightweight quilted jacket. Perfect for transitional seasons.',
      price: 89.99,
      brand: 'Uniqlo',
      category: 'Women\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 423,
      currency: '\$',
      attributes: {'color': 'Pink', 'size': 'S', 'material': 'Nylon', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w40',
      name: 'Suede Jacket',
      description: 'Soft suede jacket with fringe detail. Bohemian and stylish.',
      price: 159.99,
      brand: 'Mango',
      category: 'Women\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 189,
      currency: '\$',
      attributes: {'color': 'Tan', 'size': 'M', 'material': 'Suede', 'fit': 'Regular'},
    ),

    // More Men's Shoes
    ProductModel(
      id: 'm41',
      name: 'Chelsea Boots',
      description: 'Classic Chelsea boots with elastic side panels. Versatile and stylish.',
      price: 129.99,
      brand: 'Clarks',
      category: 'Men\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 367,
      currency: '\$',
      attributes: {'color': 'Brown', 'size': '10', 'material': 'Leather', 'type': 'Boots'},
    ),
    ProductModel(
      id: 'm42',
      name: 'Loafers',
      description: 'Slip-on loafers for casual and semi-formal wear. Comfortable and elegant.',
      price: 94.99,
      brand: 'Cole Haan',
      category: 'Men\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 289,
      currency: '\$',
      attributes: {'color': 'Black', 'size': '9.5', 'material': 'Leather', 'type': 'Loafers'},
    ),
    ProductModel(
      id: 'm43',
      name: 'Hiking Boots',
      description: 'Rugged hiking boots with ankle support. Perfect for outdoor adventures.',
      price: 139.99,
      brand: 'Timberland',
      category: 'Men\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=800&h=800&fit=crop',
      ],
      rating: 4.8,
      reviewCount: 534,
      currency: '\$',
      attributes: {'color': 'Brown', 'size': '11', 'material': 'Leather', 'type': 'Boots'},
    ),
    ProductModel(
      id: 'm44',
      name: 'Boat Shoes',
      description: 'Classic boat shoes with non-marking sole. Perfect for summer.',
      price: 74.99,
      brand: 'Sperry',
      category: 'Men\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 312,
      currency: '\$',
      attributes: {'color': 'Navy', 'size': '10', 'material': 'Leather', 'type': 'Casual'},
    ),
    ProductModel(
      id: 'm45',
      name: 'Slides',
      description: 'Comfortable slides for casual wear and poolside. Easy slip-on design.',
      price: 29.99,
      brand: 'Adidas',
      category: 'Men\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1603808033192-082d6919d3e1?w=800&h=800&fit=crop',
      ],
      rating: 4.3,
      reviewCount: 445,
      currency: '\$',
      attributes: {'color': 'Black', 'size': '11', 'material': 'Synthetic', 'type': 'Slides'},
    ),

    // More Women's Shoes
    ProductModel(
      id: 'w41',
      name: 'Platform Heels',
      description: 'Statement platform heels for special occasions. Bold and fashionable.',
      price: 99.99,
      brand: 'Steve Madden',
      category: 'Women\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 234,
      currency: '\$',
      attributes: {'color': 'Black', 'size': '8', 'material': 'Synthetic', 'heel': '5 inches'},
    ),
    ProductModel(
      id: 'w42',
      name: 'Espadrille Wedges',
      description: 'Comfortable espadrille wedges with ankle ties. Perfect for summer.',
      price: 64.99,
      brand: 'Toms',
      category: 'Women\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 378,
      currency: '\$',
      attributes: {'color': 'Beige', 'size': '7', 'material': 'Canvas', 'heel': '3 inches'},
    ),
    ProductModel(
      id: 'w43',
      name: 'Knee-High Boots',
      description: 'Elegant knee-high boots with block heel. Perfect for fall and winter.',
      price: 149.99,
      brand: 'Sam Edelman',
      category: 'Women\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 289,
      currency: '\$',
      attributes: {'color': 'Black', 'size': '7.5', 'material': 'Leather', 'heel': '2 inches'},
    ),
    ProductModel(
      id: 'w44',
      name: 'Running Shoes',
      description: 'Lightweight running shoes with breathable mesh. Perfect for workouts.',
      price: 109.99,
      brand: 'Nike',
      category: 'Women\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&h=800&fit=crop',
      ],
      rating: 4.8,
      reviewCount: 623,
      currency: '\$',
      attributes: {'color': 'Pink', 'size': '8', 'material': 'Mesh', 'type': 'Athletic'},
    ),
    ProductModel(
      id: 'w45',
      name: 'Mules',
      description: 'Backless mules with low heel. Easy to wear and stylish.',
      price: 69.99,
      brand: 'Zara',
      category: 'Women\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1603808033192-082d6919d3e1?w=800&h=800&fit=crop',
      ],
      rating: 4.3,
      reviewCount: 267,
      currency: '\$',
      attributes: {'color': 'Tan', 'size': '7', 'material': 'Leather', 'heel': '1 inch'},
    ),

    // Additional Variety
    ProductModel(
      id: 'm46',
      name: 'Turtleneck Sweater',
      description: 'Classic turtleneck sweater. Warm and sophisticated.',
      price: 69.99,
      brand: 'Uniqlo',
      category: 'Men\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1576566588028-4147f3842f27?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 312,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'M', 'material': 'Merino Wool', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm47',
      name: 'Tank Top',
      description: 'Basic tank top for layering or workout. Comfortable and breathable.',
      price: 14.99,
      brand: 'H&M',
      category: 'Men\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1622445275576-721325c15110?w=800&h=800&fit=crop',
      ],
      rating: 4.2,
      reviewCount: 456,
      currency: '\$',
      attributes: {'color': 'White', 'size': 'L', 'material': 'Cotton', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm48',
      name: 'Button-Up Vest',
      description: 'Formal vest for layering over dress shirts. Classic and refined.',
      price: 59.99,
      brand: 'Calvin Klein',
      category: 'Men\'s Vests',
      imageUrls: [
        'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 178,
      currency: '\$',
      attributes: {'color': 'Grey', 'size': 'M', 'material': 'Wool Blend', 'fit': 'Tailored'},
    ),
    ProductModel(
      id: 'm49',
      name: 'Board Shorts',
      description: 'Quick-dry board shorts for surfing and beach. Functional and stylish.',
      price: 44.99,
      brand: 'Billabong',
      category: 'Men\'s Swimwear',
      imageUrls: [
        'https://images.unsplash.com/photo-1591195853828-11db59a44f6b?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 345,
      currency: '\$',
      attributes: {'color': 'Blue Pattern', 'size': 'L', 'material': 'Polyester', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm50',
      name: 'Zip-Up Hoodie',
      description: 'Full-zip hoodie with side pockets. Casual and comfortable.',
      price: 59.99,
      brand: 'Nike',
      category: 'Men\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 534,
      currency: '\$',
      attributes: {'color': 'Grey', 'size': 'L', 'material': 'Cotton Blend', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w46',
      name: 'Halter Top',
      description: 'Trendy halter top with tie neck. Perfect for summer.',
      price: 29.99,
      brand: 'Forever 21',
      category: 'Women\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1590735213920-68192a487bc2?w=800&h=800&fit=crop',
      ],
      rating: 4.3,
      reviewCount: 289,
      currency: '\$',
      attributes: {'color': 'Red', 'size': 'S', 'material': 'Cotton', 'fit': 'Fitted'},
    ),
    ProductModel(
      id: 'w47',
      name: 'Peplum Top',
      description: 'Flattering peplum top with flared hem. Feminine and stylish.',
      price: 44.99,
      brand: 'Zara',
      category: 'Women\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1564859228273-274232fdb516?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 234,
      currency: '\$',
      attributes: {'color': 'White', 'size': 'M', 'material': 'Polyester', 'fit': 'Fitted'},
    ),
    ProductModel(
      id: 'w48',
      name: 'Tunic Top',
      description: 'Loose-fit tunic top. Comfortable and versatile.',
      price: 39.99,
      brand: 'Gap',
      category: 'Women\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1618354691373-d851c5c3a990?w=800&h=800&fit=crop',
      ],
      rating: 4.2,
      reviewCount: 198,
      currency: '\$',
      attributes: {'color': 'Navy', 'size': 'L', 'material': 'Cotton', 'fit': 'Loose'},
    ),
    ProductModel(
      id: 'w49',
      name: 'Leather Leggings',
      description: 'Edgy faux leather leggings. Perfect for going out.',
      price: 54.99,
      brand: 'H&M',
      category: 'Women\'s Pants',
      imageUrls: [
        'https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 423,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'M', 'material': 'Faux Leather', 'fit': 'Skinny'},
    ),
    ProductModel(
      id: 'w50',
      name: 'Culottes',
      description: 'Wide-leg culottes with cropped length. Modern and comfortable.',
      price: 49.99,
      brand: 'Mango',
      category: 'Women\'s Pants',
      imageUrls: [
        'https://images.unsplash.com/photo-1594633313593-bab3825d0caf?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 267,
      currency: '\$',
      attributes: {'color': 'Grey', 'size': 'S', 'material': 'Polyester', 'fit': 'Wide'},
    ),

    // Final Additions to Reach 100+
    ProductModel(
      id: 'm51',
      name: 'Rugby Shirt',
      description: 'Classic rugby shirt with horizontal stripes and collar.',
      price: 49.99,
      brand: 'Tommy Hilfiger',
      category: 'Men\'s Tops',
      imageUrls: [
        'https://images.unsplash.com/photo-1586790170083-2f9ceadc732d?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 189,
      currency: '\$',
      attributes: {'color': 'Navy/Red', 'size': 'M', 'material': 'Cotton', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm52',
      name: 'Linen Pants',
      description: 'Breathable linen pants perfect for summer. Relaxed and comfortable.',
      price: 64.99,
      brand: 'Zara',
      category: 'Men\'s Pants',
      imageUrls: [
        'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=800&h=800&fit=crop',
      ],
      rating: 4.3,
      reviewCount: 212,
      currency: '\$',
      attributes: {'color': 'Beige', 'size': '34x32', 'material': 'Linen', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm53',
      name: 'Work Boots',
      description: 'Durable steel-toe work boots. Safety and comfort combined.',
      price: 119.99,
      brand: 'Carhartt',
      category: 'Men\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1608256246200-53e635b5b65f?w=800&h=800&fit=crop',
      ],
      rating: 4.7,
      reviewCount: 367,
      currency: '\$',
      attributes: {'color': 'Brown', 'size': '10', 'material': 'Leather', 'type': 'Work Boots'},
    ),
    ProductModel(
      id: 'w51',
      name: 'Romper',
      description: 'Casual romper with shorts. Fun and easy to wear.',
      price: 44.99,
      brand: 'Aerie',
      category: 'Women\'s Rompers',
      imageUrls: [
        'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 298,
      currency: '\$',
      attributes: {'color': 'Floral', 'size': 'M', 'material': 'Rayon', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w52',
      name: 'Teddy Coat',
      description: 'Cozy teddy bear coat. Warm and on-trend.',
      price: 89.99,
      brand: 'Topshop',
      category: 'Women\'s Coats',
      imageUrls: [
        'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800&h=800&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 345,
      currency: '\$',
      attributes: {'color': 'Brown', 'size': 'M', 'material': 'Polyester', 'fit': 'Oversized'},
    ),
    ProductModel(
      id: 'w53',
      name: 'Slip Dress',
      description: 'Silky slip dress with spaghetti straps. Elegant and versatile.',
      price: 59.99,
      brand: 'Mango',
      category: 'Women\'s Dresses',
      imageUrls: [
        'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 267,
      currency: '\$',
      attributes: {'color': 'Champagne', 'size': 'S', 'material': 'Satin', 'length': 'Midi'},
    ),
    ProductModel(
      id: 'm54',
      name: 'Sleeveless Puffer',
      description: 'Lightweight sleeveless puffer vest. Great for layering.',
      price: 69.99,
      brand: 'The North Face',
      category: 'Men\'s Vests',
      imageUrls: [
        'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 234,
      currency: '\$',
      attributes: {'color': 'Black', 'size': 'L', 'material': 'Nylon', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'm55',
      name: 'Dress Shoes',
      description: 'Classic cap-toe dress shoes. Polished and professional.',
      price: 139.99,
      brand: 'Cole Haan',
      category: 'Men\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1533867617858-e7b97e060509?w=800&h=800&fit=crop',
      ],
      rating: 4.8,
      reviewCount: 312,
      currency: '\$',
      attributes: {'color': 'Black', 'size': '10', 'material': 'Leather', 'type': 'Formal'},
    ),
    ProductModel(
      id: 'w54',
      name: 'Utility Jacket',
      description: 'Trendy utility jacket with multiple pockets. Functional and stylish.',
      price: 79.99,
      brand: 'Gap',
      category: 'Women\'s Jackets',
      imageUrls: [
        'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=800&fit=crop',
      ],
      rating: 4.4,
      reviewCount: 289,
      currency: '\$',
      attributes: {'color': 'Olive', 'size': 'M', 'material': 'Cotton', 'fit': 'Regular'},
    ),
    ProductModel(
      id: 'w55',
      name: 'Loafers',
      description: 'Comfortable leather loafers. Perfect for work and casual wear.',
      price: 84.99,
      brand: 'Sam Edelman',
      category: 'Women\'s Shoes',
      imageUrls: [
        'https://images.unsplash.com/photo-1603808033192-082d6919d3e1?w=800&h=800&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 378,
      currency: '\$',
      attributes: {'color': 'Tan', 'size': '7.5', 'material': 'Leather', 'type': 'Loafers'},
    ),
  ];
}