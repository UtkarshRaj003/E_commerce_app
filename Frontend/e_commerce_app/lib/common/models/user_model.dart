class Address {
  final String id;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  Address({
    required this.id,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'] ?? '',
      addressLine: json['addressLine'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  // Fix 1: Added missing toJson() so User.toJson() doesn't crash at runtime
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final List<Address> addresses;
  final String? avatar;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.addresses,
    this.avatar,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['firstName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'] ?? json['profilePicture'],
      addresses: json['addresses'] != null
          ? (json['addresses'] as List).map((i) => Address.fromJson(i)).toList()
          : [],
      role: json['role'] ?? 'user',
      createdAt: (json['createdAt'] != null &&
              json['createdAt'].toString().isNotEmpty)
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'addresses': addresses.map((e) => e.toJson()).toList(),
      'avatar': avatar,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
