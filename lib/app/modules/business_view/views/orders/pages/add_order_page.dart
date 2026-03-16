import 'dart:io';

import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../customers/models/client_model.dart';
import '../../customers/services/client_service.dart';
import '../models/order_item.dart';
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
  String _status = 'new';
  File? _image;

  static const _statuses = <String>['new', 'in progress', 'ready', 'completed'];

  bool get _isEditMode => widget.order != null;

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
    }
  }

  Future<void> _loadClients() async {
    try {
      final clients = await _clientService.fetchClients();
      if (!mounted) return;
      setState(() {
        _clients = clients;
        _loadingClients = false;
        // If in edit mode, select the client
        if (_isEditMode) {
          _selectedClient = clients.firstWhere(
            (c) => c.id == widget.order!.client,
            orElse: () => clients.first,
          );
        }
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
        print('✅ Order updated successfully!');
      } else {
        print('💾 Creating order...');
        print('💾 Client: ${_selectedClient!.id} - ${_selectedClient!.name}');
        print('💾 Order Name: ${_orderNameCtrl.text.trim()}');
        print('💾 Price: ${_priceCtrl.text.trim()}');
        print('💾 Due: ${_dueCtrl.text.trim()}');
        print('💾 Status: $_status');

        await widget.service.createOrder(
          clientId: _selectedClient!.id,
          orderName: _orderNameCtrl.text.trim(),
          price: _priceCtrl.text.trim(),
          due: _dueCtrl.text.trim().isEmpty ? '0' : _dueCtrl.text.trim(),
          status: _status,
          image: _image,
        );
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
                    onChanged: (value) {
                      setState(() {
                        _selectedClient = value;
                      });
                    },
                    validator: (value) => value == null ? 'please_select_customer'.tr : null,
                  ),
              ],
            ),
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
                    if (s == 'new') {
                      labelKey = 'status_new';
                    } else if (s == 'in progress') {
                      labelKey = 'status_in_progress';
                    } else if (s == 'ready') {
                      labelKey = 'status_ready';
                    } else if (s == 'completed') {
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
