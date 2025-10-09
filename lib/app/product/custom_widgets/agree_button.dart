// ignore_for_file: file_names, must_be_immutable

import 'package:atelyam/app/modules/home_view/controllers/home_controller.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AgreeButton extends StatelessWidget {
  final Function() onTap;
  final String text;
  final Color? color;
  final Color? textColor;

  AgreeButton({required this.onTap, required this.text, this.color, this.textColor, super.key});

  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Obx(() => _buildAnimatedContainer()),
    );
  }

  Widget _buildAnimatedContainer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: homeController.agreeButton.value ? 60 : Get.size.width,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: homeController.agreeButton.value ? 0 : 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: ColorConstants.kSecondaryColor, width: 2),
        color: color ?? ColorConstants.kSecondaryColor,
        borderRadius: BorderRadii.borderRadius20,
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (homeController.agreeButton.value) {
      return const Center(
        child: SizedBox(
          width: 34,
          height: 33,
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    } else {
      return Text(
        text.tr,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: textColor ?? Colors.white, fontSize: AppFontSizes.fontSize20, fontWeight: FontWeight.bold),
      );
    }
  }
}
