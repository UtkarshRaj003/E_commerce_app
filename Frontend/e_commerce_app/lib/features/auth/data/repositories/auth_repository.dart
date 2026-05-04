import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../common/models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SharedPreferences _prefs;

  AuthRepository(this._dioClient, this._prefs);

  // 🔥 Common response handler
  Map<String, dynamic> _handleResponse(Response response) {
    dynamic data = response.data;

    if (data is String) {
      data = jsonDecode(data);
    }

    if (data is! Map<String, dynamic>) {
      throw Exception("Invalid server response");
    }

    return data;
  }

  Future<void> saveRole(String role) async {
    await _prefs.setString(StorageKeys.role, role);
  }

  String? getRole() {
    return _prefs.getString(StorageKeys.role);
  }

// AuthRepository ke andar
  Future<User> _saveAuthData(Map<String, dynamic> data) async {
    final token = data['token'];
    final userMap = data['user'];

    if (token == null || userMap == null) {
      throw Exception("Invalid response from server");
    }

    await _prefs.setString(StorageKeys.token, token);

    final user = User.fromJson(userMap);
    final role = user.role ?? 'user';

    await _prefs.setString(StorageKeys.role, role);
    await _prefs.setString(StorageKeys.user, jsonEncode(user.toJson()));

    return user;
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = _handleResponse(response);
      print("Login response data: $data");
      return await _saveAuthData(data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.register,
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        },
      );

      final data = _handleResponse(response);
      return await _saveAuthData(data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<User> googleSignIn(String idToken) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.google,
        data: {'idToken': idToken},
      );

      final data = _handleResponse(response);
      return await _saveAuthData(data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'];
      }

      switch (e.response?.statusCode) {
        case 401:
          return "Invalid credentials";
        case 500:
          return "Server error";
      }
    }

    return "Something went wrong";
  }

  Future<User?> getCurrentUser() async {
    final token = _prefs.getString(StorageKeys.token);
    if (token == null || token.isEmpty) return null;

    final userData = _prefs.getString(StorageKeys.user);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }

    return null;
  }

  Future<void> logout() async {
    await _prefs.clear();
  }

  bool isLoggedIn() {
    final token = _prefs.getString(StorageKeys.token);
    return token != null && token.isNotEmpty;
  }

  String? getToken() {
    return _prefs.getString(StorageKeys.token);
  }

  Future<User> refreshUserFromServer() async {
    final response = await _dioClient.get(ApiConstants.profile);
    final user = User.fromJson(response.data);
    await _prefs.setString(StorageKeys.user, jsonEncode(user.toJson()));
    return user;
  }
}
