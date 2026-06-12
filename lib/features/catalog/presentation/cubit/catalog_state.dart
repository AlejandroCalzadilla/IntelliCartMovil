import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogLoaded extends CatalogState {
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final String? searchQuery;

  const CatalogLoaded({
    required this.products,
    required this.categories,
    this.selectedCategoryId,
    this.searchQuery,
  });

  CatalogLoaded copyWith({
    List<ProductEntity>? products,
    List<CategoryEntity>? categories,
    String? selectedCategoryId,
    String? searchQuery,
  }) {
    return CatalogLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [products, categories, selectedCategoryId, searchQuery];
}

class CatalogError extends CatalogState {
  final String message;
  const CatalogError(this.message);

  @override
  List<Object?> get props => [message];
}
