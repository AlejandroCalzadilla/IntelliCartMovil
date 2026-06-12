import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final double price;
  final int stock;
  final double aiScore;
  final String imageUrl;
  final String description;
  final double? originalPrice;

  const ProductEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.stock,
    required this.aiScore,
    required this.imageUrl,
    required this.description,
    this.originalPrice,
  });

  @override
  List<Object?> get props => [
        id,
        categoryId,
        name,
        price,
        stock,
        aiScore,
        imageUrl,
        description,
        originalPrice,
      ];
}
