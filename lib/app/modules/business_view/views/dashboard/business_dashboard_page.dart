import 'package:atelyam/app/modules/business_view/views/business_currency_controller.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import 'controllers/dashboard_controller.dart';
import 'widgets/dashboard_widgets.dart';

class BusinessDashboardPage extends StatefulWidget {
  const BusinessDashboardPage({super.key});

  @override
  State<BusinessDashboardPage> createState() => _BusinessDashboardPageState();
}

class _BusinessDashboardPageState extends State<BusinessDashboardPage> {
  late final BusinessCurrencyController _ctrl;
  late final DashboardController _dashboardCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<BusinessCurrencyController>();
    _dashboardCtrl = Get.put(DashboardController());
  }

  @override
  void dispose() {
    Get.delete<DashboardController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currency = _ctrl.currency.value;
      final isLoading = _dashboardCtrl.isLoading.value;
      final data = _dashboardCtrl.dashboardData.value;

      return Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _dashboardCtrl.refresh(),
            color: ColorConstants.kSecondaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'dashboard'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: Fonts.gilroy,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: AppCurrency.values.map((c) {
                            final selected = c == currency;
                            return GestureDetector(
                              onTap: () => _ctrl.select(c),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: selected ? ColorConstants.kPrimaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  c.label,
                                  style: TextStyle(
                                    fontFamily: Fonts.gilroy,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: selected ? Colors.white : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Loading indicator or content
                  if (isLoading && data == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          color: ColorConstants.kSecondaryColor,
                        ),
                      ),
                    )
                  else if (data != null) ...[
                    // Status cards
                    Row(
                      children: [
                        Expanded(
                          child: StatusCard(
                            icon: HugeIcons.strokeRoundedTask01,
                            label: 'new_orders'.tr,
                            count: data.cards.newOrders,
                            bgColor: const Color(0xFF3B79F6),
                            filled: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatusCard(
                            icon: HugeIcons.strokeRoundedClock01,
                            label: 'in_progress'.tr,
                            count: data.cards.inProgress,
                            bgColor: const Color(0xFFF5A623),
                            filled: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatusCard(
                            icon: HugeIcons.strokeRoundedPackage,
                            label: 'filter_ready'.tr,
                            count: data.cards.ready,
                            bgColor: const Color(0xFF27AE60),
                            filled: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatusCard(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                            label: 'filter_completed'.tr,
                            count: data.cards.completed,
                            bgColor: Colors.white,
                            filled: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Financial cards
                    Row(
                      children: [
                        Expanded(
                          child: FinanceCard(
                            icon: HugeIcons.strokeRoundedMoney01,
                            iconColor: ColorConstants.greenColor,
                            label: 'today'.tr,
                            value: data.financials.today,
                            currency: currency,
                            valueColor: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FinanceCard(
                            icon: HugeIcons.strokeRoundedTradeUp,
                            iconColor: const Color(0xFF3B79F6),
                            label: 'this_month'.tr,
                            value: data.financials.thisMonth,
                            currency: currency,
                            valueColor: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FinanceCard(
                            icon: HugeIcons.strokeRoundedAlert01,
                            iconColor: ColorConstants.redColor,
                            label: 'outstanding'.tr,
                            value: data.financials.outstanding,
                            currency: currency,
                            valueColor: ColorConstants.redColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Recent orders
                    Text(
                      'recent_orders'.tr,
                      style: TextStyle(
                        fontFamily: Fonts.gilroy,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (data.recentOrders.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(
                            'no_recent_orders'.tr,
                            style: TextStyle(
                              fontFamily: Fonts.gilroy,
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      )
                    else
                      ...data.recentOrders.map((order) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: DashOrderCard(
                              customer: order.clientName,
                              item: order.orderName,
                              status: order.status,
                              price: order.price,
                              due: order.due,
                              date: order.date,
                              currency: currency,
                            ),
                          )),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
