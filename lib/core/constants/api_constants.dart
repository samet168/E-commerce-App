import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  // Default API host depending on execution environment:
  // - Android Emulator uses 10.0.2.2 to reach host machine
  // - Windows, macOS, Linux, iOS simulator, Web use 127.0.0.1
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  // Active Base URL (Can be changed in developer settings at runtime)
  static String _activeBaseUrl = defaultBaseUrl;

  static String get baseUrl => _activeBaseUrl;

  static void setCustomBaseUrl(String url) {
    if (url.endsWith('/')) {
      _activeBaseUrl = url.substring(0, url.length - 1);
    } else {
      _activeBaseUrl = url;
    }
    if (!_activeBaseUrl.endsWith('/api/v1')) {
      _activeBaseUrl = '$_activeBaseUrl/api/v1';
    }
  }

  static void setFullBaseUrl(String fullUrl) {
    _activeBaseUrl = fullUrl.endsWith('/') ? fullUrl.substring(0, fullUrl.length - 1) : fullUrl;
  }

  // Auth endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authAdminLogin = '/auth/admin-login';
  static const String authGoogle = '/auth/google';
  static const String authMe = '/auth/me';
  static const String authProfile = '/auth/profile';

  // Catalog endpoints
  static const String categories = '/categories';
  static const String branches = '/branches';
  static const String products = '/products';

  // Order endpoints
  static const String orders = '/orders';
  static const String myOrders = '/orders/my-orders';
  static String tracking(int orderId) => '/orders/$orderId/tracking';

  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
