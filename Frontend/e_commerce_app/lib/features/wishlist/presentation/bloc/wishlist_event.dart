import 'package:equatable/equatable.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class WishlistLoadRequested extends WishlistEvent {}

class WishlistAddItemRequested extends WishlistEvent {
  final String productId;

  const WishlistAddItemRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

class WishlistRemoveItemRequested extends WishlistEvent {
  final String productId;

  const WishlistRemoveItemRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

class WishlistToggleRequested extends WishlistEvent {
  final String productId;

  const WishlistToggleRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}