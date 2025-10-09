// ignore_for_file: deprecated_member_use

import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

class SettingsButton extends StatelessWidget {
  final String name;
  final Function() onTap;
  final Widget icon;
  final bool? lang;
  const SettingsButton({
    required this.name,
    required this.onTap,
    required this.icon,
    super.key,
    this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        tileColor: ColorConstants.whiteMainColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadii.borderRadius15,
        ),
        minVerticalPadding: 23,
        title: Text(
          name.tr,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        leading: _buildLeadingIcon(),
        trailing: const Icon(
          IconlyLight.arrow_right_circle,
          color: ColorConstants.kPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    if (lang == true) {
      return _buildLanguageIcon();
    } else {
      return _buildCustomIcon();
    }
  }

  Widget _buildLanguageIcon() {
    String iconPath;
    switch (Get.locale!.languageCode) {
      case 'tm':
        iconPath = Assets.turkmenLangIcon;
        break;
      case 'ru':
        iconPath = Assets.russianLangIcon;
        break;
      case 'en':
        iconPath = Assets.englishLangIcon;
        break;
      case 'tr':
        iconPath = Assets.turkLangIcon;
        break;
      case 'ch':
        iconPath = Assets.chinaLangIcon;
        break;
      default:
        iconPath = Assets.englishLangIcon; // Varsayılan olarak İngilizce
    }

    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: ColorConstants.kThirdColor.withOpacity(0.2),
        border: Border.all(
          color: ColorConstants.kSecondaryColor.withOpacity(0.4),
          width: 1,
        ),
        borderRadius: BorderRadii.borderRadius18,
      ),
      width: 45,
      height: 45,
      child: ClipRRect(
        borderRadius: BorderRadii.borderRadius18,
        child: SvgPicture.asset(
          iconPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Diğer ikonları oluşturur.
  Widget _buildCustomIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConstants.kThirdColor.withOpacity(0.2),
        border: Border.all(
          color: ColorConstants.kSecondaryColor.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadii.borderRadius18,
      ),
      child: icon,
    );
  }
}
