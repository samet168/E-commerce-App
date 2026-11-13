import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // Keys
  static const String keyToken = 'omni_auth_token';
  static const String keyUser = 'omni_auth_user';
  static const String keyServerUrl = 'omni_server_url';
  static const String keySelectedBranch = 'omni_selected_branch';
  static const String keyDeliveryAddress = 'omni_delivery_address';
  static const String keyContactPhone = 'omni_contact_phone';

  // Token Management
  Future<bool> saveToken(String token) async {
    return await _prefs?.setString(keyToken, token) ?? false;
  }

  String? getToken() {
    return _prefs?.getString(keyToken);
  }

  Future<bool> clearToken() async {
    return await _prefs?.remove(keyToken) ?? false;
  }

  // User Data Management
  Future<bool> saveUser(Map<String, dynamic> userMap) async {
    return await _prefs?.setString(keyUser, jsonEncode(userMap)) ?? false;
  }

  Map<String, dynamic>? getUser() {
    final raw = _prefs?.getString(keyUser);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> clearUser() async {
    return await _prefs?.remove(keyUser) ?? false;
  }

  // Server URL
  Future<bool> saveServerUrl(String url) async {
    return await _prefs?.setString(keyServerUrl, url) ?? false;
  }

  String? getServerUrl() {
    return _prefs?.getString(keyServerUrl);
  }

  // Delivery Address & Phone
  Future<bool> saveDeliveryAddress(String address) async {
    return await _prefs?.setString(keyDeliveryAddress, address) ?? false;
  }

  String? getDeliveryAddress() {
    return _prefs?.getString(keyDeliveryAddress);
  }

  Future<bool> saveContactPhone(String phone) async {
    return await _prefs?.setString(keyContactPhone, phone) ?? false;
  }

  String? getContactPhone() {
    return _prefs?.getString(keyContactPhone);
  }

  // Branch
  Future<bool> saveSelectedBranch(String branchName) async {
    return await _prefs?.setString(keySelectedBranch, branchName) ?? false;
  }

  String? getSelectedBranch() {
    return _prefs?.getString(keySelectedBranch);
  }

  // Full Logout
  Future<void> clearAuth() async {
    await _prefs?.remove(keyToken);
    await _prefs?.remove(keyUser);
  }
}
