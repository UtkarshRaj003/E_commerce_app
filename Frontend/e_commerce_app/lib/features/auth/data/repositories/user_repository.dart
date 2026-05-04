import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_commerce_app/common/models/user_model.dart';
import 'package:e_commerce_app/core/constants/api_constants.dart';
import 'package:e_commerce_app/core/network/dio_client.dart';

class UserRepository {
  final DioClient dio;

  UserRepository(this.dio);

  // ✅ Get Profile
  Future<User> getProfile() async {
    final response = await dio.get(ApiConstants.profile);

    if (response.statusCode == 200) {
      return User.fromJson(response.data);
    }

    throw Exception('Failed to load profile');
  }

  // ✅ Update Profile
  Future<void> updateProfile({
    required String name,
    String? phone,
  }) async {
    await dio.put(
      ApiConstants.profile,
      data: {
        "name": name,
        "phone": phone,
      },
    );
  }

  Future<void> addAddress({
    required String addressLine,
    required String city,
    required String state,
    required String pincode,
  }) async {
    await dio.post(
      '/users/address',
      data: {
        "addressLine": addressLine,
        "city": city,
        "state": state,
        "pincode": pincode,
      },
    );
  }

  /// 🔥 UPDATE ADDRESS
  Future<void> updateAddress({
    required String id,
    required String addressLine,
    required String city,
    required String state,
    required String pincode,
  }) async {
    await dio.put(
      '${ApiConstants.address}/$id',
      data: {
        "addressLine": addressLine,
        "city": city,
        "state": state,
        "pincode": pincode,
      },
    );
  }

  /// 🔥 UPLOAD AVATAR
  Future<void> uploadAvatar(File file) async {
    FormData formData = FormData.fromMap({
      "avatar": await MultipartFile.fromFile(file.path),
    });

    await dio.put(
      ApiConstants.avatar,
      data: formData,
    );
  }
}
