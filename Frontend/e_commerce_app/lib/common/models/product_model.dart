import 'package:equatable/equatable.dart';

class ProductVariant extends Equatable {
  final String size;
  final String color;
  final int stock;

  const ProductVariant({
    required this.size,
    required this.color,
    required this.stock,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'color': color,
      'stock': stock,
    };
  }

  @override
  List<Object?> get props => [size, color, stock];
}

class Product extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final String categoryId;
  final String categoryName;
  final List<ProductVariant> variants;
  final double rating;
  final int numReviews;
  final DateTime createdAt;


  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.categoryId,
    required this.categoryName,
    required this.variants,
    required this.rating,
    required this.numReviews,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final category = json['categoryId'];

    return Product(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      categoryId: category is Map ? category['_id'] ?? '' : '',
      categoryName: category is Map ? category['name'] ?? '' : '',
      variants: json['variants'] != null
          ? (json['variants'] as List)
              .map((v) => ProductVariant.fromJson(v))
              .toList()
          : [],
      rating: (json['rating'] ?? 0).toDouble(),
      numReviews: json['numReviews'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
      'images': images,
      'categoryId': {
        '_id': categoryId,
        'name': categoryName,
      },
      'variants': variants.map((v) => v.toJson()).toList(),
      'rating': rating,
      'numReviews': numReviews,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 🔥 IMPORTANT: Cart ke liye
  double get effectivePrice => price;

  @override
  List<Object?> get props => [id, title, price, images];
}
