import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/modules/home_view/views/bottom_nav_bar_view.dart';
import 'package:atelyam/app/modules/settings_view/components/settings_button.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  final NewSettingsPageController settingsController = Get.put<NewSettingsPageController>(NewSettingsPageController());

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (BuildContext context, constraints) {
        final scrolled = constraints.scrollOffset > 310;
        return SliverAppBar(
          expandedHeight: Get.size.width >= 800 ? 450 : 300,
          floating: false,
          pinned: true,
          backgroundColor: scrolled ? Colors.transparent.withOpacity(0.6) : Colors.transparent,
          title: Text(
            'profil'.tr,
          ),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontFamily: Fonts.plusJakartaSans,
            fontSize: AppFontSizes.fontSize24,
            fontWeight: FontWeight.w600,
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: GestureDetector(
              onTap: () => Dialogs().showAvatarDialog(),
              child: Obx(
                () {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        radius: 62,
                        child: CircleAvatar(
                          radius: 60,
                          child: Image.asset(
                            settingsController.avatars[settingsController.selectedAvatarIndex.value],
                            width: 90,
                            height: 90,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          settingsController.username.value.isEmpty ? 'Ulanyjy 007 ' : settingsController.username.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: AppFontSizes.fontSize20 + 2,
                          ),
                        ),
                      ),
                      Text(
                        settingsController.phoneNumber.value.isEmpty ? ' +993-60-00-00-00' : '+993-${formatPhoneNumber(settingsController.phoneNumber.value)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: AppFontSizes.fontSize16,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  String formatPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.replaceAll('-', '');
    String formattedNumber = '';
    for (int i = 0; i < phoneNumber.length; i++) {
      formattedNumber += phoneNumber[i];
      if ((i + 1) % 2 == 0 && i != phoneNumber.length - 1) {
        formattedNumber += '-';
      }
    }

    return formattedNumber;
  }

  Widget _buildSettingsList() {
    return FutureBuilder<String?>(
      future: Auth().getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(child: EmptyStates().loadingData());
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: EmptyStates().errorData(snapshot.error.toString()),
          );
        } else {
          final String? token = snapshot.data;
          final List<Map<String, dynamic>> currentSettingsViews = token != null && token.isNotEmpty ? loggedInSettingsViews : settingsViews;

          return SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: ColorConstants.whiteMainColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: ColorConstants.kSecondaryColor.withOpacity(0.2),
                    width: 2,
                  ),
                  left: BorderSide.none,
                  right: BorderSide.none,
                  bottom: BorderSide.none,
                ),
              ),
              child: ListView.builder(
                itemCount: currentSettingsViews.length,
                padding: const EdgeInsets.only(top: 20),
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final item = currentSettingsViews[index];
                  return token != null && token.isNotEmpty && item['name'] == 'login'
                      ? SettingsButton(
                          name: 'delete_account'.tr,
                          lang: false,
                          onTap: () {
                            Get.bottomSheet(
                              Dialogs().deleteAccount(
                                onYestapped: () async {
                                  await Auth().logout();
                                  Get.back();
                                  await Get.offAll(() => BottomNavBar());
                                },
                              ),
                            );
                          },
                          icon: Icon(
                            IconlyLight.delete,
                            color: ColorConstants.kSecondaryColor,
                          ),
                        )
                      : SettingsButton(
                          name: "${item['name']}".tr,
                          lang: item['name'] == 'lang',
                          onTap: () {
                            if (item['name'] == 'lang') {
                              settingsController.showLanguageDialog(context);
                            } else {
                              Get.to(item['page']);
                            }
                          },
                          icon: Icon(
                            item['icon'],
                            color: ColorConstants.kSecondaryColor,
                          ),
                        );
                },
              ),
            ),
          );
        }
      },
    );
  }

  SliverToBoxAdapter _buildSpacer() {
    return SliverToBoxAdapter(
      child: Container(
        color: ColorConstants.whiteMainColor,
        height: Get.size.width >= 800 ? Get.size.height / 2 : Get.size.height / 4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildSettingsList(),
          _buildSpacer(),
        ],
      ),
    );
  }
}
