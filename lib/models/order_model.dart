class OrderItem {
  final int? id;
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  OrderItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] is int ? json['id'] : null,
      productId: json['product_id'] is int ? json['product_id'] : int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      productName: json['product_name']?.toString() ?? 'Item',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Order {
  final int id;
  final String orderNumber;
  final String orderType;
  final String status;
  final String deliveryAddress;
  final String? deliveryNote;
  final String contactPhone;
  final double totalAmount;
  final String paymentMethod;
  final DateTime? createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.status,
    required this.deliveryAddress,
    this.deliveryNote,
    required this.contactPhone,
    required this.totalAmount,
    this.paymentMethod = 'Cash on Delivery',
    this.createdAt,
    this.items = const [],
  });

  String get statusKhmer {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'បានទទួលការកុម្ម៉ង់';
      case 'PREPARING':
        return 'កំពុងរៀបចំម្ហូប';
      case 'OUT_FOR_DELIVERY':
        return 'កំពុងដឹកជញ្ជូន';
      case 'DELIVERED':
        return 'បានដឹកជញ្ជូនរួចរាល់';
      case 'CANCELLED':
        return 'បានបោះបង់';
      default:
        return status;
    }
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    return Order(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      orderNumber: json['order_number']?.toString() ?? '#ORD-${json['id']}',
      orderType: json['order_type']?.toString() ?? 'DELIVERY',
      status: json['status']?.toString() ?? 'PENDING',
      deliveryAddress: json['delivery_address']?.toString() ?? '',
      deliveryNote: json['delivery_note']?.toString(),
      contactPhone: json['contact_phone']?.toString() ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method']?.toString() ?? 'Cash on Delivery',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      items: rawItems.map((item) => OrderItem.fromJson(item)).toList(),
    );
  }
}

class DeliveryTracking {
  final int orderId;
  final String status;
  final int currentStep; // 1 = Placed, 2 = Preparing, 3 = On The Way, 4 = Delivered
  final String statusLabelKhmer;
  final String deliveryAddress;
  final String? deliveryNote;
  final String contactPhone;
  final String driverName;
  final String driverPhone;
  final String driverAvatar;
  final String driverPlateNumber;
  final int estimatedDeliveryMinutes;
  final double totalAmount;

  DeliveryTracking({
    required this.orderId,
    required this.status,
    required this.currentStep,
    required this.statusLabelKhmer,
    required this.deliveryAddress,
    this.deliveryNote,
    required this.contactPhone,
    required this.driverName,
    required this.driverPhone,
    required this.driverAvatar,
    required this.driverPlateNumber,
    required this.estimatedDeliveryMinutes,
    required this.totalAmount,
  });

  factory DeliveryTracking.fromJson(Map<String, dynamic> json) {
    return DeliveryTracking(
      orderId: json['order_id'] is int ? json['order_id'] : int.tryParse(json['order_id']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
      currentStep: json['current_step'] is int ? json['current_step'] : 1,
      statusLabelKhmer: json['status_label_khmer']?.toString() ?? 'បានទទួលការកុម្ម៉ង់',
      deliveryAddress: json['delivery_address']?.toString() ?? '',
      deliveryNote: json['delivery_note']?.toString(),
      contactPhone: json['contact_phone']?.toString() ?? '',
      driverName: json['driver_name']?.toString() ?? 'ពិសិដ្ឋ - Piseth Express',
      driverPhone: json['driver_phone']?.toString() ?? '+855 12 345 678',
      driverAvatar: json['driver_avatar']?.toString() ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
      driverPlateNumber: json['driver_plate_number']?.toString() ?? '1AB-8899',
      estimatedDeliveryMinutes: json['estimated_delivery_minutes'] is int ? json['estimated_delivery_minutes'] : 25,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
