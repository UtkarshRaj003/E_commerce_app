import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/models/cart_model.dart';
import '../../data/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;

  CartBloc(this._cartRepository) : super(CartInitial()) {
    on<CartLoadRequested>(_onCartLoadRequested);
    on<CartAddItemRequested>(_onCartAddItemRequested);
    on<CartUpdateQuantityRequested>(_onCartUpdateQuantityRequested);
    on<CartRemoveItemRequested>(_onCartRemoveItemRequested);
    on<CartClearRequested>(_onCartClearRequested);
  }

  Future<void> _onCartLoadRequested(
    CartLoadRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final cart = await _cartRepository.getCart();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onCartAddItemRequested(
    CartAddItemRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final cart = await _cartRepository.addToCart(
        productId: event.productId,
        size: event.size,
        color: event.color,
        quantity: event.quantity,
      );

      emit(CartItemAdded(cart));
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onCartUpdateQuantityRequested(
    CartUpdateQuantityRequested event,
    Emitter<CartState> emit,
  ) async {
    try {
      final currentState = state;

      if (currentState is CartLoaded) {
        final cart = await _cartRepository.updateCartItem(
          event.productId,
          event.size,
          event.color,
          event.quantity,
        );

        emit(CartLoaded(cart)); // ✅ direct update, no loading
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onCartRemoveItemRequested(
    CartRemoveItemRequested event,
    Emitter<CartState> emit,
  ) async {
    try {
      if (state is CartLoaded) {
        final cart = await _cartRepository.removeFromCart(
          productId: event.productId,
          size: event.size,
          color: event.color,
        );

        emit(CartLoaded(cart)); // ✅ smooth update
      }
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onCartClearRequested(
    CartClearRequested event,
    Emitter<CartState> emit,
  ) async {
    // emit(CartLoading());
    try {
      await _cartRepository.clearCart();
      emit(const CartLoaded(Cart(items: [])));
    } catch (e) {
      emit(const CartLoaded(Cart(items: [])));
      emit(CartError(e.toString()));
    }
  }
}
