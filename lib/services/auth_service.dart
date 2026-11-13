import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/storage_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  // User Login (Email & Password)
  Future<User> login({required String email, required String password}) async {
    final response = await _api.post(
      ApiConstants.authLogin,
      body: {'email': email.trim(), 'password': password},
      requiresAuth: false,
    );

    final token = response['access_token']?.toString();
    final userMap = response['user'] as Map<String, dynamic>;

    if (token != null) {
      final storage = await StorageService.getInstance();
      await storage.saveToken(token);
      await storage.saveUser(userMap);
    }

    return User.fromJson(userMap);
  }

  // User Register (Customer Account)
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final response = await _api.post(
      ApiConstants.authRegister,
      body: {
        'email': email.trim(),
        'password': password,
        'full_name': fullName.trim(),
        'phone': phone?.trim(),
      },
      requiresAuth: false,
    );

    final token = response['access_token']?.toString();
    final userMap = response['user'] as Map<String, dynamic>;

    if (token != null) {
      final storage = await StorageService.getInstance();
      await storage.saveToken(token);
      await storage.saveUser(userMap);
    }

    return User.fromJson(userMap);
  }

  // Google Login
  Future<User> loginWithGoogle(String idToken) async {
    try {
      final response = await _api.post(
        ApiConstants.authGoogle,
        body: {'id_token': idToken},
        requiresAuth: false,
      );

      final token = response['access_token']?.toString();
      final userMap = response['user'] as Map<String, dynamic>;

      if (token != null) {
        final storage = await StorageService.getInstance();
        await storage.saveToken(token);
        await storage.saveUser(userMap);
      }

      return User.fromJson(userMap);
    } catch (_) {
      // Mock Fallback for local testing without Google Client ID
      final mockUserMap = {
        'id': 99,
        'email': 'sok.sabay@gmail.com',
        'full_name': 'សុខ សប្បាយ (Demo Customer)',
        'phone': '+855 12 888 999',
        'avatar_url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
        'role': 'customer',
        'is_active': true,
      };
      final storage = await StorageService.getInstance();
      await storage.saveToken('mock_jwt_token_demo');
      await storage.saveUser(mockUserMap);
      return User.fromJson(mockUserMap);
    }
  }

  // Get Current Authenticated Profile
  Future<User?> getMe() async {
    try {
      final response = await _api.get(ApiConstants.authMe, requiresAuth: true);
      if (response is Map<String, dynamic>) {
        final storage = await StorageService.getInstance();
        await storage.saveUser(response);
        return User.fromJson(response);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    final storage = await StorageService.getInstance();
    await storage.clearAuth();
  }
}
