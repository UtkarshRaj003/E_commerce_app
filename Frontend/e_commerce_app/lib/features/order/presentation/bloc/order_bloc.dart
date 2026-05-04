import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  OrderBloc(this._orderRepository) : super(OrderInitial()) {
    on<OrderLoadRequested>(_onOrderLoadRequested);
    on<OrderDetailLoadRequested>(_onOrderDetailLoadRequested);
    on<PaymentCreateRequested>(_onPaymentCreateRequested);
    on<PaymentVerifyRequested>(_onPaymentVerifyRequested);
    on<PlaceOrderRequested>(_placeOrder);
  }

  Future<void> _onOrderLoadRequested(
    OrderLoadRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getOrders();
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onOrderDetailLoadRequested(
    OrderDetailLoadRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final order = await _orderRepository.getOrderById(event.orderId);
      emit(OrderDetailLoaded(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onPaymentCreateRequested(
    PaymentCreateRequested event,
    Emitter<OrderState> emit,
  ) async {
    try {
      final paymentData = await _orderRepository.createPaymentOrder(
        items: event.items,
        totalAmount: event.amount,
        shippingAddress: event.shippingAddress, // ✅ ADD
      );
      emit(PaymentOrderCreated(paymentData));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onPaymentVerifyRequested(
    PaymentVerifyRequested event,
    Emitter<OrderState> emit,
  ) async {
    try {
      final success = await _orderRepository.verifyPayment(
        event.paymentId,
        event.orderId,
      );
      emit(PaymentVerified(success));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _placeOrder(
      PlaceOrderRequested event, Emitter<OrderState> emit) async {
    try {
      emit(OrderLoading());

      final order = await _orderRepository.createOrder(
        items: event.items,
        totalPrice: event.totalAmount,
        paymentMethod: event.paymentMethod,
        shippingAddress: event.shippingAddress,
        razorpayOrderId: event.razorpayOrderId,
      );

      emit(OrderPlaced(order));
      print("🔥 ORDER PLACED EMITTED");
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
