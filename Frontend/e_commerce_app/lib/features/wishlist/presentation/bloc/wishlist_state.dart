import 'package:e_commerce_app/common/models/wishlist_model.dart';
import 'package:equatable/equatable.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final Wishlist wishlist;

  const WishlistLoaded(this.wishlist);

  @override
  List<Object?> get props => [wishlist];
}

class WishlistError extends WishlistState {
  final String message;

  const WishlistError(this.message);

  @override
  List<Object?> get props => [message];
}

class WishlistItemToggled extends WishlistState {
  final Wishlist wishlist;
  final bool isAdded;
  final String productId;

  const WishlistItemToggled({
    required this.wishlist,
    required this.isAdded,
    required this.productId,
  });

  @override
  List<Object?> get props => [wishlist, isAdded, productId];
}
