import 'package:get/get.dart';

class BusinessCategoryController extends GetxController {
  final selectedIndex = 0.obs;

  void setSelectedIndex(int index) {
    selectedIndex.value = index;
  }
}
