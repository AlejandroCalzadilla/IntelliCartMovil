import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

abstract class CatalogRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? categoryId,
    String? query,
  });
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, ProductEntity>> getProductById(String id);
}
