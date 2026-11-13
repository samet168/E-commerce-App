import 'package:flutter/foundation.dart';
import '../core/storage/storage_service.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  static final AuthController instance = AuthController._internal();
  factory AuthController() => instance;
  AuthController._internal();

  final AuthService _authService = AuthService();

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty && _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  // Initialize Auth state from stored preferences
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final storage = await StorageService.getInstance();
      _token = storage.getToken();
      final userMap = storage.getUser();

      if (_token != null && userMap != null) {
        _currentUser = User.fromJson(userMap);

        // Background profile validation
        _authService.getMe().then((updatedUser) {
          if (updatedUser != null) {
            _currentUser = updatedUser;
            notifyListeners();
          }
        }).catchError((_) {});
      }
    } catch (_) {
      _token = null;
      _currentUser = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Sign In
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(email: email, password: password);
      final storage = await StorageService.getInstance();
      _token = storage.getToken();
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register Customer Account
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      final storage = await StorageService.getInstance();
      _token = storage.getToken();
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Google Sign-In
  Future<bool> loginWithGoogle(String idToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.loginWithGoogle(idToken);
      final storage = await StorageService.getInstance();
      _token = storage.getToken();
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('ApiException: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Quick Demo Login for instant testing
  Future<bool> loginAsDemo() async {
    return await loginWithGoogle('mock_id_token_demo');
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
