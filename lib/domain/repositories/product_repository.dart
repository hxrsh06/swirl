import 'package:shopping_swipe_app/data/models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts({int limit, int offset});
  Future<List<ProductModel>> searchProducts(String query);
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> getProductsByCategory(String category);
  Future<List<ProductModel>> getProductsByBrand(String brand);
}