// ignore_for_file: deprecated_member_use

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

class BottomNavBar extends StatelessWidget {
  final HomeController homeController = Get.put<HomeController>(HomeController());
  BottomNavBar({super.key});
  final List<Widget> pages = [
    HomeView(),
    CategoryView(),
    DiscoveryView(),
    SettingsView(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Atelyam",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() => pages[homeController.selectedIndex.value]),
      bottomNavigationBar: Obx(() {
        return CustomBottomNavBar(
          currentIndex: homeController.selectedIndex.value,
          onTap: (index) {
            homeController.selectedIndex.value = index;
          },
        );
      }),
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
      height: 60,
      color: ColorConstants.kSecondaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = index == currentIndex;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: isSelected ? 0.0 : 1.0, end: isSelected ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              const selectedColor = ColorConstants.kThirdColor;
              const unselectedColor = ColorConstants.whiteMainColor;
              return GestureDetector(
                onTap: () => onTap(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? selectedItem[index] : items[index],
                      size: 28,
                      color: Color.lerp(unselectedColor, selectedColor, value),
                    ),
                    const SizedBox(height: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: isSelected ? 4 : 0,
                      width: 16,
                      decoration: const BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadii.borderRadius10,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
