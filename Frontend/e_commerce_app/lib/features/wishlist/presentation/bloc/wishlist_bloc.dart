import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/wishlist_repository.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository _wishlistRepository;

  WishlistBloc(this._wishlistRepository) : super(WishlistInitial()) {
    on<WishlistLoadRequested>(_onLoad);
    on<WishlistToggleRequested>(_onToggle);
    on<WishlistRemoveItemRequested>((event, emit) async {
      try {
        final updatedWishlist =
            await _wishlistRepository.removeFromWishlist(event.productId);

        emit(WishlistLoaded(updatedWishlist));
      } catch (e) {
        emit(WishlistError(e.toString()));
      }
    });
  }

  Future<void> _onLoad(
    WishlistLoadRequested event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());
    try {
      final wishlist = await _wishlistRepository.getWishlist();
      emit(WishlistLoaded(wishlist));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> _onToggle(
    WishlistToggleRequested event,
    Emitter<WishlistState> emit,
  ) async {
    final currentState = state;

    if (currentState is! WishlistLoaded) return;

    try {
      final isExists = currentState.wishlist.contains(event.productId);

      final updatedWishlist = isExists
          ? await _wishlistRepository.removeFromWishlist(event.productId)
          : await _wishlistRepository.addToWishlist(event.productId);

      emit(WishlistItemToggled(
        wishlist: updatedWishlist,
        isAdded: !isExists,
        productId: event.productId,
      ));

      emit(WishlistLoaded(updatedWishlist));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  bool isInWishlist(String productId) {
    if (state is WishlistLoaded) {
      return (state as WishlistLoaded).wishlist.contains(productId);
    }
    return false;
  }
}
