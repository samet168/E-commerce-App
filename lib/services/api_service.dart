// Backward compatibility shim for legacy ApiService callers
import 'auth_service.dart';
import 'order_service.dart';
import 'product_service.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../core/constants/api_constants.dart';
import '../state/auth_controller.dart';

class ApiService {
  static String get baseUrl => ApiConstants.baseUrl;

  static String? get userToken => AuthController.instance.token;
  static Map<String, dynamic>? get currentUser => AuthController.instance.currentUser?.toJson();

  static Future<bool> loginWithGoogle(String idToken) =>
      AuthController.instance.loginWithGoogle(idToken);

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final list = await ProductService().getCategories();
    return list.map((c) => {'name': c.name, 'name_khmer': c.nameKhmer, 'icon_name': c.iconName}).toList();
  }

  static Future<List<Map<String, dynamic>>> getBranches() async {
    final list = await ProductService().getBranches();
    return list.map((b) => {'id': b.id, 'name': b.name, 'code': b.code, 'address': b.address}).toList();
  }

  static Future<List<Product>> getProducts({String? category, String? search}) =>
      ProductService().getProducts(category: category, search: search);

  static Future<int?> placeOrder({
    required String address,
    required String phone,
    String? note,
    required List<Map<String, dynamic>> items,
  }) =>
      OrderService().placeOrder(address: address, phone: phone, note: note, items: items);

  static Future<DeliveryTracking?> getDeliveryTracking(int orderId) =>
      OrderService().getDeliveryTracking(orderId);
}
