import 'package:atelyam/app/product/custom_widgets/widgets.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:get/get.dart';

import '../../orders/models/order_item.dart';
import '../../orders/services/deadline_storage.dart';
import '../../orders/services/order_service.dart';
import '../models/dashboard_data.dart';
import '../services/dashboard_service.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = DashboardService();
  final OrderService _orderService = OrderService();

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
      // Fetch dashboard data and full orders in parallel
      final results = await Future.wait([
        _dashboardService.getDashboardData(),
        _orderService.fetchOrders(),
      ]);
      final data = results[0] as DashboardData;
      final allOrders = results[1] as List<OrderItem>;

      // Build a map: clientName|orderName → full OrderItem (with real id & client)
      final orderByKey = <String, OrderItem>{};
      for (final o in allOrders) {
        orderByKey['${o.clientName}|${o.orderName}'] = o;
      }

      // Read deadlines using real order IDs from orders endpoint
      final deadlines = DeadlineStorage.readAll(allOrders.map((o) => o.id).toList());

      // Legacy migration: deadline may have been saved under id=0 (old bug)
      // Safe to migrate only when there is exactly one recent order (unambiguous)
      final legacyDl = DeadlineStorage.read(0);
      if (legacyDl != null && data.recentOrders.length == 1) {
        final singleKey = '${data.recentOrders.first.clientName}|${data.recentOrders.first.orderName}';
        final target = orderByKey[singleKey];
        if (target != null && deadlines[target.id] == null) {
          print('🔄 Migrating legacy deadline (id=0) → id=${target.id}');
          DeadlineStorage.save(target.id, legacyDl);
          DeadlineStorage.save(0, null); // remove legacy key
          deadlines[target.id] = legacyDl; // update in-memory map
        }
      }

      // Match recent orders: fix id, client and attach deadline
      final updatedOrders = data.recentOrders.map((o) {
        final key = '${o.clientName}|${o.orderName}';
        final fullOrder = orderByKey[key];
        final dl = fullOrder != null ? deadlines[fullOrder.id] : null;

        print('🔍 Matching "$key" → fullOrder.id=${fullOrder?.id}, dl=$dl');

        // Build new DashboardOrder directly (avoid reflection issues with copyWith)
        return DashboardOrder(
          id: fullOrder?.id ?? o.id,
          client: fullOrder?.client ?? o.client,
          clientName: o.clientName,
          orderName: o.orderName,
          status: o.status,
          price: o.price,
          due: o.due,
          date: o.date,
          deadline: dl,
        );
      }).toList();

      if (updatedOrders.any((o) => o.id == 0)) {
        print('⚠️ WARNING: Some dashboard orders still have id=0 after matching!');
      }

      dashboardData.value = DashboardData(
        cards: data.cards,
        financials: data.financials,
        recentOrders: updatedOrders,
      );
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
