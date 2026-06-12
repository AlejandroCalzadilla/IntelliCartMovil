import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.categoryId,
    required super.name,
    required super.price,
    required super.stock,
    required super.aiScore,
    required super.imageUrl,
    required super.description,
    super.originalPrice,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String rawImageUrl = json['image_url'] ?? '';
    if (json['images'] != null && json['images'] is List && (json['images'] as List).isNotEmpty) {
      final imagesList = json['images'] as List;
      final primaryImage = imagesList.firstWhere(
        (img) => img['is_primary'] == true || img['is_primary'] == 1,
        orElse: () => imagesList.first,
      );
      rawImageUrl = primaryImage['url'] ?? '';
    }
    
    double? originalPriceVal;
    if (json['discount'] != null) {
      originalPriceVal = double.tryParse(json['discount']['original_price']?.toString() ?? '');
    } else if (json['original_price'] != null) {
      originalPriceVal = double.tryParse(json['original_price'].toString());
    }

    return ProductModel(
      id: json['id']?.toString() ?? json['uuid']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      aiScore: double.tryParse(json['ai_score']?.toString() ?? '0.0') ?? 0.0,
      imageUrl: rawImageUrl.startsWith('http') 
          ? rawImageUrl 
          : 'https://picsum.photos/300/300?random=${json["id"]}',
      description: json['description'] ?? 'Sin descripción disponible.',
      originalPrice: originalPriceVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'price': price,
      'stock': stock,
      'ai_score': aiScore,
      'image_url': imageUrl,
      'description': description,
      if (originalPrice != null) 'original_price': originalPrice,
    };
  }
}
