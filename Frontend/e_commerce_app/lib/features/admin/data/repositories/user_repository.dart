import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final List<dynamic> addresses;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.addresses,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['firstName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'] ?? json['profilePicture'],
      addresses: json['addresses'] ?? [],
      role: json['role'] ?? 'user',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class AdminUserRepository {
  final DioClient _dioClient;

  AdminUserRepository(this._dioClient);

  Future<List<UserModel>> getAllUsers({int page = 1, int limit = 20}) async {
    final response = await _dioClient.get(
      ApiConstants.users,
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return data.map((user) => UserModel.fromJson(user)).toList();
      } else if (data['users'] != null) {
        return (data['users'] as List)
            .map((user) => UserModel.fromJson(user))
            .toList();
      }
    }
    return [];
  }
}
