import 'package:equatable/equatable.dart';
import 'product_model.dart';

class WishlistItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> images;

  WishlistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
      'images': images,
    };
  }

  @override
  String toString() {
    return 'WishlistItem(id:$id,title:$title,description:$description,price:$price)';
  }

  @override
  List<Object?> get props => [id, title, price];
}

class Wishlist extends Equatable {
  final List<WishlistItem> items;

  const Wishlist({required this.items});

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    final list = json['wishlist'] != null
        ? (json['wishlist'] as List)
            .map((item) => WishlistItem.fromJson(item))
            .toList()
        : <WishlistItem>[];

    return Wishlist(items: list);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  int get itemCount => items.length;

  bool contains(String productId) {
    return items.any((item) => item.id == productId);
  }

  @override
  List<Object?> get props => [items];
}












  // final Product product;

  // const WishlistItem({required this.product});

  // factory WishlistItem.fromJson(Map<String, dynamic> json) {
  //   return WishlistItem(
  //     product: Product.fromJson(json['product'] ?? {}),
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'product': product.toJson(),
  //   };
  // }


  //   @override
  // List<Object?> get props => [product];