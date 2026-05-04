import 'package:equatable/equatable.dart';

class ShippingAddress {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String pincode;

  const ShippingAddress({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }
}

enum OrderStatus {
  placed,
  processing,
  shipped,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderItem extends Equatable {
  final String productId;
  final String name;
  final String image;
  final int quantity;
  final double price;
  final String size;
  final String color;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
    required this.size,
    required this.color,
  });

  double get totalPrice => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final variant = json['variant'] ?? {};

    return OrderItem(
      productId: json['productId'] is Map
          ? json['productId']['_id'] ?? ''
          : json['productId'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] is String
          ? json['image']
          : (json['image'] is List && json['image'].isNotEmpty
              ? json['image'][0]
              : ''),
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      size: variant['size'] ?? '',
      color: variant['color'] ?? '',
    );
  }

  @override
  List<Object?> get props =>
      [productId, name, image, quantity, price, size, color];
}

class Order extends Equatable {
  final String id;
  final List<OrderItem> items;
  final double totalPrice;
  final String paymentMethod;
  final String paymentStatus;
  final OrderStatus status;
  final ShippingAddress shippingAddress;
  final DateTime createdAt;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;

  const Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.shippingAddress,
    required this.createdAt,
    this.razorpayOrderId,
    this.razorpayPaymentId,
  });

  bool get isPaid => paymentStatus == 'paid';

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList()
          : [],
      totalPrice: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      status: _parseStatus(json['orderStatus']),
      shippingAddress: json['shippingAddress'] is Map<String, dynamic>
          ? ShippingAddress.fromJson(json['shippingAddress'])
          : ShippingAddress(
              name: '',
              email: '',
              phone: '',
              address: json['shippingAddress']?.toString() ?? '',
              city: '',
              state: '',
              pincode: '',
            ),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      razorpayOrderId: json['razorpayOrderId'],
      razorpayPaymentId: json['razorpayPaymentId'],
    );
  }

  static OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.placed;
    }
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [id, items, totalPrice, paymentStatus, status];
}
