import 'dart:io';
import 'dart:math' as math;

import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/initialize/local_notifications_service.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../customers/models/client_measurement.dart';
import '../../customers/models/client_model.dart';
import '../../customers/models/measurement_type.dart';
import '../../customers/services/client_service.dart';
import '../models/order_item.dart';
import '../services/deadline_storage.dart';
import '../services/order_service.dart';
import '../widgets/form_widgets.dart';
import '../widgets/order_card.dart';

class AddOrderPage extends StatefulWidget {
  final OrderService service;
  final OrderItem? order;

  const AddOrderPage({super.key, required this.service, this.order});

  @override
  State<AddOrderPage> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ClientService _clientService = ClientService();
  final TextEditingController _orderNameCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _dueCtrl = TextEditingController();

  List<ClientModel> _clients = <ClientModel>[];
  bool _loadingClients = true;
  bool _saving = false;
  ClientModel? _selectedClient;
  String _status = 'New Orders';
  File? _image;

  // Measurement controllers: keyed by MeasurementType.id (from getvalues)
  final Map<int, TextEditingController> _measurementCtrls = <int, TextEditingController>{};
  final Map<int, String> _originalMeasurements = <int, String>{};
  // Ordered list of types to display (28 standard + synthetic extras)
  List<MeasurementType> _measurementTypes = <MeasurementType>[];
  // typeId → MeasurementType for quick lookup
  Map<int, MeasurementType> _measurementTypeMap = <int, MeasurementType>{};

  // Bu değerler backend'deki status field'larıyla birebir eşleşmeli
  static const _statuses = <String>['New Orders', 'In Progress', 'Ready', 'Completed'];

