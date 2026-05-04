import 'package:e_commerce_app/features/order/data/repositories/order_repository.dart';
import 'package:e_commerce_app/features/order/presentation/bloc/order_event.dart';
import 'package:e_commerce_app/features/order/presentation/bloc/order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderDetailBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository repository;

  OrderDetailBloc(this.repository) : super(OrderInitial()) {
    on<OrderDetailLoadRequested>((event, emit) async {
      emit(OrderLoading());
      try {
        final order = await repository.getOrderById(event.orderId);
        emit(OrderDetailLoaded(order));
      } catch (e) {
        emit(OrderError(e.toString()));
      }
    });
  }
}
