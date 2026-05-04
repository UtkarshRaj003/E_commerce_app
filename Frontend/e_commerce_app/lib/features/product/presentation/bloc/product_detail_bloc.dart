import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/product_repository.dart';
import 'product_detail_event.dart';
import 'product_detail_state.dart';

class ProductDetailBloc
    extends Bloc<ProductDetailEvent, ProductDetailState> {
  final ProductRepository repo;

  ProductDetailBloc(this.repo) : super(ProductDetailInitial()) {
    on<ProductDetailLoadRequested>(_loadDetail);
  }

  Future<void> _loadDetail(
      ProductDetailLoadRequested event,
      Emitter<ProductDetailState> emit) async {
    emit(ProductDetailLoading());

    try {
      final product = await repo.getProductById(event.productId);
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductDetailError(e.toString()));
    }
  }
}