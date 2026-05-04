import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrderLoadRequested extends OrderEvent {}

// ✅ ORDER DETAIL EVENT
class OrderDetailLoadRequested extends OrderEvent {
  final String orderId;

  const OrderDetailLoadRequested(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class PaymentCreateRequested extends OrderEvent {
  final double amount;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic> shippingAddress; // ✅ ADD

  const PaymentCreateRequested({
    required this.amount,
    required this.items,
    required this.shippingAddress, // ✅ ADD
  });

  @override
  List<Object?> get props => [amount, items, shippingAddress];
}

class PaymentVerifyRequested extends OrderEvent {
  final String paymentId;
  final String orderId;

  const PaymentVerifyRequested({
    required this.paymentId,
    required this.orderId,
  });

  @override
  List<Object?> get props => [paymentId, orderId];
}

class PlaceOrderRequested extends OrderEvent {
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String paymentMethod;
  final Map<String, dynamic> shippingAddress;
  final String? razorpayOrderId; // ✅ ADD

  const PlaceOrderRequested({
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.shippingAddress,
    this.razorpayOrderId, // ✅ ADD
  });
}