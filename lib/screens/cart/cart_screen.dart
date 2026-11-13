import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/storage_service.dart';
import '../../services/order_service.dart';
import '../../state/cart_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state.dart';
import '../orders/delivery_tracking_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final OrderService _orderService = OrderService();

  final _addressController = TextEditingController(text: 'ផ្ទះលេខ ១២A ផ្លូវ ២០០ សង្កាត់ទួលគោក, ភ្នំពេញ');
  final _phoneController = TextEditingController(text: '+855 12 888 999');
  final _noteController = TextEditingController(text: 'សូមខលមកមុនពេលមកដល់ ផ្ទះទ្វារពណ៌ប្រផេះ');
  final _promoController = TextEditingController();

  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _loadSavedDeliveryInfo();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedDeliveryInfo() async {
    final storage = await StorageService.getInstance();
    final savedAddr = storage.getDeliveryAddress();
    final savedPhone = storage.getContactPhone();
    if (savedAddr != null && savedAddr.isNotEmpty) {
      _addressController.text = savedAddr;
    }
    if (savedPhone != null && savedPhone.isNotEmpty) {
      _phoneController.text = savedPhone;
    }
  }

  Future<void> _handlePlaceOrder() async {
    final cart = CartController.instance;
    if (cart.isEmpty) return;

    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();

    if (address.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('សូមបញ្ចូលអាសយដ្ឋានដឹកជញ្ជូន និងលេខទូរស័ព្ទ'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Persist address & phone for next time
    final storage = await StorageService.getInstance();
    await storage.saveDeliveryAddress(address);
    await storage.saveContactPhone(phone);

    setState(() => _isPlacingOrder = true);

    try {
      final orderId = await _orderService.placeOrder(
        address: address,
        phone: phone,
        note: _noteController.text.trim(),
        items: cart.toOrderPayload(),
      );

      if (!mounted) return;
      setState(() => _isPlacingOrder = false);

      if (orderId != null) {
        cart.clearCart();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeliveryTrackingScreen(orderId: orderId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ការកុម្ម៉ង់មានបញ្ហា សូមសាកល្បងម្តងទៀត'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll("ApiException: ", "")}'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _applyVoucher() {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    final success = CartController.instance.applyPromo(code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'បានប្រើប្រាស់កូដ "$code" ដោយជោគជ័យ!'
              : 'កូដមិនត្រឹមត្រូវ (សាកល្បង "OMNI20" ឬ "FREESHIP")',
        ),
        backgroundColor: success ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('កន្ត្រកទំនិញ (Shopping Cart)'),
        actions: [
          ListenableBuilder(
            listenable: CartController.instance,
            builder: (context, _) {
              if (CartController.instance.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  CartController.instance.clearCart();
                },
                child: const Text('សម្អាត', style: TextStyle(color: AppColors.danger, fontSize: 13)),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: CartController.instance,
        builder: (context, _) {
          final cart = CartController.instance;

          if (cart.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'កន្ត្រកទំនិញរបស់អ្នកនៅទទេ',
              message: 'មិនទាន់មានទំនិញក្នុងកន្ត្រកនៅឡើយទេ។ សូមជ្រើសរើសមុខម្ហូប និងទំនិញដែលអ្នកពេញចិត្ត!',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cart Items Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'មុខទំនិញដែលបានជ្រើសរើស',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(
                              '${cart.totalItemCount} មុខ',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cart.items.length,
                          separatorBuilder: (_, __) => const Divider(height: 16),
                          itemBuilder: (context, idx) {
                            final entry = cart.items.entries.elementAt(idx);
                            final product = entry.key;
                            final qty = entry.value;

                            return Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    product.imageUrl,
                                    width: 54,
                                    height: 54,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 54,
                                      height: 54,
                                      color: const Color(0xFFF1F5F9),
                                      child: const Icon(Icons.fastfood, color: AppColors.textMuted, size: 24),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.formattedPrice,
                                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 16),
                                        onPressed: () => cart.removeItem(product),
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        padding: EdgeInsets.zero,
                                      ),
                                      Text(
                                        '$qty',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16),
                                        onPressed: () => cart.addItem(product),
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Delivery Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'ព័ត៌មានដឹកជញ្ជូន (Delivery Details)',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _addressController,
                          label: 'អាសយដ្ឋានដឹកជូន (Delivery Address)',
                          prefixIcon: Icons.home_outlined,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _phoneController,
                          label: 'លេខទូរស័ព្ទទំនាក់ទំនង (Contact Phone)',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _noteController,
                          label: 'ចំណាំសម្រាប់អ្នកដឹក (Delivery Note)',
                          prefixIcon: Icons.note_alt_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Voucher Coupon Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ប័ណ្ណបញ្ចុះតម្លៃ (Promo Code)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _promoController,
                                textCapitalization: TextCapitalization.characters,
                                decoration: const InputDecoration(
                                  hintText: 'ឧ. OMNI20, FREESHIP',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _applyVoucher,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: const Text('អនុវត្ត'),
                            ),
                          ],
                        ),
                        if (cart.promoCode != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'កូដ "${cart.promoCode}" ត្រូវបានអនុវត្ត!',
                                style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  cart.removePromo();
                                  _promoController.clear();
                                },
                                child: const Text('ដកចេញ', style: TextStyle(fontSize: 11, color: AppColors.danger)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Order Price Breakdown Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('តម្លៃសរុបទំនិញ (Subtotal):', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            Text('\$${cart.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('ថ្លៃសេវាដឹកជញ្ជូន (Delivery Fee):', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            Text(
                              cart.deliveryFee == 0 ? 'ឥតគិតថ្លៃ (FREE)' : '\$${cart.deliveryFee.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: cart.deliveryFee == 0 ? AppColors.success : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (cart.discount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('បញ្ចុះតម្លៃ Promo:', style: TextStyle(color: AppColors.success, fontSize: 13)),
                              Text('-\$${cart.discount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.success)),
                            ],
                          ),
                        ],
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ទឹកប្រាក់សរុប (Total Amount):',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(
                              '\$${cart.grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Checkout Button
                CustomButton(
                  text: 'បញ្ជាក់ការកុម្ម៉ង់ (Place Delivery Order) • \$${cart.grandTotal.toStringAsFixed(2)}',
                  icon: Icons.delivery_dining,
                  onPressed: _handlePlaceOrder,
                  isLoading: _isPlacingOrder,
                  height: 52,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
