// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:atelyam/app/modules/category_view/views/category_view.dart';
import 'package:atelyam/app/modules/discovery_view/views/discovery_view.dart';
import 'package:atelyam/app/modules/home_view/controllers/home_controller.dart';
import 'package:atelyam/app/modules/home_view/views/home_view.dart';
import 'package:atelyam/app/modules/settings_view/views/settings_view.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:upgrader/upgrader.dart'; // 🔥 upgrader importu

class BottomNavBar extends StatelessWidget {
  final HomeController homeController =
      Get.put<HomeController>(HomeController());

  BottomNavBar({super.key});

  final List<Widget> pages = [
    HomeView(),
    CategoryView(),
    DiscoveryView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    // 🔥 UpgradeAlert ile Scaffold’u sarmalıyoruz
    return UpgradeAlert(
      upgrader: Upgrader(languageCode: 'tr'), // dil ayarı
      dialogStyle: Platform.isAndroid
          ? UpgradeDialogStyle.material
          : UpgradeDialogStyle.cupertino,
      child: Scaffold(
        
        body: Obx(() => pages[homeController.selectedIndex.value]),
        bottomNavigationBar: Obx(() {
          return CustomBottomNavBar(
            currentIndex: homeController.selectedIndex.value,
            onTap: (index) {
              homeController.selectedIndex.value = index;
            },
          );
        }),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      IconlyLight.home,
      IconlyLight.category,
      IconlyLight.discovery,
      IconlyLight.profile,
    ];
    final selectedItem = [
      IconlyBold.home,
      IconlyBold.category,
      IconlyBold.discovery,
      IconlyBold.profile,
    ];

    return Container(
      color: ColorConstants.whiteMainColor,
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstants.whiteMainColor,
          border: Border.all(
            color: ColorConstants.kSecondaryColor,
            width: 0.5,
          ),
        ),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = index == currentIndex;
            return GestureDetector(
              onTap: () => onTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? selectedItem[index] : items[index],
                    size: 28,
                    color: isSelected
                        ? ColorConstants.kSecondaryColor
                        : Colors.grey,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: isSelected ? 4 : 0,
                    width: 16,
                    decoration: const BoxDecoration(
                      color: ColorConstants.kSecondaryColor,
                      borderRadius: BorderRadii.borderRadius10,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
