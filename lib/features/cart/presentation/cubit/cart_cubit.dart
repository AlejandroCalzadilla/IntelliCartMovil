import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository cartRepository;

  CartCubit({required this.cartRepository}) : super(CartInitial());

  Future<void> loadCart() async {
    emit(CartLoading());
    final result = await cartRepository.getCart();
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> addProduct(ProductEntity product, [int quantity = 1]) async {
    final result = await cartRepository.addToCart(CartItemEntity(product: product, quantity: quantity));
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> removeProduct(String productId) async {
    final result = await cartRepository.removeFromCart(productId);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> updateProductQuantity(String productId, int quantity) async {
    final result = await cartRepository.updateQuantity(productId, quantity);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (cart) => emit(CartLoaded(cart)),
    );
  }

  Future<void> checkout(String addressId, String? couponCode) async {
    emit(CartLoading());
    final result = await cartRepository.checkout(addressId, couponCode);
    result.fold(
      (failure) => emit(CartError(failure.message)),
      (_) => emit(CartCheckoutSuccess()),
    );
  }
}
