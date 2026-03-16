import 'package:atelyam/app/modules/business_view/views/business_currency_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import 'models/order_item.dart';
import 'pages/add_order_page.dart';
import 'services/order_service.dart';
import 'widgets/order_card.dart';

class BusinessOrdersPage extends StatefulWidget {
  const BusinessOrdersPage({super.key});

  @override
  State<BusinessOrdersPage> createState() => _BusinessOrdersPageState();
}

class _BusinessOrdersPageState extends State<BusinessOrdersPage> {
  final OrderService _orderService = OrderService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<OrderItem> _allOrders = <OrderItem>[];
  List<OrderItem> _filteredOrders = <OrderItem>[];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  String _activeFilter = 'All';

  static const _filters = <String>['All', 'new', 'in progress', 'ready', 'completed'];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_applyFilter);
    _loadOrders();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOrders({bool silent = false}) async {
    print('📋 Loading orders... (silent: $silent)');
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      setState(() {
        _isRefreshing = true;
      });
    }

    try {
      final orders = await _orderService.fetchOrders();
      print('📋 Loaded ${orders.length} orders');
      if (!mounted) return;
      setState(() {
        _allOrders = orders;
        _applyFilter();
        _isLoading = false;
        _isRefreshing = false;
      });
      print('📋 UI updated, filtered: ${_filteredOrders.length} orders');
    } catch (e) {
      print('❌ Failed to load orders: $e');
      if (!mounted) return;
      setState(() {
        _error = 'failed_to_load_orders'.tr;
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredOrders = _allOrders.where((o) {
        final matchFilter = _activeFilter == 'All' || o.status.toLowerCase() == _activeFilter.toLowerCase();
        final matchSearch = q.isEmpty || o.clientName.toLowerCase().contains(q) || o.orderName.toLowerCase().contains(q);
        return matchFilter && matchSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_orders',
        onPressed: () async {
          print('🎯 Opening AddOrderPage...');
          final created = await Get.to<bool>(() => AddOrderPage(service: _orderService));
          print('🎯 AddOrderPage closed, result: $created');
          if (created == true) {
            print('🔄 Refreshing order list...');
            await _loadOrders(silent: true);
            print('🔄 Order list refreshed');
          }
        },
        backgroundColor: const Color(0xFF3B79F6),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Text(
                'orders'.tr,
                style: TextStyle(
                  fontFamily: Fonts.gilroy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'search_orders'.tr,
                    hintStyle: TextStyle(fontFamily: Fonts.gilroy, fontSize: 14, color: Colors.grey.shade400),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Icon(IconlyLight.search, size: 20, color: Colors.grey.shade400),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = _filters[i];
                  final selected = f == _activeFilter;
                  String labelKey;
                  if (f == 'All') {
                    labelKey = 'filter_all';
                  } else if (f == 'new') {
                    labelKey = 'filter_new';
                  } else if (f == 'in progress') {
                    labelKey = 'filter_in_progress';
                  } else if (f == 'ready') {
                    labelKey = 'filter_ready';
                  } else if (f == 'completed') {
                    labelKey = 'filter_completed';
                  } else {
                    labelKey = f;
                  }
                  return GestureDetector(
                    onTap: () {
                      setState(() => _activeFilter = f);
                      _applyFilter();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6).copyWith(top: selected ? 10 : 8),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF3B79F6) : Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: selected ? null : Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        labelKey.tr,
                        style: TextStyle(
                          fontFamily: Fonts.gilroy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3B79F6)),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _error!,
              style: TextStyle(
                fontFamily: Fonts.gilroy,
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadOrders,
              child: Text('try_again'.tr),
            ),
          ],
        ),
      );
    }

    if (_filteredOrders.isEmpty) {
      return Center(
        child: Text(
          'no_orders_found'.tr,
          style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 15, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: <Widget>[
        RefreshIndicator(
          color: const Color(0xFF3B79F6),
          onRefresh: () => _loadOrders(silent: true),
          child: Obx(() {
            final currency = Get.find<BusinessCurrencyController>().currency.value;
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _filteredOrders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => OrderCard(
                order: _filteredOrders[i],
                currency: currency,
                onTap: () async {
                  print('🎯 Opening order ${_filteredOrders[i].id} for edit...');
                  final updated = await Get.to<bool>(() => AddOrderPage(
                        service: _orderService,
                        order: _filteredOrders[i],
                      ));
                  print('🎯 Edit page closed, result: $updated');
                  if (updated == true) {
                    print('🔄 Refreshing order list after edit...');
                    await _loadOrders(silent: true);
                    print('🔄 Order list refreshed');
                  }
                },
              ),
            );
          }),
        ),
        if (_isRefreshing)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              minHeight: 2,
              color: Color(0xFF3B79F6),
              backgroundColor: Colors.transparent,
            ),
          ),
      ],
    );
  }
}
