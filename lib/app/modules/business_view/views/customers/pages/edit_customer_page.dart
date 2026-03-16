import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/client_model.dart';
import '../models/measurement_type.dart';
import '../services/client_service.dart';
import '../widgets/form_widgets.dart';

class EditCustomerPage extends StatefulWidget {
  final ClientModel client;
  final ClientService service;

  const EditCustomerPage({
    super.key,
    required this.client,
    required this.service,
  });

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  List<MeasurementType> _measurementTypes = <MeasurementType>[];
  final Map<int, TextEditingController> _newMeasurementCtrls = <int, TextEditingController>{};
  bool _loadingMeasurements = true;
  bool _saving = false;
  late String _countryCode;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.client.name);

    // Parse phone number to extract country code
    String phoneNumber = widget.client.phone;
    if (phoneNumber.startsWith('+998')) {
      _countryCode = '+998';
      _phoneCtrl = TextEditingController(text: phoneNumber.substring(4));
    } else if (phoneNumber.startsWith('+993')) {
      _countryCode = '+993';
      _phoneCtrl = TextEditingController(text: phoneNumber.substring(4));
    } else {
      _countryCode = '+993';
      _phoneCtrl = TextEditingController(text: phoneNumber.replaceAll('+', ''));
    }

    print('📝 Edit Customer Init - ID: ${widget.client.id}, Name: ${widget.client.name}, Phone: ${widget.client.phone}');
    print('📝 Existing Measurements: ${widget.client.measurements.length}');
    for (final m in widget.client.measurements) {
      print('   - ${m.label}: ${m.value}');
    }
    _loadMeasurementTypes();
  }

  Future<void> _loadMeasurementTypes() async {
    try {
      final types = await widget.service.fetchMeasurementTypes();
      if (!mounted) return;
      setState(() {
        _measurementTypes = types;
        for (final type in types) {
          // Check if existing measurement matches this type
          final existingMeasurement = widget.client.measurements.firstWhereOrNull(
            (m) => m.label.toLowerCase() == type.name.toLowerCase(),
          );

          // Pre-fill with existing value or empty
          _newMeasurementCtrls[type.id] = TextEditingController(
            text: existingMeasurement?.value ?? '',
          );
        }
        _loadingMeasurements = false;
      });
      print('📝 Loaded ${types.length} measurement types for editing');
      print('📝 Pre-filled ${widget.client.measurements.length} existing measurements');
    } catch (e) {
      print('❌ Failed to load measurement types: $e');
      if (!mounted) return;
      setState(() {
        _measurementTypes = <MeasurementType>[];
        _loadingMeasurements = false;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    for (final controller in _newMeasurementCtrls.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      final List<Map<String, dynamic>> newMeasurements = _newMeasurementCtrls.entries.where((entry) => entry.value.text.trim().isNotEmpty).map((entry) {
        final measurementType = _measurementTypes.firstWhere((type) => type.id == entry.key);
        return <String, dynamic>{
          'name': measurementType.localizedName,
          'value': entry.value.text.trim(),
        };
      }).toList();

      print('💾 Saving customer update...');
      print('💾 Client ID: ${widget.client.id}');
      print('💾 Name: ${_nameCtrl.text.trim()}');
      print('💾 Country Code: $_countryCode');
      print('💾 Phone: ${_phoneCtrl.text.trim()}');
      print('💾 Full Phone: $_countryCode${_phoneCtrl.text.trim()}');
      print('💾 New Measurements: ${newMeasurements.length}');
      for (final m in newMeasurements) {
        print('   - ${m['name']}: ${m['value']}');
      }

      await widget.service.updateClient(
        id: widget.client.id,
        name: _nameCtrl.text.trim(),
        phone: '$_countryCode${_phoneCtrl.text.trim()}',
        newMeasurements: newMeasurements.isNotEmpty ? newMeasurements : null,
      );

      print('✅ Client updated successfully!');
      print('📱 Widget mounted: $mounted');
      print('🔙 Calling Get.back...');

      Get.back<bool>(result: true);

      print('🔙 Get.back called');

      // Show success message after navigation
      Get.snackbar(
        'success'.tr,
        'client_updated'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Update Error: $e');
      print('❌ Error Type: ${e.runtimeType}');
      if (mounted) {
        Get.snackbar(
          'error'.tr,
          'client_error'.tr,
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
          'edit_customer'.tr,
          style: TextStyle(
            fontFamily: Fonts.gilroy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: <Widget>[
            // Name
            CFormCard(
              children: <Widget>[
                CFormLabel('customer_name'.tr),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 15),
                  decoration: cInputDeco('customer_name'.tr),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'errorEmpty'.tr : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Phone
            CFormCard(
              children: <Widget>[
                CFormLabel('phone_number'.tr),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _countryCode = _countryCode == '+993' ? '+998' : '+993';
                        });
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F6FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              _countryCode == '+993' ? '🇹🇲' : '🇺🇿',
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _countryCode,
                              style: TextStyle(
                                fontFamily: Fonts.gilroy,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneCtrl,
                        style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 15),
                        decoration: cInputDeco(_countryCode == '+993' ? '65 123456' : '90 123 45 67'),
                        keyboardType: TextInputType.phone,
                        maxLength: _countryCode == '+993' ? 8 : 9,
                        buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Measurements
            CFormCard(
              children: <Widget>[
                CFormLabel('saved_measurements'.tr),
                if (_loadingMeasurements) ...<Widget>[
                  const SizedBox(height: 12),
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3B79F6),
                      strokeWidth: 2,
                    ),
                  ),
                ] else if (_measurementTypes.isEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    'no_measurements_defined'.tr,
                    style: TextStyle(
                      fontFamily: Fonts.gilroy,
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ] else ...<Widget>[
                  const SizedBox(height: 12),
                  ..._measurementTypes.map((type) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 110,
                            child: Text(
                              type.localizedName,
                              style: TextStyle(
                                fontFamily: Fonts.gilroy,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _newMeasurementCtrls[type.id],
                              style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 14),
                              decoration: cInputDeco('measurement_value'.tr),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
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
