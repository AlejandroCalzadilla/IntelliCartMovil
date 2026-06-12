import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_entity.dart';
import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, CartEntity>> getCart();
  Future<Either<Failure, CartEntity>> addToCart(CartItemEntity item);
  Future<Either<Failure, CartEntity>> removeFromCart(String productId);
  Future<Either<Failure, CartEntity>> updateQuantity(String productId, int quantity);
  Future<Either<Failure, void>> checkout(String addressId, String? couponCode);
}
