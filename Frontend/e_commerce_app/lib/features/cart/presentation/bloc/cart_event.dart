import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartLoadRequested extends CartEvent {}

class CartAddItemRequested extends CartEvent {
  final String productId;
  final String size;
  final String color;
  final int quantity;

  const CartAddItemRequested({
    required this.productId,
    required this.size,
    required this.color,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, size, color, quantity];
}

class CartUpdateQuantityRequested extends CartEvent {
  final String productId;
  final String size;
  final String color;
  final int quantity;

  const CartUpdateQuantityRequested({
    required this.productId,
    required this.size,
    required this.color,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, size, color, quantity];
}

class CartRemoveItemRequested extends CartEvent {
  final String productId;
  final String size;
  final String color;

  const CartRemoveItemRequested({
    required this.productId,
    required this.size,
    required this.color,
  });

  @override
  List<Object?> get props => [productId, size, color];
}
class CartClearRequested extends CartEvent {}