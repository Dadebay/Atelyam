import 'package:atelyam/app/product/initialize/firebase_analytics_service.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/customer_controller.dart';
import 'pages/add_customer_page.dart';
import 'services/client_service.dart';
import 'widgets/customer_tile.dart';
import 'widgets/search_bar.dart';

class BusinessCustomersPage extends StatefulWidget {
  const BusinessCustomersPage({super.key});

  @override
  State<BusinessCustomersPage> createState() => _BusinessCustomersPageState();
}

class _BusinessCustomersPageState extends State<BusinessCustomersPage> {
  late final CustomerController _controller;
  final ClientService _clientService = ClientService();
  final TextEditingController _searchCtrl = TextEditingController();

  List filteredClients = [];

  @override
  void initState() {
    super.initState();
    _controller = Get.put<CustomerController>(CustomerController());
    _searchCtrl.addListener(_onSearch);

    // Clients yüklenince filtreyi uygula
    ever(_controller.clients, (_) => _applySearch());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    setState(() => _applySearch());
    final q = _searchCtrl.text.trim();
    if (q.length >= 2) {
      FirebaseAnalyticsService.instance().logBusinessCustomerSearch(query: q);
    }
  }

  void _applySearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      filteredClients = q.isEmpty
          ? List.from(_controller.clients)
          : _controller.clients.where((c) => c.name.toLowerCase().contains(q) || c.phone.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_customers',
        onPressed: () async {
          print('🎯 Opening AddCustomerPage...');
          final created = await Get.to<bool>(() => AddCustomerPage(service: _clientService));
          print('🎯 AddCustomerPage closed, result: $created');
          if (created == true) {
            print('🔄 Refreshing customer list...');
            await _controller.refresh();
            print('🔄 Customer list refreshed');
          }
        },
        backgroundColor: const Color(0xFF3B79F6),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              Text(
                'customers'.tr,
                style: TextStyle(
                  fontFamily: Fonts.gilroy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              CustomerSearchBar(controller: _searchCtrl),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFF3B79F6)));
      }

      if (_controller.error.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'client_error'.tr,
                style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _controller.loadClients,
                child: Text('try_again'.tr),
              ),
            ],
          ),
        );
      }

      if (filteredClients.isEmpty) {
        return Center(
          child: Text(
            'no_customers_found'.tr,
            style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 15, color: Colors.grey),
          ),
        );
      }

      return RefreshIndicator(
        color: const Color(0xFF3B79F6),
        onRefresh: _controller.refresh,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          itemCount: filteredClients.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return CustomerTile(
              client: filteredClients[index],
              service: _clientService,
              onChanged: () => _controller.refresh(),
            );
          },
        ),
      );
    });
  }
}
