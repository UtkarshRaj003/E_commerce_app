import 'package:e_commerce_app/common/models/category_model.dart';
import 'package:e_commerce_app/common/models/product_model.dart';
import 'package:e_commerce_app/core/constants/api_constants.dart';
import 'package:e_commerce_app/core/network/dio_client.dart';

class ProductRepository {
  final DioClient _dioClient;

  ProductRepository(this._dioClient);

  Future<List<Category>> getCategories() async {
    final response = await _dioClient.get(ApiConstants.categories);

    if (response.statusCode == 200) {
      final data = response.data;

      if (data is List) {
        return data.map((e) => Category.fromJson(e)).toList();
      }

      if (data is Map && data['categories'] is List) {
        return (data['categories'] as List)
            .map((e) => Category.fromJson(e))
            .toList();
      }
    }

    return [];
  }

  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 10,
    String? categoryId,
    String? search,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.products,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (categoryId != null) 'categoryId': categoryId,
        if (search != null) 'search': search,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;

      if (data is List) {
        return data.map((e) => Product.fromJson(e)).toList();
      }

      if (data is Map && data['products'] is List) {
        return (data['products'] as List)
            .map((e) => Product.fromJson(e))
            .toList();
      }
    }

    return [];
  }

  Future<Product> getProductById(String id) async {
    final response = await _dioClient.get('${ApiConstants.products}/$id');

    if (response.statusCode == 200) {
      return Product.fromJson(response.data);
    }

    throw Exception('Failed to load product');
  }
}
