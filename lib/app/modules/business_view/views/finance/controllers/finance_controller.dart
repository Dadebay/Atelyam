import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:get/get.dart';

import '../models/finance_data.dart';
import '../services/finance_service.dart';

class FinanceController extends GetxController {
  final FinanceService _financeService = FinanceService();

  final Rx<FinanceData?> financeData = Rx<FinanceData?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedPeriod = 'monthly'.obs; // 'daily', 'weekly', 'monthly'
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFinanceData();
  }

  Future<void> loadFinanceData({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    error.value = '';

    try {
      final data = await _financeService.getFinanceData(period: selectedPeriod.value);
      financeData.value = data;
    } catch (e) {
      print('❌ Error loading finance data: $e');
      error.value = e.toString();
      showSnackBar('error'.tr, 'Failed to load finance data', ColorConstants.redColor);
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> changePeriod(String period) async {
    selectedPeriod.value = period;
    await loadFinanceData();
  }

  Future<void> addExpense({
    required String title,
    required String category,
    required double amount,
  }) async {
    try {
      await _financeService.createExpense(
        title: title,
        category: category,
        amount: amount,
      );
      showSnackBar('success'.tr, 'Expense added successfully', ColorConstants.kPrimaryColor);
      await loadFinanceData(silent: true);
    } catch (e) {
      print('❌ Error adding expense: $e');
      showSnackBar('error'.tr, 'Failed to add expense', ColorConstants.redColor);
      rethrow;
    }
  }

  Future<void> deleteExpense(int expenseId) async {
    try {
      await _financeService.deleteExpense(expenseId);
      showSnackBar('success'.tr, 'Expense deleted successfully', ColorConstants.kPrimaryColor);
      await loadFinanceData(silent: true);
    } catch (e) {
      print('❌ Error deleting expense: $e');
      showSnackBar('error'.tr, 'Failed to delete expense', ColorConstants.redColor);
    }
  }
}
