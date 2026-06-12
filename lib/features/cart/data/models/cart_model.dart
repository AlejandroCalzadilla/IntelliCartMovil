import '../../domain/entities/cart_entity.dart';
import 'cart_item_model.dart';

class CartModel extends CartEntity {
  const CartModel({required super.items});

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final List list = json['items'] ?? json['cart_items'] ?? [];
    return CartModel(
      items: list.map((item) => CartItemModel.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => (item as CartItemModel).toJson()).toList(),
    };
  }
}
