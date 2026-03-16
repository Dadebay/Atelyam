import 'package:atelyam/app/modules/business_view/views/business_currency_controller.dart';
import 'package:atelyam/app/modules/business_view/views/finance/controllers/finance_controller.dart';
import 'package:atelyam/app/modules/business_view/views/finance/pages/add_expense_page.dart';
import 'package:atelyam/app/modules/business_view/views/orders/models/order_item.dart';
import 'package:atelyam/app/modules/business_view/views/orders/services/order_service.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class BusinessFinancePage extends StatefulWidget {
  const BusinessFinancePage({super.key});

  @override
  State<BusinessFinancePage> createState() => _BusinessFinancePageState();
}

class _BusinessFinancePageState extends State<BusinessFinancePage> {
  final FinanceController _controller = Get.put(FinanceController());
  final BusinessCurrencyController _currencyController = Get.find<BusinessCurrencyController>();
  final OrderService _orderService = OrderService();
  List<OrderItem> _outstandingOrders = [];
  bool _loadingOrders = true;

  @override
  void initState() {
    super.initState();
    _loadOutstandingOrders();
  }

  Future<void> _loadOutstandingOrders() async {
    try {
      final orders = await _orderService.fetchOrders();
      setState(() {
        _outstandingOrders = orders.where((o) => o.due > 0).toList();
        _loadingOrders = false;
      });
    } catch (e) {
      setState(() => _loadingOrders = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoading.value && _controller.financeData.value == null) {
            return EmptyStates().loadingData();
          }

          final data = _controller.financeData.value;
          if (data == null) {
            return Center(child: Text('No data available'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await _controller.loadFinanceData();
              await _loadOutstandingOrders();
            },
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
                  _buildPeriodFilter(),

                  // Stats cards
                  _buildStatsGrid(data),

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
                            await _controller.loadFinanceData();
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
                  _buildExpensesList(data),

                  const SizedBox(height: 24),

                  // Outstanding Payments
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

                  _buildOutstandingList(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    return Obx(() {
      final selected = _controller.selectedPeriod.value;

      return Container(
        height: 42,
        margin: EdgeInsets.only(top: 10, bottom: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _periodButton('daily', 'daily', selected),
            _periodButton('weekly', 'weekly', selected),
            _periodButton('monthly', 'monthly', selected),
          ],
        ),
      );
    });
  }

  Widget _periodButton(String label, String value, String selected) {
    final isSelected = selected == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => _controller.changePeriod(value),
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

  Widget _buildStatsGrid(data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.68,
      children: [
        _buildStatCard(
          'income',
          data.income,
          HugeIcons.strokeRoundedArrowUpRight01,
          Colors.green.shade600,
          Colors.green.shade50,
        ),
        _buildStatCard(
          'expenses',
          data.expenses,
          HugeIcons.strokeRoundedArrowDownRight01,
          Colors.red.shade600,
          Colors.red.shade50,
        ),
        _buildStatCard(
          'net_profit',
          data.netProfit,
          HugeIcons.strokeRoundedDollarCircle,
          Colors.blue.shade600,
          Colors.blue.shade50,
        ),
        _buildStatCard(
          'outstanding',
          data.outstanding,
          HugeIcons.strokeRoundedClock01,
          Colors.orange.shade600,
          Colors.orange.shade50,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, double amount, IconData icon, Color iconColor, Color bgColor) {
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
                margin: EdgeInsets.only(right: 15),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Expanded(
                child: Text(
                  '\$${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: Fonts.gilroy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: title == 'net_profit' && amount < 0 ? Colors.red : Colors.black,
                  ),
                ),
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

  Widget _buildExpensesList(data) {
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
        return Dismissible(
          key: Key('expense_${expense.id}'),
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
          onDismissed: (_) => _controller.deleteExpense(expense.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                      '-${_currencyController.currency.value.format(expense.amount)}',
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
      },
    );
  }

  Widget _buildOutstandingList() {
    if (_loadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_outstandingOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'no_outstanding_payments'.tr,
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
      itemCount: _outstandingOrders.length,
      itemBuilder: (context, index) {
        final order = _outstandingOrders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              CircleAvatar(
                radius: 20,
                backgroundColor: ColorConstants.kSecondaryColor.withOpacity(0.1),
                child: Text(
                  order.clientName.isNotEmpty ? order.clientName[0].toUpperCase() : 'C',
                  style: TextStyle(
                    fontFamily: Fonts.gilroy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.kSecondaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  order.clientName,
                  style: TextStyle(
                    fontFamily: Fonts.gilroy,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Obx(() => Text(
                    _currencyController.currency.value.format(order.due),
                    style: TextStyle(
                      fontFamily: Fonts.gilroy,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.red.shade600,
                    ),
                  )),
            ],
          ),
        );
      },
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