  bool get _isEditMode => widget.order != null;
  bool _measurementsExpanded = false;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _loadClients();
    _initializeFormData();
  }

  void _initializeFormData() {
    if (_isEditMode) {
      final order = widget.order!;
      _orderNameCtrl.text = order.orderName;
      _priceCtrl.text = order.price.toString();
      _dueCtrl.text = order.due.toString();
      _status = order.status;
      // Load deadline from local storage, fall back to value passed via order
      _deadline = DeadlineStorage.read(order.id) ?? order.deadline;
    }
  }

  // ---------------------------------------------------------------------------
  // Measurement helpers
  // ---------------------------------------------------------------------------

  static String _normLabel(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r"['\u2018\u2019\u0060]"), '')
      .replaceAll("ý", "y")
      .replaceAll("ö", "o")
      .replaceAll("ä", "a")
      .replaceAll("ü", "u")
      .replaceAll("ş", "s")
      .replaceAll("ç", "c")
      .replaceAll("ğ", "g")
      .replaceAll("ň", "n")
      .replaceAll("ž", "z")
      .replaceAll('uzunligi', 'uzynlygy')
      .replaceAll('kokrak', 'dos')
      .trim();

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final mx = List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));
    for (int i = 0; i <= a.length; i++) mx[i][0] = i;
    for (int j = 0; j <= b.length; j++) mx[0][j] = j;
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        mx[i][j] = [mx[i - 1][j] + 1, mx[i][j - 1] + 1, mx[i - 1][j - 1] + cost].reduce(math.min);
      }
    }
    return mx[a.length][b.length];
  }

  /// EditCustomerPage ile aynı matching mantığı:
  /// Standart type listesini temel alır, client measurements ile eşleştirir.
  void _initMeasurementCtrls(ClientModel? client, List<MeasurementType> allTypes) {
    for (final ctrl in _measurementCtrls.values) ctrl.dispose();
    _measurementCtrls.clear();
    _originalMeasurements.clear();

    if (client == null) {
      _measurementTypes = <MeasurementType>[];
      return;
    }

    List<MeasurementType> types = List<MeasurementType>.from(allTypes);
    final Set<int> matchedTypeIds = <int>{};
    final Set<int> usedMeasurementTypeIds = <int>{};

    for (final type in types) {
      // 1. typeId ile eşleştir
      var existing = client.measurements.firstWhereOrNull(
        (m) => m.typeId != null && m.typeId == type.id,
      );
      // 2. Exact label match (tüm dil varyantları)
      existing ??= client.measurements.firstWhereOrNull((m) {
        final ml = m.label.toLowerCase().trim();
        return ml == type.name.toLowerCase().trim() ||
            (type.nameEn?.toLowerCase().trim() == ml) ||
            (type.nameRu?.toLowerCase().trim() == ml) ||
            (type.nameUz?.toLowerCase().trim() == ml) ||
            (type.nameTr?.toLowerCase().trim() == ml);
      });
      // 3. Normalized match (value olanı tercih et)
      if (existing == null || existing.value.trim().isEmpty) {
        final normTypeNames = [
          type.name,
          type.nameEn ?? '',
          type.nameRu ?? '',
          type.nameUz ?? '',
          type.nameTr ?? '',
        ].map(_normLabel).toSet();
        final normalized = client.measurements.firstWhereOrNull((m) {
          if (m.value.trim().isEmpty) return false;
          if (m.typeId != null && usedMeasurementTypeIds.contains(m.typeId)) return false;
          return normTypeNames.contains(_normLabel(m.label));
        });
        if (normalized != null) existing = normalized;
      }
      // 4. Fuzzy contains
      existing ??= client.measurements.firstWhereOrNull((m) {
        final ml = m.label.toLowerCase().trim();
        if (ml.isEmpty) return false;
        return [type.name, type.nameEn ?? '', type.nameUz ?? '', type.nameTr ?? ''].map((n) => n.toLowerCase().trim()).where((n) => n.isNotEmpty).any((n) => n.contains(ml) || ml.contains(n));
      });
      // 5. Levenshtein >= 65%
      if (existing == null || existing.value.trim().isEmpty) {
        final typeNames = [
          type.name,
          type.nameEn ?? '',
          type.nameRu ?? '',
          type.nameUz ?? '',
          type.nameTr ?? '',
        ].map(_normLabel).where((n) => n.isNotEmpty).toList();
        double bestScore = 0.65;
        ClientMeasurement? bestMatch;
        for (final m in client.measurements) {
          if (m.value.trim().isEmpty) continue;
          if (m.typeId != null && usedMeasurementTypeIds.contains(m.typeId)) continue;
          final ml = _normLabel(m.label);
          if (ml.isEmpty) continue;
          for (final tn in typeNames) {
            final maxLen = math.max(ml.length, tn.length);
            if (maxLen == 0) continue;
            final score = 1.0 - _levenshtein(ml, tn) / maxLen;
            if (score > bestScore) {
              bestScore = score;
              bestMatch = m;
            }
          }
        }
        if (bestMatch != null) existing = bestMatch;
      }

      if (existing?.typeId != null) {
        matchedTypeIds.add(existing!.typeId!);
        if (existing.value.trim().isNotEmpty) usedMeasurementTypeIds.add(existing.typeId!);
      }
      final prefill = existing?.value ?? '';
      _measurementCtrls[type.id] = TextEditingController(text: prefill);
      _originalMeasurements[type.id] = prefill;
    }

    // Eşleşemeyen ama value olan measurement'ları synthetic olarak ekle
    for (final m in client.measurements) {
      if (m.value.trim().isEmpty) continue;
      if (m.typeId == null) continue;
      if (matchedTypeIds.contains(m.typeId)) continue;
      if (types.any((t) => t.id == m.typeId)) continue;
      final synthetic = MeasurementType(id: m.typeId!, name: m.label);
      types.add(synthetic);
      _measurementCtrls[m.typeId!] = TextEditingController(text: m.value);
      _originalMeasurements[m.typeId!] = m.value;
    }

    _measurementTypes = types;
  }

  void _onClientChanged(ClientModel? client) {
    _initMeasurementCtrls(client, _measurementTypeMap.values.toList());
    setState(() => _selectedClient = client);
  }

  // ---------------------------------------------------------------------------

  Future<void> _loadClients() async {
    try {
      final results = await Future.wait(<Future<dynamic>>[
        _clientService.fetchClients(),
        _clientService.fetchMeasurementTypes(),
      ]);
      if (!mounted) return;
      final clients = results[0] as List<ClientModel>;
      final types = results[1] as List<MeasurementType>;
      final typeMap = <int, MeasurementType>{
        for (final t in types) t.id: t,
      };
      ClientModel? editClient;
      if (_isEditMode) {
        editClient = clients.firstWhere(
          (c) => c.id == widget.order!.client,
          orElse: () => clients.first,
        );
        _initMeasurementCtrls(editClient, types);
      }
      setState(() {
        _clients = clients;
        _loadingClients = false;
        _measurementTypeMap = typeMap;
        if (_isEditMode) _selectedClient = editClient;
      });
      print('📋 Loaded ${clients.length} clients for order');
    } catch (e) {
      print('❌ Failed to load clients: $e');
      if (!mounted) return;
      setState(() {
        _clients = <ClientModel>[];
        _loadingClients = false;
      });
    }
  }

  Widget _buildMeasurementsSection() {
    if (_measurementTypes.isEmpty) return const SizedBox.shrink();

    final filledTypes = _measurementTypes.where((t) {
      final ctrl = _measurementCtrls[t.id];
      return ctrl != null && ctrl.text.trim().isNotEmpty;
    }).toList();

    return OFormCard(
      children: <Widget>[
        // Collapsible header
        GestureDetector(
          onTap: () => setState(() => _measurementsExpanded = !_measurementsExpanded),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: <Widget>[
              const Icon(Icons.straighten_rounded, size: 16, color: Color(0xFF3B79F6)),
              const SizedBox(width: 6),
              Expanded(child: OFormLabel('measurements'.tr)),
              if (filledTypes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B79F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${filledTypes.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3B79F6),
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _measurementsExpanded ? 0.5 : 0,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _measurementsExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'client_measurements_hint'.tr,
                style: TextStyle(
                  fontFamily: Fonts.gilroy,
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 12),
              ..._measurementTypes.map((type) {
                final ctrl = _measurementCtrls[type.id];
                if (ctrl == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Text(
                          type.localizedName,
                          style: TextStyle(
                            fontFamily: Fonts.gilroy,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: ctrl,
                          style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 14),
                          decoration: oInputDeco('0').copyWith(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorConstants.kPrimaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  String _formatDeadline(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      Get.snackbar(
        'error'.tr,
        'please_select_customer'.tr,
        backgroundColor: ColorConstants.redColor,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      // Update measurements that have changed
      final changedMeasurements = <Map<String, dynamic>>[];
      for (final type in _measurementTypes) {
        final ctrl = _measurementCtrls[type.id];
        if (ctrl == null) continue;
        final current = ctrl.text.trim();
        if (current != (_originalMeasurements[type.id] ?? '')) {
          changedMeasurements.add(<String, dynamic>{
            'name': type.localizedName,
            'value': current,
          });
        }
      }
      if (changedMeasurements.isNotEmpty) {
        print('📏 Updating ${changedMeasurements.length} measurements for client ${_selectedClient!.id}');
        await _clientService.updateClient(
          id: _selectedClient!.id,
          name: _selectedClient!.name,
          phone: _selectedClient!.phone,
          newMeasurements: changedMeasurements,
        );
        print('✅ Measurements updated');
      }

      if (_isEditMode) {
        print('💾 Updating order...');
        await widget.service.updateOrder(
          id: widget.order!.id,
          clientId: _selectedClient!.id,
          orderName: _orderNameCtrl.text.trim(),
          price: _priceCtrl.text.trim(),
          due: _dueCtrl.text.trim().isEmpty ? '0' : _dueCtrl.text.trim(),
          status: _status,
          image: _image,
        );
        // Save deadline locally on device
        DeadlineStorage.save(widget.order!.id, _deadline);
        try {
          if (_deadline != null) {
            await LocalNotificationsService.instance().scheduleDeadlineNotifications(
              orderId: widget.order!.id,
              orderName: _orderNameCtrl.text.trim(),
              clientName: _selectedClient!.name,
              deadline: _deadline!,
            );
          } else {
            await LocalNotificationsService.instance().cancelDeadlineNotifications(widget.order!.id);
          }
        } catch (notifErr) {
          print('⚠️ Notification scheduling failed (order still saved): $notifErr');
        }
        print('✅ Order updated successfully!');
      } else {
        print('💾 Creating order...');
        print('💾 Client: ${_selectedClient!.id} - ${_selectedClient!.name}');
        print('💾 Order Name: ${_orderNameCtrl.text.trim()}');
        print('💾 Price: ${_priceCtrl.text.trim()}');
        print('💾 Due: ${_dueCtrl.text.trim()}');
        print('💾 Status: $_status');

        final newOrder = await widget.service.createOrder(
          clientId: _selectedClient!.id,
          orderName: _orderNameCtrl.text.trim(),
          price: _priceCtrl.text.trim(),
          due: _dueCtrl.text.trim().isEmpty ? '0' : _dueCtrl.text.trim(),
          status: _status,
          image: _image,
        );
        // Save deadline locally on device
        DeadlineStorage.save(newOrder.id, _deadline);
        try {
          if (_deadline != null) {
            await LocalNotificationsService.instance().scheduleDeadlineNotifications(
              orderId: newOrder.id,
              orderName: _orderNameCtrl.text.trim(),
              clientName: _selectedClient!.name,
              deadline: _deadline!,
            );
          }
        } catch (notifErr) {
          print('⚠️ Notification scheduling failed (order still saved): $notifErr');
        }
        print('✅ Order created successfully!');
      }

      Get.back<bool>(result: true);

      Get.snackbar(
        'success'.tr,
        _isEditMode ? 'order_updated'.tr : 'order_added'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Save Error: $e');
      if (mounted) {
        Get.snackbar(
          'error'.tr,
          'order_error'.tr,
          backgroundColor: ColorConstants.redColor,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _orderNameCtrl.dispose();
    _priceCtrl.dispose();
    _dueCtrl.dispose();
    for (final ctrl in _measurementCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Get.back<void>(),
          child: const Icon(IconlyLight.arrow_left_circle, color: Colors.black87),
        ),
        title: Text(
          _isEditMode ? 'edit_order'.tr : 'add_order'.tr,
          style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: <Widget>[
            // Client Selection
            OFormCard(
              children: <Widget>[
                OFormLabel('select_customer'.tr),
                const SizedBox(height: 12),
                if (_loadingClients)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: Color(0xFF3B79F6), strokeWidth: 2),
                    ),
                  )
                else if (_clients.isEmpty)
                  Text(
                    'no_customers_found'.tr,
                    style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 13, color: Colors.grey.shade500),
                  )
                else
                  DropdownButtonFormField<ClientModel>(
                    value: _selectedClient,
                    decoration: oInputDeco('select_customer'.tr),
                    items: _clients.map((client) {
                      return DropdownMenuItem<ClientModel>(
                        value: client,
                        child: Text(
                          '${client.name} (${client.phone})',
                          style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: _onClientChanged,
                    validator: (value) => value == null ? 'please_select_customer'.tr : null,
                  ),
              ],
            ),
            // Measurements (shown when a client is selected and types are loaded)
            if (_selectedClient != null && _measurementTypes.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              _buildMeasurementsSection(),
            ],
            const SizedBox(height: 14),
            // Order Name
            OFormCard(
              children: <Widget>[
                OFormLabel('order_name'.tr),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _orderNameCtrl,
                  style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 15),
                  decoration: oInputDeco('e.g. Dress, Suit'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'errorEmpty'.tr : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Status
            OFormCard(
              children: <Widget>[
                OFormLabel('select_status'.tr),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _statuses.map((s) {
                    final color = orderStatusColor(s);
                    final selected = s == _status;
                    String labelKey;
                    if (s == 'New Orders') {
                      labelKey = 'status_new';
                    } else if (s == 'In Progress') {
                      labelKey = 'status_in_progress';
                    } else if (s == 'Ready') {
                      labelKey = 'status_ready';
                    } else if (s == 'Completed') {
                      labelKey = 'status_completed';
                    } else {
                      labelKey = s;
                    }
                    return GestureDetector(
                      onTap: () => setState(() => _status = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? color : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          labelKey.tr,
                          style: TextStyle(
                            fontFamily: Fonts.gilroy,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : color,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Price & Due
            OFormCard(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          OFormLabel('price'.tr),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _priceCtrl,
                            style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 15),
                            decoration: oInputDeco('0.00'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'errorEmpty'.tr : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          OFormLabel('due'.tr),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _dueCtrl,
                            style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 15),
                            decoration: oInputDeco('0.00'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Deadline
            OFormCard(
              children: <Widget>[
                OFormLabel('deadline'.tr + ' (${'optional'.tr})'),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickDeadline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, size: 18, color: _deadline != null ? ColorConstants.kPrimaryColor : Colors.grey.shade400),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _deadline != null ? _formatDeadline(_deadline!) : 'select_deadline'.tr,
                            style: TextStyle(
                              fontFamily: Fonts.gilroy,
                              fontSize: 14,
                              color: _deadline != null ? Colors.black87 : Colors.grey.shade500,
                            ),
                          ),
                        ),
                        if (_deadline != null)
                          GestureDetector(
                            onTap: () => setState(() => _deadline = null),
                            child: Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade400),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Image
            OFormCard(
              children: <Widget>[
                OFormLabel('order_image'.tr + ' (${'optional'.tr})'),
                const SizedBox(height: 12),
                if (_image != null) ...<Widget>[
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ] else if (_isEditMode && widget.order?.image != null) ...<Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: widget.order!.image!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(color: Color(0xFF3B79F6)),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error_outline, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(
                    (_image == null && (!_isEditMode || widget.order?.image == null)) ? Icons.add_photo_alternate_outlined : Icons.edit,
                    size: 20,
                  ),
                  label: Text(
                    (_image == null && (!_isEditMode || widget.order?.image == null)) ? 'add_image'.tr : 'change_image'.tr,
                    style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey.shade300),
                    foregroundColor: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B79F6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'save'.tr,
                        style: TextStyle(
                          fontFamily: Fonts.gilroy,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
