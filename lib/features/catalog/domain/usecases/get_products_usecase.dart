import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/catalog_repository.dart';

class GetProductsParams {
  final String? categoryId;
  final String? query;

  const GetProductsParams({this.categoryId, this.query});
}

class GetProductsUseCase {
  final CatalogRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call(GetProductsParams params) async {
    return await repository.getProducts(
      categoryId: params.categoryId,
      query: params.query,
    );
  }
}
