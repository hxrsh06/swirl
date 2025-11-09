import 'package:shopping_swipe_app/data/datasources/remote/product_remote_data_source.dart';
import 'package:shopping_swipe_app/data/models/product_model.dart';
import 'package:shopping_swipe_app/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProductModel>> getProducts({int limit = 20, int offset = 0}) {
    return remoteDataSource.getProducts(limit: limit, offset: offset);
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) {
    return remoteDataSource.searchProducts(query);
  }

  @override
  Future<ProductModel> getProductById(String id) {
    return remoteDataSource.getProductById(id);
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) {
    return remoteDataSource.getProductsByCategory(category);
  }

  @override
  Future<List<ProductModel>> getProductsByBrand(String brand) {
    return remoteDataSource.getProductsByBrand(brand);
  }
}