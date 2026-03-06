import 'dart:io';
import 'package:atelyam/app/data/service/banner_service.dart';
import 'package:atelyam/app/modules/category_view/views/category_view.dart';
import 'package:atelyam/app/modules/discovery_view/controllers/discovery_controller.dart';
import 'package:atelyam/app/modules/discovery_view/views/discovery_view.dart';
import 'package:atelyam/app/modules/home_view/controllers/home_controller.dart';
import 'package:atelyam/app/modules/home_view/views/home_view.dart';
import 'package:atelyam/app/modules/map_view/views/map_view.dart';
import 'package:atelyam/app/modules/settings_view/views/settings_view.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/custom_widgets/offline_indicator.dart';
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

  final List<Widget> pages = [HomeView(), DiscoveryView(), CategoryView(), const MapView(), SettingsView()];

  final List<String> pageTitles = ['home', 'discovery', 'categories', 'map', 'settings'];

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

  void _showPhoneBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Başlık
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCall02,
                  size: 20,
                  color: ColorConstants.kPrimaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Telefon Numaraları',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.kPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            // Numara listesi
            ...phoneNumbers.map((phone) {
              final String phoneStr = phone.toString();
              String flag;
              String label;
              if (phoneStr.startsWith('+998')) {
                flag = '🇺🇿';
                label = 'Özbekistan';
              } else if (phoneStr.startsWith('+993')) {
                flag = '🇹🇲';
                label = 'Türkmenistan';
              } else {
                flag = '📞';
                label = '';
              }

              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                      makePhoneCall(phoneStr);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      child: Row(
                        children: [
                          Text(flag, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (label.isNotEmpty)
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              Text(
                                phoneStr,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ColorConstants.kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(
                            Icons.call_rounded,
                            color: ColorConstants.kSecondaryColor,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                ],
              );
            }),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
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
          resizeToAvoidBottomInset: false,
          appBar: homeController.selectedIndex.value == 4
              ? null
              : AppBar(
                  title: Text(pageTitles[homeController.selectedIndex.value].tr, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  backgroundColor: ColorConstants.whiteMainColor,
                  scrolledUnderElevation: 0.0,
                  leading: IconButton(
                      onPressed: () {
                        if (phoneNumbers.isNotEmpty) {
                          _showPhoneBottomSheet(context);
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
                              if (Get.isRegistered<DiscoveryController>()) {
                                final discoveryController = Get.find<DiscoveryController>();
                                discoveryController.fetchProducts(isRefresh: true);
                              } else {
                                homeController.selectedIndex.value = 1;
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (Get.isRegistered<DiscoveryController>()) {
                                    Get.find<DiscoveryController>().fetchProducts(isRefresh: true);
                                  }
                                });
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
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OfflineIndicator(),
              BottomNavigationBar(
                currentIndex: homeController.selectedIndex.value,
                onTap: (index) {
                  FocusScope.of(context).unfocus();
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
                    icon: Icon(IconlyLight.location),
                    activeIcon: Icon(IconlyBold.location),
                    label: pageTitles[3].tr,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(IconlyLight.profile),
                    activeIcon: Icon(IconlyBold.profile),
                    label: pageTitles[4].tr,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
