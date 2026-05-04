import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

/// Callback for auth errors (401/403)
typedef AuthErrorCallback = void Function();

class DioClient {
  late final Dio _dio;
  final SharedPreferences _prefs;
  AuthErrorCallback? onAuthError;

  DioClient(this._prefs) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: AppConstants.timeout,
        receiveTimeout: AppConstants.timeout,
        headers: {
          // 'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString(StorageKeys.token);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (options.data is! FormData) {
            options.headers['Content-Type'] = 'application/json';
          }
          print('[DIO] → ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Debug log for all responses
          print('[DIO] URL: \'${response.requestOptions.uri}\''
              ' | Status: ${response.statusCode}\n[DATA]: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          final statusCode = error.response?.statusCode;
          // Handle 401/403 globally
          if (statusCode == 401) {
            _prefs.remove(StorageKeys.token);
            onAuthError?.call();
          } else if (statusCode == 403) {
            // Do NOT logout, just throw error
            // Optionally, show a message elsewhere
          }
          print('[DIO][ERROR] URL: \'${error.requestOptions.uri}\''
              ' | Status: $statusCode\n[DATA]: ${error.response?.data}');
          if (statusCode == 401) {
            final path = error.requestOptions.path;
            final isAdminProductRoute =
                path.contains('/products') || path.contains('/orders');

            if (!isAdminProductRoute) {
              _prefs.remove(StorageKeys.token);
              onAuthError?.call();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  void setAuthErrorCallback(AuthErrorCallback callback) {
    onAuthError = callback;
  }

  Dio get dio => _dio;

  /// Get current auth token
  String? get token => _prefs.getString(StorageKeys.token);

  /// Check if user is authenticated
  bool get isAuthenticated => token != null && token!.isNotEmpty;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(path,
        data: data, queryParameters: queryParameters);
  }

  Future<Response> uploadFile(
    String path, {
    required FormData formData,
  }) async {
    // Use FormData for multipart, do not send as JSON
    return await _dio.post(
      path,
      data: formData,
    );
  }
}
