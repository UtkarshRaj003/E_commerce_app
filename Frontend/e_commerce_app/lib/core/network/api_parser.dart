import 'package:dio/dio.dart';

/// Helper to parse paginated or list API responses
T parseApiResponse<T>(
  dynamic data, {
  required T Function(List<dynamic>) listParser,
  String? listKey,
}) {
  if (data is List) {
    return listParser(data);
  } else if (listKey != null && data[listKey] != null) {
    return listParser(data[listKey] as List);
  } else if (data is Map && data.values.any((v) => v is List)) {
    // Try to find the first list in the map
    final list = data.values.firstWhere((v) => v is List, orElse: () => []);
    return listParser(list as List);
  }
  return listParser([]);
}

/// Helper to extract error message from DioException
String parseDioError(dynamic error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return error.message ?? 'Unknown error';
  }
  return error.toString();
}
