import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:get/get.dart';

import 'package:atelyam/app/data/service/business_user_service.dart';
import '../models/finance_data.dart';
import '../models/outstanding_customer_model.dart';
import '../services/finance_service.dart';

class FinanceController extends GetxController {
  final FinanceService _financeService = FinanceService();

  final Rx<FinanceData?> financeData = Rx<FinanceData?>(null);
  final RxList<OutstandingCustomer> outstandingCustomers = <OutstandingCustomer>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedPeriod = 'monthly'.obs;
  final RxString error = ''.obs;
  final RxInt lastAddedExpenseId = (-1).obs; // Yeni eklenen giderin ID'si

  @override
  void onInit() {
    super.onInit();
    loadFinanceData();
  }

  Future<void> loadFinanceData({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    error.value = '';

    try {
      financeData.value = await _financeService.getFinanceData(period: selectedPeriod.value);
    } catch (e) {
      print('❌ Error loading finance data: $e');
      error.value = e.toString();
      showSnackBar('error'.tr, 'Failed to load finance data', ColorConstants.redColor);
    } finally {
      if (!silent) isLoading.value = false;
    }

    // Load outstanding separately so a failure here doesn't block finance data
    try {
      final outstanding = await _financeService.getOutstandingCustomers();
      outstandingCustomers.assignAll(outstanding);
    } catch (e) {
      print('❌ Error loading outstanding: $e');
      outstandingCustomers.clear();
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
      // 1. getMyStatus ile categoryUser ID'yi al
      final businessUserService = BusinessUserService();
      final statusList = await businessUserService.getMyStatus();

      print('🟠 addExpense: statusList = $statusList');

      if (statusList == null || statusList.isEmpty) {
        throw Exception('getMyStatus boş döndü — oturum açık mı?');
      }

      final me = statusList.first;
      print('🟠 me.id=${me.id}  me.user=${me.user}  me.categoryUser=${me.categoryUser}');

      // Backend'in istediği categoryuser ID: önce categoryUser, sonra id
      final categoryUserId = me.categoryUser ?? me.id;
      if (categoryUserId == null) {
        throw Exception('categoryUser ID alınamadı');
      }

      print('🟠 categoryUserId olarak kullanılacak: $categoryUserId');

      // 2. Gideri kaydet
      final created = await _financeService.createExpense(
        title: title,
        category: category,
        amount: amount,
        categoryUserId: categoryUserId,
      );

      lastAddedExpenseId.value = created.id;
      await loadFinanceData(silent: true);

      // Highlight'ı 3 saniye sonra kaldır
      Future.delayed(const Duration(seconds: 3), () {
        lastAddedExpenseId.value = -1;
      });
    } catch (e) {
      print('❌ Error adding expense: $e');
      rethrow; // Hatayı page'e ilet, orada snackbar gösterilecek
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
