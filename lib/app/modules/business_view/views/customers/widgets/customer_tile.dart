import 'package:atelyam/app/product/initialize/firebase_analytics_service.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/client_model.dart';
import '../services/client_service.dart';
import '../pages/customer_detail_page.dart';

class CustomerTile extends StatelessWidget {
  final ClientModel client;
  final ClientService service;
  final VoidCallback onChanged;

  const CustomerTile({
    super.key,
    required this.client,
    required this.service,
    required this.onChanged,
  });

  void _showDetails(BuildContext context) {
    FirebaseAnalyticsService.instance().logBusinessCustomerTapped(
      customerName: client.name,
      orderCount: client.orderCount,
      totalSpent: client.totalSpend ?? 0,
    );

    Get.to<void>(
      () => CustomerDetailPage(
        client: client,
        service: service,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFF3B79F6), Color(0xFF5B92FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  client.initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    client.name,
                    style: TextStyle(
                      fontFamily: Fonts.gilroy,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${client.orderCount} ${'orders'.tr}  ·  ${client.phone}',
                    style: TextStyle(
                      fontFamily: Fonts.gilroy,
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if ((client.outstanding ?? 0) > 0) ...<Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: ColorConstants.redColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${client.outstanding!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: Fonts.gilroy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ColorConstants.redColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
