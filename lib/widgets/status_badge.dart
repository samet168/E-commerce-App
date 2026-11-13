import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? labelKhmer;

  const StatusBadge({
    super.key,
    required this.status,
    this.labelKhmer,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text = labelKhmer ?? status;

    switch (status.toUpperCase()) {
      case 'PENDING':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        text = labelKhmer ?? 'បានទទួលការកុម្ម៉ង់';
        break;
      case 'PREPARING':
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0284C7);
        text = labelKhmer ?? 'កំពុងរៀបចំ';
        break;
      case 'OUT_FOR_DELIVERY':
        bg = const Color(0xFFEDE9FE);
        fg = const Color(0xFF7C3AED);
        text = labelKhmer ?? 'កំពុងដឹកជញ្ជូន';
        break;
      case 'DELIVERED':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        text = labelKhmer ?? 'ដឹកជញ្ជូនរួចរាល់';
        break;
      case 'CANCELLED':
        bg = const Color(0xFFFFE4E6);
        fg = const Color(0xFFE11D48);
        text = labelKhmer ?? 'បានបោះបង់';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
