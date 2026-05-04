import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../common/models/wishlist_model.dart';

class WishlistRepository {
  final DioClient _dioClient;

  WishlistRepository(this._dioClient);

  Future<Wishlist> getWishlist() async {
    final response = await _dioClient.get(ApiConstants.wishlist);

    if (response.statusCode == 200) {
      final data = response.data;
      debugPrint("🔥 FULL DATA: $data");
      return Wishlist.fromJson(data);
    }

    return const Wishlist(items: []);
  }
 
  Future<Wishlist> addToWishlist(String productId) async {
    final response = await _dioClient.post(
      ApiConstants.wishlistToggle,
      data: {'productId': productId},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Wishlist.fromJson(response.data);
    }

    throw Exception('Failed to add to wishlist');
  }

  Future<Wishlist> removeFromWishlist(String productId) async {
    final response = await _dioClient.post(
      ApiConstants.wishlistToggle,
      data: {'productId': productId},
    );

    if (response.statusCode == 200) {
      return Wishlist.fromJson(response.data);
    }

    throw Exception('Failed to remove from wishlist');
  }
}
