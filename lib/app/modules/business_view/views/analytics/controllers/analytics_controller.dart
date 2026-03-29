import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:get/get.dart';

import '../models/analytics_data.dart';
import '../services/analytics_service.dart';

class AnalyticsController extends GetxController {
  final AnalyticsService _analyticsService = AnalyticsService();

  final Rx<AnalyticsData?> analyticsData = Rx<AnalyticsData?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAnalyticsData();
  }

  Future<void> loadAnalyticsData({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    error.value = '';

    try {
      final data = await _analyticsService.getAnalyticsData();
      analyticsData.value = data;
    } catch (e) {
      print('❌ Error loading analytics data: $e');
      error.value = e.toString();
      showSnackBar('error'.tr, 'Failed to load analytics data', ColorConstants.redColor);
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await loadAnalyticsData(silent: true);
  }
}
