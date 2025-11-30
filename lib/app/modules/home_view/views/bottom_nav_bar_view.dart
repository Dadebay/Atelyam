// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:atelyam/app/data/service/banner_service.dart';
import 'package:atelyam/app/modules/category_view/views/category_view.dart';
import 'package:atelyam/app/modules/discovery_view/controllers/discovery_controller.dart';
import 'package:atelyam/app/modules/discovery_view/views/discovery_view.dart';
import 'package:atelyam/app/modules/home_view/controllers/home_controller.dart';
import 'package:atelyam/app/modules/home_view/views/home_view.dart';
import 'package:atelyam/app/modules/settings_view/views/favorites_view.dart';
import 'package:atelyam/app/modules/settings_view/views/settings_view.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/utils/upgrade_messages_tm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconly/iconly.dart';
import 'package:upgrader/upgrader.dart';

class BottomNavBar extends StatefulWidget {
  BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final HomeController homeController = Get.put<HomeController>(HomeController());
  List phoneNumbers = [];
  dynamic getPhoneNumber() async {
    phoneNumbers = await BannerService().fetchPhoneNumbers();
    setState(() {});
  }

  final List<Widget> pages = [HomeView(), DiscoveryView(), CategoryView(), FavoritesView(), SettingsView()];

  final List<String> pageTitles = ['home'.tr, 'discovery'.tr, 'categories'.tr, 'favorites'.tr, 'settings'.tr];

  @override
  void initState() {
    super.initState();
    getPhoneNumber();
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    print(phoneNumber);
    final Uri launchUri = Uri.parse('tel:$phoneNumber');

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      showSnackBar('error', 'phone_call_error'.tr, ColorConstants.redColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        languageCode: Get.locale!.languageCode,
        messages: Get.locale!.languageCode == 'tm' ? UpgraderMessagesTm() : UpgraderMessages(),
      ),
      dialogStyle: Platform.isAndroid ? UpgradeDialogStyle.material : UpgradeDialogStyle.cupertino,
      child: Obx(() {
        return Scaffold(
          appBar: AppBar(
            title: Text(pageTitles[homeController.selectedIndex.value], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            backgroundColor: ColorConstants.whiteMainColor,
            scrolledUnderElevation: 0.0,
            leading: IconButton(
                onPressed: () {
                  if (phoneNumbers.isNotEmpty) {
                    makePhoneCall(phoneNumbers[0]);
                  } else {
                    print("No phone numbers loaded!");
                  }
                },
                icon: HugeIcon(icon: HugeIcons.strokeRoundedCall02, size: 22, color: ColorConstants.kPrimaryColor)),
            actions: homeController.selectedIndex.value == 1
                ? [
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedRefresh,
                        color: ColorConstants.kPrimaryColor,
                      ),
                      onPressed: () {
                        // DiscoveryController'ı bul ve refresh yap
                        try {
                          final discoveryController = Get.find<DiscoveryController>();
                          discoveryController.onRefresh();
                        } catch (e) {
                          print('DiscoveryController not found: $e');
                        }
                      },
                      tooltip: 'refresh'.tr,
                    ),
                  ]
                : null,
          ),
          body: IndexedStack(
            index: homeController.selectedIndex.value,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: homeController.selectedIndex.value,
            onTap: (index) {
              homeController.selectedIndex.value = index;
            },
            selectedItemColor: ColorConstants.kSecondaryColor,
            unselectedItemColor: Colors.grey,
            backgroundColor: ColorConstants.whiteMainColor,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
            selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            items: [
              BottomNavigationBarItem(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedHome09, color: Colors.grey),
                activeIcon: HugeIcon(icon: HugeIcons.strokeRoundedHome09, color: ColorConstants.kSecondaryColor),
                label: pageTitles[0].tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(IconlyLight.discovery),
                activeIcon: Icon(IconlyBold.discovery),
                label: pageTitles[1].tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(IconlyLight.category),
                activeIcon: Icon(IconlyBold.category),
                label: pageTitles[2].tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(IconlyLight.heart),
                activeIcon: Icon(IconlyBold.heart),
                label: pageTitles[3].tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(IconlyLight.profile),
                activeIcon: Icon(IconlyBold.profile),
                label: pageTitles[4].tr,
              ),
            ],
          ),
        );
      }),
    );
  }
}
