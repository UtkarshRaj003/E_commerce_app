class ApiConstants {
  static const String baseUrl = 'https://e-commerce-app-t0my.onrender.com/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String google = '/auth/google';

  // Product endpoints
  static const String products = '/products';
  static const String categories = '/categories';

  // Cart endpoints
  static const String cart = '/cart';
  static const String clearcart = '/cart/clear';

  // Wishlist endpoints
  static const String wishlist = '/wishlist';
  static const String wishlistToggle = '/wishlist/toggle';

  // Order endpoints
  static const String orders = '/orders';
  static const String myorders = '/orders/my-orders';
  static const String allOrders = '/orders/all';
  static const String orderById = '/orders';

  // User endpoints (admin)
  static const String users = '/users';
  static const String saveToken = '/users/save-token';
  static const String profile = '/users/profile';
  static const String avatar = '/users/avatar';
  static const String address = '/users/address';

  static const String notifications = '/notifications';

  // Payment endpoints
  static const String createOrder = '/payments/order';
  static const String verifyPayment = '/payments/verify';
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String role = 'user_role';
  static const String user = 'user_data';
  static const String isDarkMode = 'is_dark_mode';
}

class AppConstants {
  static const String appName = 'E-Commerce';
  static const int pageSize = 10;
  static const Duration timeout = Duration(seconds: 60);
}
