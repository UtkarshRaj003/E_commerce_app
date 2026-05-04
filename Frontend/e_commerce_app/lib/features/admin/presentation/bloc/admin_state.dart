import 'package:e_commerce_app/common/models/category_model.dart';
import 'package:e_commerce_app/features/admin/data/repositories/user_repository.dart';
import 'package:equatable/equatable.dart';
import '../../../../common/models/product_model.dart';
import '../../../../common/models/order_model.dart';

/// Base class for all admin states
abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminInitial extends AdminState {}

/// Generic loading state (for backward compatibility)
class AdminLoading extends AdminState {}

/// ============ AUTH STATES ============

/// Login in progress
class AdminLoginLoading extends AdminState {}

/// Successfully authenticated
class AdminAuthenticated extends AdminState {}

/// Logged out
class AdminUnauthenticated extends AdminState {}

// =========== USERS STATES ============

class AdminUsersLoading extends AdminState {}

class AdminUsersLoaded extends AdminState {
  final List<UserModel> users;
  const AdminUsersLoaded(this.users);
}

/// ============ PRODUCT STATES ============

/// Products list loading
class AdminProductsLoading extends AdminState {}

/// Products loaded successfully
class AdminProductsLoaded extends AdminState {
  final List<Product> products;
  final int totalProducts;
  final String? searchQuery;

  const AdminProductsLoaded({
    required this.products,
    this.totalProducts = 0,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [products, totalProducts, searchQuery];
}

/// Product creation in progress
class AdminProductCreating extends AdminState {}

/// Product created successfully
class AdminProductCreated extends AdminState {
  final Product product;

  const AdminProductCreated(this.product);

  @override
  List<Object?> get props => [product];
}

/// Product update in progress
class AdminProductUpdating extends AdminState {}

/// Product updated successfully
class AdminProductUpdated extends AdminState {
  final Product product;

  const AdminProductUpdated(this.product);

  @override
  List<Object?> get props => [product];
}

/// Product deletion in progress
class AdminProductDeleting extends AdminState {}

/// Product deleted successfully
class AdminProductDeleted extends AdminState {
  final String productId;

  const AdminProductDeleted(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// ============ ORDER STATES ============

/// Orders loading
class AdminOrdersLoading extends AdminState {}

/// Orders loaded successfully
class AdminOrdersLoaded extends AdminState {
  final List<Order> orders;
  final int totalOrders;

  const AdminOrdersLoaded({
    required this.orders,
    this.totalOrders = 0,
  });

  @override
  List<Object?> get props => [orders, totalOrders];
}

/// Order status update in progress
class AdminOrderStatusUpdating extends AdminState {
  final List<Order> orders;

  const AdminOrderStatusUpdating({this.orders = const []});

  @override
  List<Object?> get props => [orders];
}

/// Order status updated successfully
class AdminOrderStatusUpdated extends AdminState {
  final Order order;

  const AdminOrderStatusUpdated(this.order);

  @override
  List<Object?> get props => [order];
}

/// ============ DASHBOARD STATES ============

/// Dashboard stats loading
class AdminDashboardLoading extends AdminState {}

/// Dashboard stats loaded
class AdminDashboardStats extends AdminState {
  final int totalProducts;
  final int totalOrders;
  final int totalUsers;
  final int totalCategories;

  const AdminDashboardStats({
    required this.totalProducts,
    required this.totalOrders,
    this.totalUsers = 0,
    this.totalCategories = 0,
  });

  @override
  List<Object?> get props =>
      [totalProducts, totalOrders, totalUsers, totalCategories];
}

/// ============ ERROR STATE ============

/// Error occurred
class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
