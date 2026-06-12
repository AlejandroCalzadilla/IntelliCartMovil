import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remoteDataSource;

  CatalogRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? categoryId,
    String? query,
  }) async {
    try {
      final products = await remoteDataSource.getProducts(
        categoryId: categoryId,
        query: query,
      );
      return Right(products);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(ServerFailure('Ocurrió un error al obtener los productos.'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(ServerFailure('Ocurrió un error al obtener las categorías.'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final product = await remoteDataSource.getProductById(id);
      return Right(product);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(ServerFailure('Ocurrió un error al obtener el producto.'));
    }
  }
}
