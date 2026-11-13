import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/order_model.dart';

class OrderService {
  final ApiClient _api = ApiClient();

  // Place a new delivery order
  Future<int?> placeOrder({
    required String address,
    required String phone,
    String? note,
    String paymentMethod = 'Cash on Delivery',
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _api.post(
        ApiConstants.orders,
        body: {
          'order_type': 'DELIVERY',
          'delivery_address': address.trim(),
          'contact_phone': phone.trim(),
          'delivery_note': note?.trim(),
          'payment_method': paymentMethod,
          'items': items,
        },
        requiresAuth: true,
      );

      if (response is Map && response.containsKey('id')) {
        return response['id'] is int ? response['id'] : int.tryParse(response['id'].toString());
      }
      return null;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to place order: $e');
    }
  }

  // Get Order History for the authenticated user
  Future<List<Order>> getMyOrders() async {
    try {
      final response = await _api.get(ApiConstants.myOrders, requiresAuth: true);
      if (response is List) {
        return response.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Get Live Delivery Tracking status
  Future<DeliveryTracking?> getDeliveryTracking(int orderId) async {
    try {
      final response = await _api.get(ApiConstants.tracking(orderId), requiresAuth: true);
      if (response is Map<String, dynamic>) {
        return DeliveryTracking.fromJson(response);
      }
      return null;
    } catch (_) {
      // Fallback tracking model for demo if offline
      return DeliveryTracking(
        orderId: orderId,
        status: 'PREPARING',
        currentStep: 2,
        statusLabelKhmer: 'កំពុងរៀបចំម្ហូប និងវេចខ្ចប់',
        deliveryAddress: 'ផ្ទះលេខ ១២A ផ្លូវ ២០០ សង្កាត់ទួលគោក, ភ្នំពេញ',
        contactPhone: '+855 12 888 999',
        driverName: 'ពិសិដ្ឋ (Piseth Delivery)',
        driverPhone: '+855 12 345 678',
        driverAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
        driverPlateNumber: '1AB-8899',
        estimatedDeliveryMinutes: 20,
        totalAmount: 18.50,
      );
    }
  }
}
