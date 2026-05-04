import 'package:equatable/equatable.dart';
import '../../../../common/models/order_model.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Order> orders;

  const OrderLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderPlaced extends OrderState {
  final Order order;
  OrderPlaced(this.order);
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

// ✅ ORDER DETAIL STATE
class OrderDetailLoaded extends OrderState {
  final Order order;

  const OrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class PaymentOrderCreated extends OrderState {
  final Map<String, dynamic> paymentData;

  const PaymentOrderCreated(this.paymentData);

  @override
  List<Object?> get props => [paymentData];
}

class PaymentVerified extends OrderState {
  final bool success;

  const PaymentVerified(this.success);

  @override
  List<Object?> get props => [success];
}
