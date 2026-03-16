import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const CustomerSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'search_customers'.tr,
          hintStyle: TextStyle(
            fontFamily: Fonts.gilroy,
            fontSize: 14,
            color: Colors.grey.shade400,
          ),
          prefixIcon: Padding(padding: const EdgeInsets.all(12), child: Icon(IconlyLight.search, color: Colors.grey)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
}
