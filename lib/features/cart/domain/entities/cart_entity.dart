import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> items;

  const CartEntity({required this.items});

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  double get tax => subtotal * 0.15; // 15% IVA
  double get total => subtotal + tax;

  @override
  List<Object?> get props => [items];
}
