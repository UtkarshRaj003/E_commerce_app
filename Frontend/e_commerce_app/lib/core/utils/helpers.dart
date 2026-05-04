import 'package:intl/intl.dart';

// Returns full image URL for backend images
String getBackendImageUrl(String path) {
  if (path.isEmpty) return '';

  if (path.startsWith('http')) return path;

  if (!path.startsWith('/')) {
    return 'https://e-commerce-app-t0my.onrender.com/uploads/$path';
  }

  // Baaki cases ke liye simple append
  return 'https://e-commerce-app-t0my.onrender.com$path';
}

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}

class PriceFormatter {
  static String format(double price) {
    return NumberFormat.currency(symbol: '₹', decimalDigits: 2).format(price);
  }
}

class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }
    if (value.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}
