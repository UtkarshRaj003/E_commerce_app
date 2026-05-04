import 'package:equatable/equatable.dart';
import 'product_model.dart';

class CartItem extends Equatable {
  final String productId;
  final Product product;
  final int quantity;
  final String size;
  final String color;

  const CartItem({
    required this.productId,
    required this.product,
    required this.quantity,
    required this.size,
    required this.color,
  });

  double get totalPrice => product.price * quantity; // ✅ FIX

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      // ✅ Backend: productId is OBJECT (after populate)
      productId: json['productId']?['_id'] ?? '',

      // ✅ पूरा product object
      product: Product.fromJson(json['productId'] ?? {}),

      quantity: json['quantity'] ?? 1,

      // ✅ nested variant
      size: json['selectedVariant']?['size'] ?? '',
      color: json['selectedVariant']?['color'] ?? '',
    );
  }

  @override
  List<Object?> get props => [productId, product, quantity, size, color];
}

class Cart extends Equatable {
  final List<CartItem> items;

  const Cart({required this.items});

  factory Cart.fromJson(Map<String, dynamic> json) {
    final items = json['items'] != null
        ? (json['items'] as List)
            .map((item) => CartItem.fromJson(item))
            .toList()
        : <CartItem>[];

    return Cart(items: items);
  }

  // ✅ Total UNIQUE items
  int get itemCount => items.length;

  // ✅ Total quantity (optional alag se rakh lo)
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);

  @override
  List<Object?> get props => [items];
}
