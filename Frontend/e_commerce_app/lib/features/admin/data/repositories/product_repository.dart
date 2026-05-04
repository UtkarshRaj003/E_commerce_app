import 'dart:convert'; // ✅ JSON Encode ke liye zaroori hai
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_parser.dart';
import '../../../../common/models/product_model.dart';

class AdminProductRepository {
  final DioClient _dioClient;

  AdminProductRepository(this._dioClient);

  /// Get products with pagination and search support
  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    final response = await _dioClient.get(
      ApiConstants.products,
      queryParameters: params,
    );

    return parseApiResponse<List<Product>>(
      response.data,
      listParser: (list) => list.map((prod) => Product.fromJson(prod)).toList(),
      listKey: 'products',
    );
  }

  /// Get single product by ID
  Future<Product> getProductById(String id) async {
    final response = await _dioClient.get('${ApiConstants.products}/$id');
    return Product.fromJson(response.data);
  }

  /// Create product with image upload
  Future<Product> createProduct(
    Map<String, dynamic> productData,
    List<File> images,
  ) async {
    final formData = FormData();

    // ✅ Fix: Complex types ko properly JSON stringify karna zaroori hai
    productData.forEach((key, value) {
      if (key == 'images') return;

      if (value is List || value is Map) {
        formData.fields.add(MapEntry(
            key, jsonEncode(value))); // .toString() ki jagah jsonEncode
      } else {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    // Add images as multipart files
    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      final extension = image.path.split('.').last.toLowerCase();

      formData.files.add(MapEntry(
        'images', // Backend should expect an array of files named 'images'
        await MultipartFile.fromFile(
          image.path,
          filename:
              'product_${DateTime.now().millisecondsSinceEpoch}_$i.$extension',
          contentType: _getMediaType(extension),
        ),
      ));
    }

    final response = await _dioClient.post(
      // ✅ Uploading using standard POST
      ApiConstants.products,
      data: formData,
    );

    return Product.fromJson(response.data);
  }

  /// Update product
  Future<Product> updateProduct(
    String id,
    Map<String, dynamic> productData, {
    List<String>? existingImageUrls,
    List<File>? newImages,
  }) async {
    final formData = FormData();

    // ✅ Fix: JSON stringify complex data
    productData.forEach((key, value) {
      if (key == 'images') return;

      if (value is List || value is Map) {
        formData.fields.add(MapEntry(key, jsonEncode(value)));
      } else {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    // ✅ Fix: Send existing images as a proper JSON array string
    if (existingImageUrls != null && existingImageUrls.isNotEmpty) {
      formData.fields.add(MapEntry(
        'existingImages',
        jsonEncode(existingImageUrls),
      ));
    }

    if (newImages != null) {
      for (int i = 0; i < newImages.length; i++) {
        final image = newImages[i];
        final extension = image.path.split('.').last.toLowerCase();

        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(
            image.path,
            filename:
                'product_update_${DateTime.now().millisecondsSinceEpoch}_$i.$extension',
            contentType: _getMediaType(extension),
          ),
        ));
      }
    }

    // ✅ Fix: Updates should use PUT request generally
    final response = await _dioClient.put(
      '${ApiConstants.products}/$id',
      data: formData,
    );

    return Product.fromJson(response.data);
  }

  /// Delete product by ID
  Future<void> deleteProduct(String id) async {
    final response = await _dioClient.delete('${ApiConstants.products}/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product');
    }
  }

  MediaType _getMediaType(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'jpg':
        return MediaType('image', 'jpg');
      case 'jpeg':
      return MediaType('image', 'jpeg');
      default:
        return MediaType('image', 'jpeg');
    }
  }
}
