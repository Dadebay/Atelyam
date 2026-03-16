import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/client_model.dart';
import '../pages/edit_customer_page.dart';
import '../services/client_service.dart';
import 'form_widgets.dart';

class CustomerDetailSheet extends StatelessWidget {
  final ClientModel client;
  final ClientService service;
  final VoidCallback onChanged;

  const CustomerDetailSheet({
    super.key,
    required this.client,
    required this.service,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Avatar + name + phone + actions
              Row(
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 56,
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
                          fontSize: 22,
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
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        if (client.phone.isNotEmpty)
                          Row(
                            children: <Widget>[
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedCall,
                                color: Colors.grey.shade500,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                client.phone,
                                style: TextStyle(
                                  fontFamily: Fonts.gilroy,
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Edit button
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedPencilEdit01,
                      color: const Color(0xFF3B79F6),
                      size: 22,
                    ),
                    onPressed: () async {
                      Get.back<void>();
                      final updated = await Get.to<bool>(
                        () => EditCustomerPage(
                          client: client,
                          service: service,
                        ),
                      );
                      if (updated == true) onChanged();
                    },
                  ),
                  // Delete button
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedDelete02,
                      color: ColorConstants.redColor,
                      size: 22,
                    ),
                    onPressed: () => _showDeleteDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Stats
              Row(
                children: <Widget>[
                  Expanded(
                    child: StatBox(
                      label: 'orders'.tr,
                      value: '${client.orderCount}',
                      valueColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatBox(
                      label: 'total_spent'.tr,
                      value: '${(client.totalSpend ?? 0).toStringAsFixed(0)}',
                      valueColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatBox(
                      label: 'outstanding'.tr,
                      value: '${(client.outstanding ?? 0).toStringAsFixed(0)}',
                      valueColor: (client.outstanding ?? 0) > 0 ? ColorConstants.redColor : Colors.black,
                    ),
                  ),
                ],
              ),
              // Measurements
              if (client.measurements.isNotEmpty) ...<Widget>[
                const SizedBox(height: 20),
                Text(
                  'saved_measurements'.tr,
                  style: TextStyle(
                    fontFamily: Fonts.gilroy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: client.measurements.asMap().entries.map((entry) {
                      final index = entry.key;
                      final measurement = entry.value;
                      final isLast = index == client.measurements.length - 1;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: isLast
                              ? null
                              : Border(
                                  bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                                ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                measurement.label,
                                style: TextStyle(
                                  fontFamily: Fonts.gilroy,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B79F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                measurement.value,
                                style: TextStyle(
                                  fontFamily: Fonts.gilroy,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF3B79F6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: ColorConstants.redColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: ColorConstants.redColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'delete_customer'.tr,
                style: TextStyle(
                  fontFamily: Fonts.gilroy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'confirm_delete_customer'.tr,
                style: TextStyle(
                  fontFamily: Fonts.gilroy,
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back<bool>(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'no'.tr,
                        style: TextStyle(
                          fontFamily: Fonts.gilroy,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back<bool>(result: true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: ColorConstants.redColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'yes'.tr,
                        style: TextStyle(
                          fontFamily: Fonts.gilroy,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmDelete != true) return;

    try {
      await service.deleteClient(client.id);
      Get.back<void>();
      Get.snackbar(
        'success'.tr,
        'client_deleted'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      onChanged();
    } catch (e) {
      print('❌ Delete Error: $e');
      Get.snackbar(
        'error'.tr,
        'client_error'.tr,
        backgroundColor: ColorConstants.redColor,
        colorText: Colors.white,
      );
    }
  }
}
