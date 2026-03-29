import 'package:atelyam/app/modules/business_view/views/business_currency_controller.dart';
import 'package:atelyam/app/modules/business_view/views/customers/pages/customer_detail_page.dart';
import 'package:atelyam/app/modules/business_view/views/customers/services/client_service.dart';
import 'package:atelyam/app/modules/business_view/views/finance/controllers/finance_controller.dart';
import 'package:atelyam/app/modules/business_view/views/finance/models/outstanding_customer_model.dart';
import 'package:atelyam/app/modules/business_view/views/finance/pages/add_expense_page.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class BusinessFinancePage extends StatelessWidget {
  const BusinessFinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final FinanceController controller = Get.put(FinanceController());
    final BusinessCurrencyController currencyController = Get.find<BusinessCurrencyController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.financeData.value == null) {
            return EmptyStates().loadingData();
          }

          final data = controller.financeData.value;
          if (data == null) {
            return Center(child: Text('no_data'.tr));
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadFinanceData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'finance'.tr,
                    style: TextStyle(
                      fontFamily: Fonts.gilroy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),

                  // Period filter
                  _buildPeriodFilter(controller),

                  // Stats cards
                  _buildStatsGrid(data, currencyController),

                  const SizedBox(height: 24),

                  // Recent Expenses header with Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'recent_expenses'.tr,
                        style: TextStyle(
                          fontFamily: Fonts.gilroy,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final result = await Get.to(() => const AddExpensePage());
                          if (result == true) {
                            await controller.loadFinanceData();
                          }
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ColorConstants.kSecondaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(HugeIcons.strokeRoundedAdd01, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Recent Expenses list
                  _buildExpensesList(data, controller, currencyController),

                  const SizedBox(height: 24),

                  // Outstanding Payments header
                  Text(
                    'outstanding_payments'.tr,
                    style: TextStyle(
                      fontFamily: Fonts.gilroy,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Outstanding — per-customer list
                  Obx(() => _buildOutstandingList(
                        context,
                        controller,
                        controller.outstandingCustomers,
                        currencyController,
                      )),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _openCustomerDetail(
    BuildContext context,
    FinanceController controller,
    OutstandingCustomer customer,
  ) async {
    if (customer.id == 0) {
      Get.snackbar(
        'error'.tr,
        'unknownError'.tr,
        backgroundColor: ColorConstants.redColor,
        colorText: Colors.white,
      );
      return;
    }

    final clientService = ClientService();

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final client = await clientService.fetchClientById(customer.id);
      if (Get.isDialogOpen ?? false) Get.back<void>();
      await Get.to<void>(
        () => CustomerDetailPage(
          client: client,
          service: clientService,
          onChanged: () async => controller.loadFinanceData(silent: true),
        ),
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back<void>();
      Get.snackbar(
        'error'.tr,
        'unknownError'.tr,
        backgroundColor: ColorConstants.redColor,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildPeriodFilter(FinanceController controller) {
    return Obx(() {
      final selected = controller.selectedPeriod.value;

      return Container(
        height: 42,
        margin: const EdgeInsets.only(top: 10, bottom: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _periodButton('daily', 'daily', selected, controller),
            _periodButton('weekly', 'weekly', selected, controller),
            _periodButton('monthly', 'monthly', selected, controller),
          ],
        ),
      );
    });
  }

  Widget _periodButton(String label, String value, String selected, FinanceController controller) {
    final isSelected = selected == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changePeriod(value),
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? ColorConstants.kSecondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label.tr,
            style: TextStyle(
              fontFamily: Fonts.gilroy,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(data, BusinessCurrencyController currency) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _buildStatCard(
          'income',
          data.income,
          HugeIcons.strokeRoundedArrowUpRight01,
          Colors.green.shade600,
          Colors.green.shade50,
          currency,
        ),
        _buildStatCard(
          'expenses',
          data.expenses,
          HugeIcons.strokeRoundedArrowDownRight01,
          Colors.red.shade600,
          Colors.red.shade50,
          currency,
        ),
        _buildStatCard(
          'net_profit',
          data.netProfit,
          HugeIcons.strokeRoundedDollarCircle,
          Colors.blue.shade600,
          Colors.blue.shade50,
          currency,
        ),
        _buildStatCard(
          'outstanding',
          data.outstanding,
          HugeIcons.strokeRoundedClock01,
          Colors.orange.shade600,
          Colors.orange.shade50,
          currency,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    double amount,
    IconData icon,
    Color iconColor,
    Color bgColor,
    BusinessCurrencyController currency,
  ) {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 15),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Expanded(
                child: Obx(() => FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currency.currency.value.format(amount),
                        style: TextStyle(
                          fontFamily: Fonts.gilroy,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: title == 'net_profit' && amount < 0 ? Colors.red : Colors.black,
                        ),
                      ),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: Fonts.gilroy,
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(data, FinanceController controller, BusinessCurrencyController currency) {
    if (data.recentExpenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'no_expenses_yet'.tr,
            style: TextStyle(
              fontFamily: Fonts.gilroy,
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.recentExpenses.length,
      itemBuilder: (context, index) {
        final expense = data.recentExpenses[index];
        return Obx(() {
          final isNew = controller.lastAddedExpenseId.value == expense.id;
          return Dismissible(
            key: Key('expense_${expense.id}_$index'),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              child: const Icon(HugeIcons.strokeRoundedDelete02, color: Colors.white),
            ),
            onDismissed: (_) => controller.deleteExpense(expense.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isNew ? Colors.green.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isNew ? Border.all(color: Colors.green.shade400, width: 1.5) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: TextStyle(
                            fontFamily: Fonts.gilroy,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${expense.category} · ${_formatDate(expense.date)}',
                          style: TextStyle(
                            fontFamily: Fonts.gilroy,
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() => Text(
                        '-${currency.currency.value.format(expense.amount)}',
                        style: TextStyle(
                          fontFamily: Fonts.gilroy,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade600,
                        ),
                      )),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildOutstandingList(
    BuildContext context,
    FinanceController controller,
    List<OutstandingCustomer> customers,
    BusinessCurrencyController currency,
  ) {
    if (customers.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Center(
          child: Text(
            'no_outstanding_payments'.tr,
            style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 14, color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return Column(
      children: customers.map((customer) {
        return GestureDetector(
          onTap: () => _openCustomerDetail(context, controller, customer),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF2B6FDE),
                  child: Text(
                    customer.initial,
                    style: TextStyle(
                      fontFamily: Fonts.gilroy,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    customer.name,
                    style: TextStyle(
                      fontFamily: Fonts.gilroy,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Obx(() => Text(
                      currency.currency.value.format(customer.outstanding),
                      style: TextStyle(
                        fontFamily: Fonts.gilroy,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade600,
                      ),
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('MMM d').format(parsed);
    } catch (e) {
      return date;
    }
  }
}
