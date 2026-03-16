import 'package:atelyam/app/product/initialize/firebase_analytics_service.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'models/client_model.dart';
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
  final ClientService _clientService = ClientService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<ClientModel> _allClients = <ClientModel>[];
  List<ClientModel> _filteredClients = <ClientModel>[];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
    _loadClients();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClients({bool silent = false}) async {
    print('📋 Loading clients... (silent: $silent)');
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
      final clients = await _clientService.fetchClients();
      print('📋 Loaded ${clients.length} clients');
      if (!mounted) return;
      setState(() {
        _allClients = clients;
        _applySearch();
        _isLoading = false;
        _isRefreshing = false;
      });
      print('📋 UI updated, filtered: ${_filteredClients.length} clients');
    } catch (_) {
      print('❌ Failed to load clients');
      if (!mounted) return;
      setState(() {
        _error = 'client_error'.tr;
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  void _onSearch() {
    _applySearch();
    final q = _searchCtrl.text.trim();
    if (q.length >= 2) {
      FirebaseAnalyticsService.instance().logBusinessCustomerSearch(query: q);
    }
  }

  void _applySearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    _filteredClients = q.isEmpty ? List<ClientModel>.from(_allClients) : _allClients.where((client) => client.name.toLowerCase().contains(q) || client.phone.toLowerCase().contains(q)).toList();
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
            await _loadClients(silent: true);
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
              onPressed: _loadClients,
              child: Text('try_again'.tr),
            ),
          ],
        ),
      );
    }

    if (_filteredClients.isEmpty) {
      return Center(
        child: Text(
          'no_customers_found'.tr,
          style: TextStyle(
            fontFamily: Fonts.gilroy,
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Stack(
      children: <Widget>[
        RefreshIndicator(
          color: const Color(0xFF3B79F6),
          onRefresh: () => _loadClients(silent: true),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: _filteredClients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return CustomerTile(
                client: _filteredClients[index],
                service: _clientService,
                onChanged: () => _loadClients(silent: true),
              );
            },
          ),
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
