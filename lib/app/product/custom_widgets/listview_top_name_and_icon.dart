import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

class ListviewTopNameAndIcon extends StatelessWidget {
  final String text;
  final bool icon;
  final Function() onTap;

  const ListviewTopNameAndIcon({
    required this.text,
    required this.icon,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: ColorConstants.whiteMainColor,
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 12, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildText(),
            _buildIcon(),
          ],
        ),
      ),
    );
  }

  // Text widget'ı
  Widget _buildText() {
    return Text(
      text.tr,
      maxLines: 1,
      style: TextStyle(
        color: Colors.black,
        fontSize: AppFontSizes.fontSize20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Icon widget'ı
  Widget _buildIcon() {
    if (icon) {
      return Icon(
        IconlyBroken.arrow_right_circle,
        color: Colors.black,
        size: AppFontSizes.fontSize20,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
