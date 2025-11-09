import 'package:shopping_swipe_app/data/models/product_model.dart';
import 'package:shopping_swipe_app/domain/repositories/product_repository.dart';

class GetProductsUsecase {
  final ProductRepository repository;

  GetProductsUsecase({required this.repository});

  Future<List<ProductModel>> call({int limit = 20, int offset = 0}) {
    return repository.getProducts(limit: limit, offset: offset);
  }
}