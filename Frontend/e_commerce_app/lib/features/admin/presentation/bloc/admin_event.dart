import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../../common/models/order_model.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

/// Admin login event with credentials
class AdminLoginRequested extends AdminEvent {
  final String email;
  final String password;

  const AdminLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AdminUsersLoadRequested extends AdminEvent {}



/// Load products with optional search and pagination
class AdminProductsLoadRequested extends AdminEvent {
  final String? search;
  final int page;

  const AdminProductsLoadRequested({this.search, this.page = 1});

  @override
  List<Object?> get props => [search, page];
}

/// Create product with image files
/// [productData] - product fields (name, description, price, category, variants)
/// [images] - list of image files to upload
class AdminProductCreateRequested extends AdminEvent {
  final Map<String, dynamic> productData;
  final List<File> images;

  const AdminProductCreateRequested(
    this.productData, {
    this.images = const [],
  });

  @override
  List<Object?> get props => [productData, images];
}

/// Update product with optional new images
/// [productId] - ID of product to update
/// [productData] - updated product fields
/// [existingImageUrls] - URLs of images to keep
/// [newImages] - new image files to upload
class AdminProductUpdateRequested extends AdminEvent {
  final String productId;
  final Map<String, dynamic> productData;
  final List<String>? existingImageUrls;
  final List<File>? newImages;

  const AdminProductUpdateRequested({
    required this.productId,
    required this.productData,
    this.existingImageUrls,
    this.newImages,
  });

  @override
  List<Object?> get props =>
      [productId, productData, existingImageUrls, newImages];
}

class AdminProductDeleteRequested extends AdminEvent {
  final String productId;

  const AdminProductDeleteRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

class AdminOrdersLoadRequested extends AdminEvent {
  final int page;

  const AdminOrdersLoadRequested({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class AdminOrderStatusUpdateRequested extends AdminEvent {
  final String orderId;
  final OrderStatus status;

  const AdminOrderStatusUpdateRequested({
    required this.orderId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, status];
}

class AdminDashboardStatsRequested extends AdminEvent {}

class AdminLogoutRequested extends AdminEvent {}
