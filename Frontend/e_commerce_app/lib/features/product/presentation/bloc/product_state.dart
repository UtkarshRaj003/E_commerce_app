import 'package:equatable/equatable.dart';
import '../../../../common/models/category_model.dart';
import '../../../../common/models/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<Category> categories;
  final bool hasReachedMax;
  final int currentPage;
  final String? selectedCategoryId;
  final String? searchQuery;

  const ProductLoaded({
    required this.products,
    required this.categories,
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.selectedCategoryId,
    this.searchQuery,
  });

  ProductLoaded copyWith({
    List<Product>? products,
    List<Category>? categories,
    bool? hasReachedMax,
    int? currentPage,
    String? selectedCategoryId,
    String? searchQuery,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        products,
        categories,
        hasReachedMax,
        currentPage,
        selectedCategoryId,
        searchQuery,
      ];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductDetailLoading extends ProductState {}

class ProductDetailLoaded extends ProductState {
  final Product product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductDetailError extends ProductState {
  final String message;

  const ProductDetailError(this.message);

  @override
  List<Object?> get props => [message];
}