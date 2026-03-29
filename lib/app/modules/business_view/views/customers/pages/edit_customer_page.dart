import 'dart:math' as math;

import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/client_measurement.dart';
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
      print('   - [typeId=${m.typeId}] ${m.label}: ${m.value}');
    }
    _loadMeasurementTypes();
  }

  Future<void> _loadMeasurementTypes() async {
    try {
      final types = await widget.service.fetchMeasurementTypes();
      if (!mounted) return;
      setState(() {
        _measurementTypes = types;
        final Set<int> matchedMeasurementTypeIds = <int>{};
        final Set<int> usedMeasurementTypeIds = <int>{};
        for (final type in types) {
          // 1. TypeId ile eşleştir (en güvenilir)
          ClientMeasurement? existingMeasurement = widget.client.measurements.firstWhereOrNull(
            (m) => m.typeId != null && m.typeId == type.id,
          );

          // 2. Exact label eşleşmesi (tüm dil varyantları)
          existingMeasurement ??= widget.client.measurements.firstWhereOrNull((m) {
            final mLabel = m.label.toLowerCase().trim();
            return mLabel == type.name.toLowerCase().trim() ||
                (type.nameEn?.toLowerCase().trim() == mLabel) ||
                (type.nameRu?.toLowerCase().trim() == mLabel) ||
                (type.nameCh?.toLowerCase().trim() == mLabel) ||
                (type.nameUz?.toLowerCase().trim() == mLabel) ||
                (type.nameTr?.toLowerCase().trim() == mLabel);
          });

          // 2.5. Normalize label fallback (apostrophe, accents, translation variants, etc.)
          // If typeId match is empty, prefer a translated/normalized match that has value.
          if (existingMeasurement == null || existingMeasurement.value.trim().isEmpty) {
            String normalize(String s) => s
                .toLowerCase()
                .replaceAll(RegExp(r"['‘’`]"), "")
                .replaceAll('o‘', 'o')
                .replaceAll('o’', 'o')
                .replaceAll("ý", "y")
                .replaceAll("ö", "o")
                .replaceAll("ä", "a")
                .replaceAll("ü", "u")
                .replaceAll("ş", "s")
                .replaceAll("ç", "c")
                .replaceAll("ğ", "g")
                .replaceAll('uzunligi', 'uzynlygy')
                .replaceAll('kokrak', 'dos');
            final normTypeNames = [
              type.name,
              type.nameEn ?? '',
              type.nameRu ?? '',
              type.nameCh ?? '',
              type.nameUz ?? '',
              type.nameTr ?? '',
            ].map(normalize).toSet();
            final normalizedMatch = widget.client.measurements.firstWhereOrNull((m) {
              if (m.value.trim().isEmpty) return false;
              if (m.typeId != null && usedMeasurementTypeIds.contains(m.typeId)) return false;
              final mLabel = normalize(m.label);
              return normTypeNames.contains(mLabel);
            });
            if (normalizedMatch != null) {
              existingMeasurement = normalizedMatch;
            }
          }

          // 3. Fuzzy contains: "Egin" type isminde geçiyorsa eşleş
          existingMeasurement ??= widget.client.measurements.firstWhereOrNull((m) {
            final mLabel = m.label.toLowerCase().trim();
            if (mLabel.isEmpty) return false;
            final typeNames = [
              type.name,
              type.nameEn ?? '',
              type.nameRu ?? '',
              type.nameCh ?? '',
              type.nameUz ?? '',
              type.nameTr ?? '',
            ].map((n) => n.toLowerCase().trim()).where((n) => n.isNotEmpty);
            return typeNames.any((n) => n.contains(mLabel) || mLabel.contains(n));
          });

          // 4. Levenshtein similarity matching (>= 65% similarity)
          if (existingMeasurement == null || existingMeasurement.value.trim().isEmpty) {
            String norm(String s) => s
                .toLowerCase()
                .replaceAll(RegExp(r"['\u2018\u2019\u0060]"), '')
                .replaceAll('\u00fd', 'y')
                .replaceAll('\u00f6', 'o')
                .replaceAll('\u00e4', 'a')
                .replaceAll('\u00fc', 'u')
                .replaceAll('\u015f', 's')
                .replaceAll('\u00e7', 'c')
                .replaceAll('\u011f', 'g')
                .replaceAll('uzunligi', 'uzynlygy')
                .replaceAll('kokrak', 'dos')
                .trim();
            final typeNames = [
              type.name,
              type.nameEn ?? '',
              type.nameRu ?? '',
              type.nameCh ?? '',
              type.nameUz ?? '',
              type.nameTr ?? '',
            ].map(norm).where((n) => n.isNotEmpty).toList();
            double bestScore = 0.65;
            ClientMeasurement? bestMatch;
            for (final m in widget.client.measurements) {
              if (m.value.trim().isEmpty) continue;
              if (m.typeId != null && usedMeasurementTypeIds.contains(m.typeId)) continue;
              final mNorm = norm(m.label);
              if (mNorm.isEmpty) continue;
              for (final tn in typeNames) {
                final maxLen = math.max(mNorm.length, tn.length);
                if (maxLen == 0) continue;
                final dist = _levenshtein(mNorm, tn);
                final score = 1.0 - dist / maxLen;
                if (score > bestScore) {
                  bestScore = score;
                  bestMatch = m;
                }
              }
            }
            if (bestMatch != null) {
              existingMeasurement = bestMatch;
              print('   🔤 FUZZY MATCH (score=${bestScore.toStringAsFixed(2)}): type="${type.name}" ← label="${bestMatch.label}" value="${bestMatch.value}"');
            }
          }

          if (existingMeasurement != null && existingMeasurement.typeId != null) {
            matchedMeasurementTypeIds.add(existingMeasurement.typeId!);
            if (existingMeasurement.value.trim().isNotEmpty) {
              usedMeasurementTypeIds.add(existingMeasurement.typeId!);
            }
          }

          // Mevcut değeri veya boş string ile doldur
          final prefillValue = existingMeasurement?.value ?? '';
          _newMeasurementCtrls[type.id] = TextEditingController(text: prefillValue);
          if (prefillValue.isNotEmpty) {
            print('   ✅ MATCH: type="${type.name}" ← label="${existingMeasurement?.label}" value="$prefillValue"');
          }
        }

        // Eşleşemeyen ama VALUE olan ölçümleri, synthetic type olarak listeye ekle
        for (final m in widget.client.measurements) {
          if (m.value.trim().isEmpty) continue;
          if (m.typeId == null) continue;
          if (matchedMeasurementTypeIds.contains(m.typeId)) continue;
          // Bu typeId zaten standart listede var mı?
          if (_measurementTypes.any((t) => t.id == m.typeId)) continue;
          // Synthetic MeasurementType olarak ekle
          final syntheticType = MeasurementType(id: m.typeId!, name: m.label);
          _measurementTypes = List<MeasurementType>.from(_measurementTypes)..add(syntheticType);
          _newMeasurementCtrls[m.typeId!] = TextEditingController(text: m.value);
          matchedMeasurementTypeIds.add(m.typeId!);
          print('   ➕ SYNTHETIC TYPE ADDED: id=${m.typeId} label="${m.label}" value="${m.value}"');
        }

        _loadingMeasurements = false;
      });
      print('📝 Loaded ${types.length} measurement types for editing');
      print('📝 UI will show ${_measurementTypes.length} measurement inputs total');
      print('📝 Pre-filled: ${_newMeasurementCtrls.values.where((c) => c.text.isNotEmpty).length} inputs have values');
    } catch (e) {
      print('❌ Failed to load measurement types: $e');
      if (!mounted) return;
      setState(() {
        _measurementTypes = <MeasurementType>[];
        _loadingMeasurements = false;
      });
    }
  }

  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    final matrix = List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));
    for (int i = 0; i <= a.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= b.length; j++) matrix[0][j] = j;
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost].reduce(math.min);
      }
    }
    return matrix[a.length][b.length];
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
