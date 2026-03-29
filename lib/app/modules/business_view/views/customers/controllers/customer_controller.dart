import 'package:get/get.dart';

import '../models/client_model.dart';
import '../services/client_service.dart';

class CustomerController extends GetxController {
  final ClientService _clientService = ClientService();

  final RxList<ClientModel> clients = <ClientModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadClients();
  }

  Future<void> loadClients({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    error.value = '';
    try {
      final result = await _clientService.fetchClients();
      clients.assignAll(result);
    } catch (e) {
      print('❌ Error loading clients: $e');
      error.value = e.toString();
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await loadClients(silent: true);
  }
}
