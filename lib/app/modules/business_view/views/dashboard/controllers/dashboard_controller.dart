import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:get/get.dart';

import '../models/dashboard_data.dart';
import '../services/dashboard_service.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = DashboardService();

  final Rx<DashboardData?> dashboardData = Rx<DashboardData?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    error.value = '';

    try {
      final data = await _dashboardService.getDashboardData();
      dashboardData.value = data;
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      error.value = e.toString();
      showSnackBar('error'.tr, 'Failed to load dashboard data', ColorConstants.redColor);
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await loadDashboardData(silent: true);
  }
}
