import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repo;

  ProductBloc(this._repo) : super(ProductInitial()) {
    on<ProductLoadRequested>(_load);
    on<ProductRefreshRequested>(_refresh);
    on<ProductLoadMoreRequested>(_loadMore);
  }

  Future<void> _load(
      ProductLoadRequested event, Emitter<ProductState> emit) async {
    emit(ProductLoading());

    try {
      final products = await _repo.getProducts(
        page: event.page,
        categoryId: event.categoryId,
        search: event.search,
      );

      final categories = await _repo.getCategories();

      emit(ProductLoaded(
        products: products,
        categories: categories,
        currentPage: event.page,
        selectedCategoryId: event.categoryId,
        searchQuery: event.search,
        hasReachedMax: products.length < 10,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _refresh(
      ProductRefreshRequested event, Emitter<ProductState> emit) async {
    add(ProductLoadRequested(
      page: 1,
      categoryId: event.categoryId,
      search: event.search,
    ));
  }

  Future<void> _loadMore(
      ProductLoadMoreRequested event, Emitter<ProductState> emit) async {
    if (state is! ProductLoaded) return;

    final current = state as ProductLoaded;
    if (current.hasReachedMax) return;

    try {
      final nextPage = current.currentPage + 1;

      final newProducts = await _repo.getProducts(
        page: nextPage,
        categoryId: current.selectedCategoryId,
        search: current.searchQuery,
      );

      emit(current.copyWith(
        products: [...current.products, ...newProducts],
        currentPage: nextPage,
        hasReachedMax: newProducts.length < 10,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
