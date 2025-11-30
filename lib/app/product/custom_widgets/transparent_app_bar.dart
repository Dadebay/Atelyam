// ignore_for_file: deprecated_member_use
import 'package:atelyam/app/product/custom_widgets/back_button.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TransparentAppBar({
    required this.title,
    required this.color,
    Key? key,
    this.actions,
    this.miniBackButton,
    this.removeLeading,
  }) : super(key: key);
  final String title;
  final Color color;
  final bool? miniBackButton;
  final bool? removeLeading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title.tr,
        style: TextStyle(
          color: color,
          fontSize: AppFontSizes.fontSize20 + 2,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      scrolledUnderElevation: 0.0,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      leadingWidth: 60,
      leading: removeLeading == false
          ? Padding(
              padding: EdgeInsets.only(left: 8, top: 4, bottom: 4, right: 4),
              child: BackButtonMine(
                miniButton: miniBackButton ?? false,
              ),
            )
          : SizedBox.shrink(),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
