import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartController extends ChangeNotifier {
  static final CartController instance = CartController._internal();
  factory CartController() => instance;
  CartController._internal();

  final Map<Product, int> _items = {};
  String? _promoCode;
  double _promoDiscount = 0.0;

  Map<Product, int> get items => Map.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  String? get promoCode => _promoCode;

  int get totalItemCount => _items.values.fold(0, (sum, count) => sum + count);

  double get subtotal => _items.entries.fold(
        0.0,
        (sum, entry) => sum + (entry.key.price * entry.value),
      );

  double get deliveryFee {
    if (isEmpty) return 0.0;
    if (_promoCode == 'FREESHIP' || subtotal >= 25.0) return 0.0;
    return 1.50;
  }

  double get discount => _promoDiscount;

  double get grandTotal {
    final total = subtotal + deliveryFee - discount;
    return total > 0 ? total : 0.0;
  }

  int getQuantity(Product product) => _items[product] ?? 0;

  void addItem(Product product) {
    _items[product] = (_items[product] ?? 0) + 1;
    _recalculateDiscount();
    notifyListeners();
  }

  void removeItem(Product product) {
    if (!_items.containsKey(product)) return;
    if (_items[product]! > 1) {
      _items[product] = _items[product]! - 1;
    } else {
      _items.remove(product);
    }
    _recalculateDiscount();
    notifyListeners();
  }

  void deleteItem(Product product) {
    _items.remove(product);
    _recalculateDiscount();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _promoCode = null;
    _promoDiscount = 0.0;
    notifyListeners();
  }

  bool applyPromo(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'OMNI20') {
      _promoCode = clean;
      _promoDiscount = subtotal * 0.20;
      notifyListeners();
      return true;
    } else if (clean == 'FREESHIP') {
      _promoCode = clean;
      _promoDiscount = 0.0;
      notifyListeners();
      return true;
    } else if (clean == 'SAVE5' && subtotal >= 15.0) {
      _promoCode = clean;
      _promoDiscount = 5.0;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removePromo() {
    _promoCode = null;
    _promoDiscount = 0.0;
    notifyListeners();
  }

  void _recalculateDiscount() {
    if (_promoCode == 'OMNI20') {
      _promoDiscount = subtotal * 0.20;
    } else if (_promoCode == 'SAVE5') {
      _promoDiscount = subtotal >= 15.0 ? 5.0 : 0.0;
    } else {
      _promoDiscount = 0.0;
    }
  }

  List<Map<String, dynamic>> toOrderPayload() {
    return _items.entries.map((entry) {
      return {
        'product_id': entry.key.id,
        'quantity': entry.value,
      };
    }).toList();
  }
}
