import 'package:atelyam/app/modules/business_view/views/business_currency_controller.dart';
import 'package:atelyam/app/product/initialize/firebase_analytics_service.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/order_item.dart';

Color orderStatusColor(String status) {
  final lowerStatus = status.toLowerCase();
  if (lowerStatus.contains('progress')) return const Color(0xFFF5A623);
  if (lowerStatus.contains('ready')) return const Color(0xFF27AE60);
  if (lowerStatus.contains('completed')) return Colors.grey;
  if (lowerStatus.contains('new')) return const Color(0xFF3B79F6);
  return const Color(0xFF9B59B6);
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

String getOrderStatusTranslation(String status) {
  final lowerStatus = status.toLowerCase();
  if (lowerStatus == 'new') return 'status_new'.tr;
  if (lowerStatus == 'in progress') return 'status_in_progress'.tr;
  if (lowerStatus == 'ready') return 'status_ready'.tr;
  if (lowerStatus == 'completed') return 'status_completed'.tr;
  return status;
}

class OrderCard extends StatelessWidget {
  final OrderItem order;
  final AppCurrency currency;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isDeleting;

  const OrderCard({
    super.key,
    required this.order,
    required this.currency,
    this.onTap,
    this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = orderStatusColor(order.status);
    return GestureDetector(
      onTap: onTap ??
          () {
            FirebaseAnalyticsService.instance().logBusinessOrderTapped(
              customerName: order.clientName,
              status: order.status,
              amount: currency.format(order.price),
            );
          },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
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
                    order.clientName,
                    style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    getOrderStatusTranslation(order.status),
                    style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 8),
                  isDeleting
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(ColorConstants.redColor),
                          ),
                        )
                      : GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: ColorConstants.redColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              HugeIcons.strokeRoundedDelete02,
                              size: 18,
                              color: ColorConstants.redColor,
                            ),
                          ),
                        ),
                ],
              ],
            ),
            const SizedBox(height: 3),
            Text(order.orderName, style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 10),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 13, color: Colors.black87),
                    children: [
                      TextSpan(text: '${'price'.tr}: '),
                      TextSpan(
                        text: currency.format(order.price),
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
                        text: currency.format(order.due),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: order.due > 0 ? ColorConstants.redColor : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Icon(Icons.calendar_today_rounded, size: 13, color: Colors.grey.shade400),
                // const SizedBox(width: 4),
                // Text(formatDate(order.created), style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 12, color: Colors.grey.shade500)),
                if (order.deadline != null) ...[
                  const SizedBox(width: 10),
                  _DeadlineBadge(deadline: order.deadline!),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeadlineBadge extends StatelessWidget {
  final DateTime deadline;
  const _DeadlineBadge({required this.deadline});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysLeft = deadline.difference(DateTime(now.year, now.month, now.day)).inDays;

    Color badgeColor;
    if (daysLeft < 0) {
      badgeColor = const Color(0xFFE53935); // overdue
    } else if (daysLeft <= 2) {
      badgeColor = const Color(0xFFF5A623); // urgent (≤2 days)
    } else if (daysLeft <= 5) {
      badgeColor = const Color(0xFFF5A623).withOpacity(0.7); // soon (≤5 days)
    } else {
      badgeColor = Colors.grey.shade400; // normal
    }

    String label;
    if (daysLeft < 0) {
      label = '${-daysLeft} ${'deadline_days_overdue'.tr}';
    } else if (daysLeft == 0) {
      label = 'deadline_today'.tr;
    } else {
      label = '$daysLeft ${'deadline_days_left'.tr}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 11, color: badgeColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 11, fontWeight: FontWeight.w600, color: badgeColor),
          ),
        ],
      ),
    );
  }
}
