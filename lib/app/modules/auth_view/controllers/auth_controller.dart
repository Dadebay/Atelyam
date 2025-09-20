import 'package:atelyam/app/data/service/auth_service.dart';
import 'package:atelyam/app/modules/auth_view/views/otp_view.dart';
import 'package:atelyam/app/modules/home_view/controllers/home_controller.dart';
import 'package:atelyam/app/modules/home_view/views/bottom_nav_bar_view.dart';
import 'package:atelyam/app/modules/settings_view/controllers/settings_controller.dart';
import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final ipAddress = 'http://216.250.12.49:8000'.obs;

  Future<void> handleAuthAction({required String phoneController, required String usernameController}) async {
    final HomeController homeController = Get.find();
    print(phoneController);
    print(usernameController);
    homeController.agreeButton.toggle();
    final signInService = SignInService();
    final phoneNumber = phoneController;
    final userName = usernameController;
    try {
      final registerResponse = await signInService.register(phoneNumber: phoneNumber, name: userName);
      if (registerResponse == 200) {
        homeController.agreeButton.toggle();
        await Get.to(() => OTPView(phoneNumber: phoneNumber, userName: userName));
      } else {
        final loginResponse = await signInService.login(phone: phoneNumber);

        if (loginResponse == 200) {
          homeController.agreeButton.toggle();
          await Get.to(() => OTPView(phoneNumber: phoneNumber, userName: userName));
        } else {
          homeController.agreeButton.toggle();
          showSnackBar('error', 'errorLogin', ColorConstants.redColor);
        }
      }
    } catch (e) {
      homeController.agreeButton.toggle();
      showSnackBar('error', 'errorLogin', ColorConstants.redColor);
    }
  }

  Future<void> verifyOTP({required String phoneNumber, required List<TextEditingController> otpControllers, required String username}) async {
    final String otp = otpControllers.map((controller) => controller.text).join();
    if (otp.length == 4) {
      final response = await SignInService().otpCheck(phoneNumber: phoneNumber, otp: otp);
      if (response == 200) {
        final homeController = Get.find<HomeController>();
        final settingsController = Get.find<NewSettingsPageController>();
        homeController.selectedIndex.value = 0;
        settingsController.isLoginView.value = true;
        await settingsController.saveUserData(username, phoneNumber);
        showSnackBar('success', 'successOTP', ColorConstants.kSecondaryColor);
        await Get.offAll(() => BottomNavBar());
      } else {
        showSnackBar('error', 'errorOTP', Colors.red);
      }
    } else {
      showSnackBar('error', 'errorOTP', Colors.red);
    }
  }
}
