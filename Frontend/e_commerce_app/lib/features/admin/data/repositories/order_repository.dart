import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_parser.dart';
import '../../../../common/models/order_model.dart';

class AdminOrderRepository {
  final DioClient _dioClient;

  AdminOrderRepository(this._dioClient);

  Future<List<Order>> getAllOrders({int page = 1, int limit = 20}) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.allOrders,
        queryParameters: {'page': page, 'limit': limit},
      );
      return parseApiResponse<List<Order>>(
        response.data,
        listParser: (list) =>
            list.map((order) => Order.fromJson(order)).toList(),
        listKey: 'orders',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final response = await _dioClient.get(
          ApiConstants.orders,
          queryParameters: {'page': page, 'limit': limit},
        );
        return parseApiResponse<List<Order>>(
          response.data,
          listParser: (list) =>
              list.map((order) => Order.fromJson(order)).toList(),
          listKey: 'orders',
        );
      }
      rethrow;
    }
  }

  Future<Order> getOrderById(String id) async {
    final response = await _dioClient.get('${ApiConstants.orderById}/$id');
    return Order.fromJson(response.data);
  }

  Future<Order> updateOrderStatus(String id, String status) async {
    // ✅ BUG 5 FIX: send both field names — whichever your backend uses will work
    final response = await _dioClient.put(
      '${ApiConstants.orderById}/$id/status',
      data: {
        'status': status, // most common backend field name
        'orderStatus': status, // fallback if backend uses this
      },
    );
    return Order.fromJson(response.data);
  }

  Future<int> getOrderCount() async {
    try {
      final response = await _dioClient.get(
        ApiConstants.allOrders,
        queryParameters: {'page': 1, 'limit': 1},
      );
      final data = response.data;
      if (data is Map) {
        return data['total'] ??
            data['totalOrders'] ??
            data['count'] ??
            (data['orders'] as List?)?.length ??
            0;
      }
      if (data is List) return data.length;
    } catch (_) {
      try {
        final response = await _dioClient.get(ApiConstants.orders);
        final data = response.data;
        if (data is List) return data.length;
        if (data is Map && data['orders'] != null) {
          return (data['orders'] as List).length;
        }
      } catch (_) {}
    }
    return 0;
  }
}
