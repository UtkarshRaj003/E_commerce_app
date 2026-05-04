import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class ProductLoadRequested extends ProductEvent {
  final int page;
  final String? categoryId;
  final String? search;

  const ProductLoadRequested({
    this.page = 1,
    this.categoryId,
    this.search,
  });

  @override
  List<Object?> get props => [page, categoryId, search];
}

class ProductRefreshRequested extends ProductEvent {
  final String? categoryId;
  final String? search;

  const ProductRefreshRequested({this.categoryId, this.search});

  @override
  List<Object?> get props => [categoryId, search];
}

class ProductLoadMoreRequested extends ProductEvent {}

class CategoryLoadRequested extends ProductEvent {}

