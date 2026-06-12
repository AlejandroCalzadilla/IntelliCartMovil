import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../models/cart_item_model.dart';
import '../models/cart_model.dart';

class CartRepositoryImpl implements CartRepository {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  CartRepositoryImpl({
    required this.apiClient,
    required this.sharedPreferences,
  });

  Future<void> _saveLocalCart(CartModel cart) async {
    await sharedPreferences.setString('cached_cart', jsonEncode(cart.toJson()));
  }

  Future<CartModel> _getLocalCart() async {
    final jsonString = sharedPreferences.getString('cached_cart');
    if (jsonString != null) {
      try {
        return CartModel.fromJson(jsonDecode(jsonString));
      } catch (_) {
        return const CartModel(items: []);
      }
    }
    return const CartModel(items: []);
  }

  @override
  Future<Either<Failure, CartEntity>> getCart() async {
    try {
      final token = sharedPreferences.getString('auth_token');
      if (token != null) {
        final response = await apiClient.get('/cart');
        final data = jsonDecode(response.body);
        final cart = CartModel.fromJson(data);
        await _saveLocalCart(cart);
        return Right(cart);
      }
      
      final localCart = await _getLocalCart();
      return Right(localCart);
    } catch (_) {
      final localCart = await _getLocalCart();
      return Right(localCart);
    }
  }

  @override
  Future<Either<Failure, CartEntity>> addToCart(CartItemEntity item) async {
    try {
      final localCart = await _getLocalCart();
      final items = List<CartItemEntity>.from(localCart.items);
      
      final existingIndex = items.indexWhere((i) => i.product.id == item.product.id);
      if (existingIndex >= 0) {
        items[existingIndex] = items[existingIndex].copyWith(
          quantity: items[existingIndex].quantity + item.quantity,
        );
      } else {
        items.add(item);
      }

      final updatedCart = CartModel(
        items: items.map((i) => CartItemModel(product: i.product, quantity: i.quantity)).toList(),
      );
      await _saveLocalCart(updatedCart);

      final token = sharedPreferences.getString('auth_token');
      if (token != null) {
        await apiClient.post(
          '/cart/items',
          body: {
            'product_id': item.product.id,
            'quantity': item.quantity,
          },
        );
      }

      return Right(updatedCart);
    } catch (e) {
      return const Left(ServerFailure('Error al agregar al carrito.'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> removeFromCart(String productId) async {
    try {
      final localCart = await _getLocalCart();
      final items = List<CartItemEntity>.from(localCart.items);
      items.removeWhere((i) => i.product.id == productId);

      final updatedCart = CartModel(
        items: items.map((i) => CartItemModel(product: i.product, quantity: i.quantity)).toList(),
      );
      await _saveLocalCart(updatedCart);

      final token = sharedPreferences.getString('auth_token');
      if (token != null) {
        await apiClient.delete('/cart/items/$productId');
      }

      return Right(updatedCart);
    } catch (e) {
      return const Left(ServerFailure('Error al remover del carrito.'));
    }
  }

  @override
  Future<Either<Failure, CartEntity>> updateQuantity(String productId, int quantity) async {
    try {
      final localCart = await _getLocalCart();
      final items = List<CartItemEntity>.from(localCart.items);
      
      final index = items.indexWhere((i) => i.product.id == productId);
      if (index >= 0) {
        if (quantity <= 0) {
          items.removeAt(index);
        } else {
          items[index] = items[index].copyWith(quantity: quantity);
        }
      }

      final updatedCart = CartModel(
        items: items.map((i) => CartItemModel(product: i.product, quantity: i.quantity)).toList(),
      );
      await _saveLocalCart(updatedCart);

      final token = sharedPreferences.getString('auth_token');
      if (token != null) {
        await apiClient.post(
          '/cart/items/update',
          body: {
            'product_id': productId,
            'quantity': quantity,
          },
        );
      }

      return Right(updatedCart);
    } catch (e) {
      return const Left(ServerFailure('Error al actualizar cantidad.'));
    }
  }

  @override
  Future<Either<Failure, void>> checkout(String addressId, String? couponCode) async {
    try {
      final token = sharedPreferences.getString('auth_token');
      if (token == null) {
        return const Left(AuthFailure('Debés iniciar sesión para realizar la compra.'));
      }

      await apiClient.post(
        '/checkout',
        body: {
          'address_id': addressId,
          if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
        },
      );

      await _saveLocalCart(const CartModel(items: []));
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(ServerFailure('Error al procesar la compra.'));
    }
  }
}
