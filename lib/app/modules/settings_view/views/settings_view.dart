import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/modules/home_view/views/bottom_nav_bar_view.dart';
import 'package:atelyam/app/modules/settings_view/components/settings_button.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatelessWidget {
  final NewSettingsPageController settingsController = Get.put<NewSettingsPageController>(NewSettingsPageController());

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
          return EmptyStates().loadingData();
        } else if (snapshot.hasError) {
          return EmptyStates().errorData(snapshot.error.toString());
        } else {
          final String? token = snapshot.data;
          final List<Map<String, dynamic>> currentSettingsViews = token != null && token.isNotEmpty ? loggedInSettingsViews : settingsViews;

          return ListView.builder(
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
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.whiteMainColor,
      body: _buildSettingsList(),
    );
  }
}
