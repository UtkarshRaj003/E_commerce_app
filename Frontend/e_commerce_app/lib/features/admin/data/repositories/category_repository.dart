import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_commerce_app/common/models/category_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class AdminCategoryRepository {
  final DioClient _dioClient;

  AdminCategoryRepository(this._dioClient);

  Future<List<Category>> getCategories() async {
    final response = await _dioClient.get(ApiConstants.categories);
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => Category.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<Category> createCategory(String name, {File? imageFile}) async {
    FormData formData = FormData.fromMap({
      'name': name,
      if (imageFile != null)
        'image': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await _dioClient.post(
      ApiConstants.categories,
      data: formData,
    );

    if (response.statusCode == 201) {
      return Category.fromJson(response.data);
    }
    throw Exception('Failed to create category');
  }

  Future<Category> updateCategory(String id, String name,
      {File? imageFile}) async {
    FormData formData = FormData.fromMap({
      'name': name,
      if (imageFile != null)
        'image': await MultipartFile.fromFile(imageFile.path),
    });

    final response = await _dioClient.put(
      '${ApiConstants.categories}/$id',
      data: formData,
    );

    if (response.statusCode == 200) {
      return Category.fromJson(response.data);
    }
    throw Exception('Failed to update category');
  }

  Future<void> deleteCategory(String id) async {
    final response = await _dioClient.delete('${ApiConstants.categories}/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete category');
    }
  }
}
