import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../common/models/cart_model.dart';

class CartRepository {
  final DioClient _dioClient;

  CartRepository(this._dioClient);

  Future<Cart> getCart() async {
    try {
      final response = await _dioClient.get(ApiConstants.cart);

      if (response.statusCode == 200 && response.data != null) {
        return Cart.fromJson(response.data);
      }

      return const Cart(items: []);
    } catch (e) {
      throw Exception('Failed to load cart: $e');
    }
  }

  Future<Cart> addToCart({
    required String productId,
    required String size,
    required String color,
    required int quantity,
  }) async {
    try {
      final body = {
        'productId': productId,
        'quantity': quantity,
        'selectedVariant': {
          'size': size,
          'color': color,
        }
      };

      debugPrint("🔥 ADD TO CART BODY: $body");

      final response = await _dioClient.post(
        ApiConstants.cart,
        data: body,
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        return Cart.fromJson(response.data);
      }

      throw Exception(response.data?['message'] ?? 'Failed to add to cart');
    } catch (e) {
      debugPrint("❌ ADD TO CART ERROR: $e");
      throw Exception('Add to cart error: $e');
    }
  }

  Future<Cart> updateCartItem(
    String productId,
    String size,
    String color,
    int quantity,
  ) async {
    try {
      final response = await _dioClient.put(
        ApiConstants.cart,
        data: {
          'productId': productId,
          'quantity': quantity,
          'selectedVariant': {
            'size': size,
            'color': color,
          }
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return Cart.fromJson(response.data);
      }

      throw Exception('Failed to update cart item');
    } catch (e) {
      debugPrint("❌ UPDATE CART ERROR: $e");
      throw Exception('Update cart error: $e');
    }
  }

  Future<Cart> removeFromCart({
    required String productId,
    required String size,
    required String color,
  }) async {
    try {
      final body = {
        'productId': productId,
        'selectedVariant': {
          'size': size,
          'color': color,
        }
      };

      debugPrint("🔥 REMOVE BODY: $body");

      final response = await _dioClient.delete(
        ApiConstants.cart,
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        return Cart.fromJson(response.data);
      }

      throw Exception('Failed to remove item');
    } catch (e) {
      debugPrint("❌ REMOVE ERROR: $e");
      throw Exception('Remove item error: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _dioClient.delete(ApiConstants.clearcart);
    } catch (e) {
      debugPrint("❌ CLEAR CART ERROR: $e");
      throw Exception('Clear cart error: $e');
    }
  }
}
