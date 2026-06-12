import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final GetProductsUseCase getProductsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  CatalogCubit({
    required this.getProductsUseCase,
    required this.getCategoriesUseCase,
  }) : super(CatalogInitial());

  Future<void> loadCatalog() async {
    emit(CatalogLoading());
    final categoriesResult = await getCategoriesUseCase();
    final productsResult = await getProductsUseCase(const GetProductsParams());

    categoriesResult.fold(
      (failure) => emit(CatalogError(failure.message)),
      (categories) {
        productsResult.fold(
          (failure) => emit(CatalogError(failure.message)),
          (products) {
            emit(CatalogLoaded(
              products: products,
              categories: categories,
            ));
          },
        );
      },
    );
  }

  Future<void> filterByCategory(String? categoryId) async {
    final currentState = state;
    if (currentState is CatalogLoaded) {
      emit(CatalogLoading());
      final productsResult = await getProductsUseCase(GetProductsParams(
        categoryId: categoryId,
        query: currentState.searchQuery,
      ));

      productsResult.fold(
        (failure) => emit(CatalogError(failure.message)),
        (products) {
          emit(CatalogLoaded(
            products: products,
            categories: currentState.categories,
            selectedCategoryId: categoryId,
            searchQuery: currentState.searchQuery,
          ));
        },
      );
    }
  }

  Future<void> searchProducts(String query) async {
    final currentState = state;
    if (currentState is CatalogLoaded) {
      emit(CatalogLoading());
      final productsResult = await getProductsUseCase(GetProductsParams(
        categoryId: currentState.selectedCategoryId,
        query: query,
      ));

      productsResult.fold(
        (failure) => emit(CatalogError(failure.message)),
        (products) {
          emit(CatalogLoaded(
            products: products,
            categories: currentState.categories,
            selectedCategoryId: currentState.selectedCategoryId,
            searchQuery: query,
          ));
        },
      );
    }
  }
}
