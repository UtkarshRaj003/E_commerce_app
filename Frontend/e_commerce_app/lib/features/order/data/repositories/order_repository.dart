import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../common/models/order_model.dart';

class OrderRepository {
  final DioClient _dioClient;

  OrderRepository(this._dioClient);

  Future<List<Order>> getOrders() async {
    final response = await _dioClient.get(ApiConstants.myorders);
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return data.map((order) => Order.fromJson(order)).toList();
      } else if (data['orders'] != null) {
        return (data['orders'] as List)
            .map((order) => Order.fromJson(order))
            .toList();
      }
    }
    return [];
  }

  Future<Order> getOrderById(String id) async {
    final response = await _dioClient.get('${ApiConstants.orderById}/$id');
    if (response.statusCode == 200) {
      return Order.fromJson(response.data);
    }
    throw Exception('Failed to load order');
  }

  Future<Order> createOrder({
    required List<Map<String, dynamic>> items,
    required double totalPrice,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    String? razorpayOrderId,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.orders,
      data: {
        'items': items,
        'totalAmount': totalPrice,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        'razorpayOrderId': razorpayOrderId,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Order.fromJson(response.data);
    }
    throw Exception('Failed to create order');
  }

  Future<Map<String, dynamic>> createPaymentOrder({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required Map<String, dynamic> shippingAddress,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.createOrder,
      data: {
        'items': items,
        'totalAmount': totalAmount,
        'shippingAddress': shippingAddress,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    }
    throw Exception('Failed to create payment order');
  }

  Future<bool> verifyPayment(String paymentId, String orderId) async {
    final response = await _dioClient.post(
      ApiConstants.verifyPayment,
      data: {
        'paymentId': paymentId,
        'orderId': orderId,
      },
    );
    return response.statusCode == 200;
  }
}
