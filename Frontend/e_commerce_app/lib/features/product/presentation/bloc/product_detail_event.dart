import 'package:equatable/equatable.dart';

abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

class ProductDetailLoadRequested extends ProductDetailEvent {
  final String productId;

  const ProductDetailLoadRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}