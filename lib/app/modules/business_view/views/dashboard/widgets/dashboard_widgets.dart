import 'package:atelyam/app/modules/business_view/views/business_currency_controller.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

// Helper functions for order status
Color orderStatusColor(String status) {
  final lowerStatus = status.toLowerCase();
  if (lowerStatus.contains('progress')) return const Color(0xFFF5A623);
  if (lowerStatus.contains('ready')) return const Color(0xFF27AE60);
  if (lowerStatus.contains('completed')) return Colors.grey;
  if (lowerStatus.contains('new')) return const Color(0xFF3B79F6);
  return const Color(0xFF9B59B6);
}

String getOrderStatusTranslation(String status) {
  final lowerStatus = status.toLowerCase();
  if (lowerStatus == 'new') return 'status_new'.tr;
  if (lowerStatus == 'in progress') return 'status_in_progress'.tr;
  if (lowerStatus == 'ready') return 'status_ready'.tr;
  if (lowerStatus == 'completed') return 'status_completed'.tr;
  return status;
}

String formatDate(String isoDate) {
  try {
    final date = DateTime.parse(isoDate);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  } catch (_) {
    return isoDate;
  }
}

class StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color bgColor;
  final bool filled;

  const StatusCard({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.bgColor,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = filled ? Colors.white : Colors.black;
    final subColor = filled ? Colors.white70 : Colors.grey.shade500;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (filled ? bgColor : Colors.black).withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: filled ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: filled ? Colors.white.withOpacity(0.20) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: filled ? Colors.white : Colors.black87, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: Fonts.gilroy,
                    fontSize: 12,
                    color: subColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: Fonts.gilroy,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FinanceCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final double value;
  final AppCurrency currency;
  final Color valueColor;

  const FinanceCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.currency,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          HugeIcon(icon: icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: Fonts.gilroy,
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              currency.format(value),
              style: TextStyle(
                fontFamily: Fonts.gilroy,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashOrderCard extends StatelessWidget {
  final String customer;
  final String item;
  final String status;
  final double price;
  final double due;
  final String date;
  final AppCurrency currency;

  const DashOrderCard({
    super.key,
    required this.customer,
    required this.item,
    required this.status,
    required this.price,
    required this.due,
    required this.date,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = orderStatusColor(status);
    final statusText = getOrderStatusTranslation(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  customer,
                  style: TextStyle(
                    fontFamily: Fonts.gilroy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontFamily: Fonts.gilroy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            item,
            style: TextStyle(
              fontFamily: Fonts.gilroy,
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 13, color: Colors.black87),
                  children: [
                    TextSpan(text: '${'price'.tr}: '),
                    TextSpan(
                      text: currency.format(price),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 13, color: Colors.black87),
                  children: [
                    TextSpan(text: '${'due'.tr}: '),
                    TextSpan(
                      text: currency.format(due),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: due > 0 ? ColorConstants.redColor : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.calendar_today_rounded, size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                formatDate(date),
                style: TextStyle(
                  fontFamily: Fonts.gilroy,
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
