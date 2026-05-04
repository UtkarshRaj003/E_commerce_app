import 'package:dio/dio.dart';
import 'package:e_commerce_app/features/admin/data/repositories/category_repository.dart';
import 'package:e_commerce_app/features/admin/data/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/order_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminUserRepository _userRepository;
  final AdminProductRepository _productRepository;
  final AdminOrderRepository? _orderRepository;
  final DioClient _dioClient;
  final SharedPreferences _prefs;

  AdminBloc(
    this._userRepository,
    this._productRepository,
    this._dioClient,
    this._prefs, {
    AdminOrderRepository? orderRepository,
  })  : _orderRepository = orderRepository,
        super(AdminInitial()) {
    on<AdminLoginRequested>(_onAdminLoginRequested);
    on<AdminUsersLoadRequested>(_onAdminUsersLoadRequested);

    on<AdminProductsLoadRequested>(_onAdminProductsLoadRequested);
    on<AdminProductCreateRequested>(_onAdminProductCreateRequested);
    on<AdminProductUpdateRequested>(_onAdminProductUpdateRequested);
    on<AdminProductDeleteRequested>(_onAdminProductDeleteRequested);
    on<AdminOrdersLoadRequested>(_onAdminOrdersLoadRequested);
    on<AdminOrderStatusUpdateRequested>(_onAdminOrderStatusUpdateRequested);
    on<AdminDashboardStatsRequested>(_onAdminDashboardStatsRequested);
    on<AdminLogoutRequested>(_onAdminLogoutRequested);
  }

  Future<void> _onAdminLoginRequested(
    AdminLoginRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoginLoading());
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: {'email': event.email, 'password': event.password},
      );

      final data = response.data;
      if (data == null) {
        emit(const AdminError('Invalid response from server'));
        return;
      }

      final token = data['token'] ?? data['accessToken'];
      final userData = data['user'] ?? data['userData'];

      if (token == null) {
        emit(const AdminError('Login failed: No token received'));
        return;
      }

      final role = userData?['role']?.toString();
      final isAdminFlag = userData?['isAdmin'] == true;
      final isAdmin = role == 'admin' || isAdminFlag;

      if (!isAdmin) {
        emit(const AdminError('Access denied. Admin privileges required.'));
        return;
      }

      await _prefs.setString(StorageKeys.token, token.toString());

      emit(AdminAuthenticated());
    } on DioException catch (e) {
      emit(AdminError(_extractDioError(e)));
    } catch (e) {
      emit(AdminError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onAdminUsersLoadRequested(
    AdminUsersLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminUsersLoading());
    try {
      final users = await _userRepository.getAllUsers();
      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onAdminProductsLoadRequested(
    AdminProductsLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminProductsLoading());
    try {
      final products = await _productRepository.getProducts(
        page: event.page,
        search: event.search,
      );
      emit(AdminProductsLoaded(
        products: products,
        searchQuery: event.search,
      ));
    } on DioException catch (e) {
      emit(AdminError(_extractDioError(e)));
    } catch (e) {
      emit(AdminError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onAdminProductCreateRequested(
    AdminProductCreateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminProductCreating());
    try {
      final product = await _productRepository.createProduct(
        event.productData,
        event.images,
      );

      emit(AdminProductCreated(product));
      await Future.delayed(const Duration(milliseconds: 100));
      add(const AdminProductsLoadRequested());
    } on DioException catch (e) {
      emit(AdminError(_extractDioError(e)));
    } catch (e) {
      emit(AdminError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onAdminProductUpdateRequested(
    AdminProductUpdateRequested event,
    Emitter<AdminState> emit,
  ) async {
    print('🟡 UPDATE EVENT RECEIVED: ${event.productId}');
    emit(AdminProductUpdating());
    try {
      final product = await _productRepository.updateProduct(
        event.productId,
        event.productData,
        existingImageUrls: event.existingImageUrls,
        newImages: event.newImages,
      );
      // ✅ BUG 7 FIX: same pattern — emit Updated, delay, then reload
      emit(AdminProductUpdated(product));
      await Future.delayed(const Duration(milliseconds: 100));
      add(const AdminProductsLoadRequested());
    } on DioException catch (e) {
      emit(AdminError(_extractDioError(e)));
    } catch (e) {
      emit(AdminError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onAdminProductDeleteRequested(
    AdminProductDeleteRequested event,
    Emitter<AdminState> emit,
  ) async {
    print('🔴 DELETE EVENT RECEIVED: ${event.productId}');
    emit(AdminProductDeleting());
    try {
      await _productRepository.deleteProduct(event.productId);
      emit(AdminProductDeleted(event.productId));
      await Future.delayed(const Duration(milliseconds: 100));
      add(const AdminProductsLoadRequested());
    } on DioException catch (e) {
      emit(AdminError(_extractDioError(e)));
    } catch (e) {
      emit(AdminError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onAdminOrdersLoadRequested(
    AdminOrdersLoadRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminOrdersLoading());
    try {
      if (_orderRepository != null) {
        final orders = await _orderRepository!.getAllOrders(page: event.page);
        emit(AdminOrdersLoaded(orders: orders));
      } else {
        emit(const AdminError('Order repository not initialized'));
      }
    } on DioException catch (e) {
      emit(AdminError(_extractDioError(e)));
    } catch (e) {
      emit(AdminError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onAdminOrderStatusUpdateRequested(
    AdminOrderStatusUpdateRequested event,
    Emitter<AdminState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminOrdersLoaded) {
      emit(AdminOrderStatusUpdating(orders: currentState.orders));
    } else {
      emit(const AdminOrderStatusUpdating());
    }

    try {
      if (_orderRepository != null) {
        final order = await _orderRepository!.updateOrderStatus(
          event.orderId,
          event.status.name,
        );
        emit(AdminOrderStatusUpdated(order));
        add(const AdminOrdersLoadRequested());
      } else {
        emit(const AdminError('Order repository not initialized'));
      }
    } on DioException catch (e) {
      emit(AdminError(_extractDioError(e)));
    } catch (e) {
      emit(AdminError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onAdminDashboardStatsRequested(
    AdminDashboardStatsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminDashboardLoading());
    try {
      int totalProducts = 0;
      int totalOrders = 0;
      int totalUsers = 0; // <--- New Variable
      int totalCategories = 0; // <--- New Variable

      // 1. Fetch Product Count
      try {
        final productResponse = await _dioClient.get(
          ApiConstants.products,
          queryParameters: {'page': 1, 'limit': 1},
        );
        final pd = productResponse.data;
        if (pd is Map) {
          totalProducts =
              pd['total'] ?? pd['totalProducts'] ?? pd['count'] ?? 0;
        }
      } catch (_) {}

      // 2. Fetch Order Count
      if (_orderRepository != null) {
        totalOrders = await _orderRepository!.getOrderCount();
      }

      // 3. Fetch User Count (Adding this)
      try {
        final users = await _userRepository.getAllUsers();
        totalUsers = users.length;
      } catch (_) {}

      // 4. Fetch Category Count (Adding this)
      // Note: Agar aapke paas category repository yahan injected hai toh:
      try {
        final response = await _dioClient.get(ApiConstants.categories);
        if (response.data is List) {
          totalCategories = (response.data as List).length;
        }
      } catch (_) {}

      // Final Emit
      emit(AdminDashboardStats(
          totalProducts: totalProducts,
          totalOrders: totalOrders,
          totalUsers: totalUsers, // <--- Ensure your State class supports this
          totalCategories: totalCategories));
    } catch (e) {
      emit(AdminError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onAdminLogoutRequested(
    AdminLogoutRequested event,
    Emitter<AdminState> emit,
  ) async {
    await _prefs.clear();
    emit(AdminUnauthenticated());
  }

  String _extractDioError(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['error'];
      if (message != null) return message.toString();
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to server.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) return 'Unauthorized. Please login again.';
        if (statusCode == 403) return 'Access denied. Admin privileges required.';
        if (statusCode == 404) return 'Resource not found.';
        if (statusCode == 500) return 'Server error. Please try again later.';
        return 'Server error: $statusCode';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return error.message ?? 'Unknown error occurred.';
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) return _extractDioError(error);
    return error
        .toString()
        .replaceAll('Exception: ', '')
        .replaceAll('Exception', '');
  }
}
