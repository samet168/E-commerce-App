import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../storage/storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();

  Future<Map<String, String>> _buildHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final storage = await StorageService.getInstance();
      final token = storage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final baseUrl = ApiConstants.baseUrl;
    String fullUrl = '$baseUrl$path';
    if (queryParams != null && queryParams.isNotEmpty) {
      final query = queryParams.entries
          .where((e) => e.value != null && e.value.toString().isNotEmpty)
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      if (query.isNotEmpty) {
        fullUrl += (fullUrl.contains('?') ? '&' : '?') + query;
      }
    }
    return Uri.parse(fullUrl);
  }

  // GET Request
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams, bool requiresAuth = true}) async {
    try {
      final uri = _buildUri(path, queryParams);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);

      final response = await _client
          .get(uri, headers: headers)
          .timeout(ApiConstants.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Please check your network connection.');
    } on TimeoutException {
      throw ApiException('Connection timeout. The server took too long to respond.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected network error: $e');
    }
  }

  // POST Request
  Future<dynamic> post(String path, {dynamic body, bool requiresAuth = true}) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);

      final response = await _client
          .post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(ApiConstants.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Please check your network connection.');
    } on TimeoutException {
      throw ApiException('Connection timeout. The server took too long to respond.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected network error: $e');
    }
  }

  // PUT Request
  Future<dynamic> put(String path, {dynamic body, bool requiresAuth = true}) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);

      final response = await _client
          .put(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(ApiConstants.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Please check your network connection.');
    } on TimeoutException {
      throw ApiException('Connection timeout. The server took too long to respond.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected network error: $e');
    }
  }

  // DELETE Request
  Future<dynamic> delete(String path, {bool requiresAuth = true}) async {
    try {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);

      final response = await _client
          .delete(uri, headers: headers)
          .timeout(ApiConstants.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw ApiException('Cannot reach the server. Please check your network connection.');
    } on TimeoutException {
      throw ApiException('Connection timeout. The server took too long to respond.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected network error: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    final bodyString = utf8.decode(response.bodyBytes);
    dynamic bodyJson;
    try {
      bodyJson = jsonDecode(bodyString);
    } catch (_) {
      bodyJson = bodyString;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return bodyJson;
    }

    String errorMessage = 'Server error (${response.statusCode})';
    if (bodyJson is Map && bodyJson.containsKey('detail')) {
      errorMessage = bodyJson['detail'].toString();
    } else if (bodyJson is Map && bodyJson.containsKey('message')) {
      errorMessage = bodyJson['message'].toString();
    }

    if (response.statusCode == 401) {
      // Invalidate stored token if unauthorized
      StorageService.getInstance().then((s) => s.clearToken());
    }

    throw ApiException(errorMessage, response.statusCode);
  }
}
