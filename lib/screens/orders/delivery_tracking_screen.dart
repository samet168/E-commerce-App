import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../widgets/status_badge.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  final int orderId;

  const DeliveryTrackingScreen({super.key, required this.orderId});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  final OrderService _orderService = OrderService();

  DeliveryTracking? _tracking;
  Timer? _timer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    // Real-time polling every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    final data = await _orderService.getDeliveryTracking(widget.orderId);
    if (mounted) {
      setState(() {
        _tracking = data;
        _isLoading = false;
      });
    }
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String titleKhmer,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    Color iconBg = isCompleted
        ? AppColors.success
        : isCurrent
            ? AppColors.primary
            : Colors.white;

    Color iconBorder = isCompleted
        ? AppColors.success
        : isCurrent
            ? AppColors.primary
            : const Color(0xFFCBD5E1);

    Color textColor = isCurrent
        ? AppColors.primary
        : isCompleted
            ? AppColors.textPrimary
            : AppColors.textMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
                border: Border.all(color: iconBorder, width: 2),
                boxShadow: isCurrent
                    ? const [
                        BoxShadow(
                          color: Color(0x3302569B),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : isCurrent
                        ? const Icon(Icons.pedal_bike, size: 18, color: Colors.white)
                        : Text(
                            '$stepNumber',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
              ),
            ),
            if (!isLast)
              Container(
                width: 3,
                height: 44,
                color: isCompleted ? AppColors.success : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleKhmer,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('តាមដានការដឹក #${widget.orderId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _tracking == null
              ? const Center(child: Text('រកមិនឃើញព័ត៌មាននៃការកុម្ម៉ង់នេះឡើយ'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // ETA & Status Banner Card
                      Card(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _tracking!.statusLabelKhmer,
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'ពេលវេលាដឹកជញ្ជូនប៉ាន់ស្មាន',
                                      style: TextStyle(color: Color(0xFFE0F2FE), fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_tracking!.estimatedDeliveryMinutes} នាទី',
                                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.access_time_filled, color: Colors.white, size: 36),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Delivery Timeline Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'ដំណើរការដឹកជញ្ជូន (Tracking Steps)',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  StatusBadge(status: _tracking!.status),
                                ],
                              ),
                              const Divider(height: 24),
                              _buildStepItem(
                                stepNumber: 1,
                                titleKhmer: 'បានទទួលការកុម្ម៉ង់ (Order Placed)',
                                subtitle: 'ប្រព័ន្ធបានបញ្ជូន Order ទៅកាន់សាខាហាងរួចរាល់',
                                isCompleted: _tracking!.currentStep > 1,
                                isCurrent: _tracking!.currentStep == 1,
                                isLast: false,
                              ),
                              _buildStepItem(
                                stepNumber: 2,
                                titleKhmer: 'កំពុងរៀបចំម្ហូប (Preparing Food)',
                                subtitle: 'ផ្ទះបាយកំពុងចម្អិន និងវេចខ្ចប់យ៉ាងប្រុងប្រយ័ត្ន',
                                isCompleted: _tracking!.currentStep > 2,
                                isCurrent: _tracking!.currentStep == 2,
                                isLast: false,
                              ),
                              _buildStepItem(
                                stepNumber: 3,
                                titleKhmer: 'កំពុងដឹកជញ្ជូន (Out For Delivery)',
                                subtitle: 'អ្នកដឹកជញ្ជូនកំពុងធ្វើដំណើរទៅកាន់ទីតាំងរបស់អ្នក',
                                isCompleted: _tracking!.currentStep > 3,
                                isCurrent: _tracking!.currentStep == 3,
                                isLast: false,
                              ),
                              _buildStepItem(
                                stepNumber: 4,
                                titleKhmer: 'ដឹកជញ្ជូនដល់ជោគជ័យ (Delivered)',
                                subtitle: 'ទំនិញត្រូវបានប្រគល់ជូនអតិថិជនរួចរាល់',
                                isCompleted: _tracking!.currentStep >= 4,
                                isCurrent: _tracking!.currentStep == 4,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Driver Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(0xFFE0F2FE),
                                backgroundImage: NetworkImage(_tracking!.driverAvatar),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _tracking!.driverName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _tracking!.driverPlateNumber,
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                                        const SizedBox(width: 2),
                                        const Text('4.9', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.phone, color: AppColors.success),
                                style: IconButton.styleFrom(
                                  backgroundColor: const Color(0xFFD1FAE5),
                                  padding: const EdgeInsets.all(12),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Calling driver: ${_tracking!.driverPhone}')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Delivery Destination Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.location_on, color: AppColors.danger, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'ទីតាំងទទួលទំនិញ (Destination)',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _tracking!.deliveryAddress,
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                              ),
                              if (_tracking!.deliveryNote != null && _tracking!.deliveryNote!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'ចំណាំ: ${_tracking!.deliveryNote}',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('ទូរស័ព្ទអ្នកទទួល:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  Text(_tracking!.contactPhone, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
