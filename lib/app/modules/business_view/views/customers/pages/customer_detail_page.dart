import 'package:atelyam/app/modules/business_view/views/business_currency_controller.dart';
import 'package:atelyam/app/product/custom_widgets/index.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import '../models/client_model.dart';
import '../pages/edit_customer_page.dart';
import '../services/client_service.dart';

class CustomerDetailPage extends StatefulWidget {
  final ClientModel client;
  final ClientService service;
  final VoidCallback onChanged;

  const CustomerDetailPage({
    super.key,
    required this.client,
    required this.service,
    required this.onChanged,
  });

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  bool _measurementsExpanded = true;
  late ClientModel _client;

  ClientModel get client => _client;
  ClientService get service => widget.service;
  VoidCallback get onChanged => widget.onChanged;

  @override
  void initState() {
    super.initState();
    _client = widget.client;
  }

  Future<void> _refreshClient() async {
    try {
      final updated = await service.fetchClientById(_client.id);
      if (mounted) setState(() => _client = updated);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // Sadece gerçekten dolu olan ölçüleri al
    final filledMeasurements = client.measurements.where((m) {
      final v = m.value.trim().toLowerCase();
      return v.isNotEmpty && v != 'null' && v != '0' && v != '-';
    }).toList();

    // Print all filled measurements in detail
    for (final m in filledMeasurements) {
      print('[MEASUREMENT] typeId=${m.typeId} label="${m.label}" value="${m.value}"');
    }

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
          client.name,
          style: TextStyle(
            fontFamily: Fonts.gilroy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedPencilEdit01,
              color: const Color(0xFF3B79F6),
              size: 22,
            ),
            onPressed: () async {
              final updated = await Get.to<bool>(
                () => EditCustomerPage(client: client, service: service),
              );
              if (updated == true) {
                onChanged();
                await _refreshClient();
              }
            },
          ),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              color: ColorConstants.redColor,
              size: 22,
            ),
            onPressed: () => _showDeleteDialog(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Profil kartı ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  // Avatar
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: <Color>[Color(0xFF3B79F6), Color(0xFF5B92FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        client.initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          client.name,
                          style: TextStyle(
                            fontFamily: Fonts.gilroy,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        if (client.phone.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 4),
                          Row(
                            children: <Widget>[
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedCall,
                                color: Colors.grey.shade500,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                client.phone,
                                style: TextStyle(
                                  fontFamily: Fonts.gilroy,
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── İstatistik kartları ───────────────────────────────────
            Row(
              children: <Widget>[
                Expanded(
                  child: _StatCard(
                    label: 'orders'.tr,
                    value: '${client.orderCount}',
                    icon: HugeIcons.strokeRoundedDocumentAttachment,
                    iconColor: const Color(0xFF3B79F6),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    final currency = Get.find<BusinessCurrencyController>().currency.value;
                    return _StatCard(
                      label: 'total_spent'.tr,
                      value: currency.format(client.totalSpend ?? 0),
                      icon: HugeIcons.strokeRoundedMoney01,
                      iconColor: Colors.green.shade600,
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    final currency = Get.find<BusinessCurrencyController>().currency.value;
                    return _StatCard(
                      label: 'outstanding'.tr,
                      value: currency.format(client.outstanding ?? 0),
                      icon: HugeIcons.strokeRoundedAlert01,
                      iconColor: (client.outstanding ?? 0) > 0 ? ColorConstants.redColor : Colors.grey.shade400,
                      valueColor: (client.outstanding ?? 0) > 0 ? ColorConstants.redColor : Colors.black,
                    );
                  }),
                ),
              ],
            ),

            // ── Ölçüler — sadece dolu olanlar, açılır/kapanır ────────
            if (filledMeasurements.isNotEmpty) ...<Widget>[
              const SizedBox(height: 24),

              // Başlık + toggle
              GestureDetector(
                onTap: () => setState(() => _measurementsExpanded = !_measurementsExpanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedRuler,
                        color: const Color(0xFF3B79F6),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'saved_measurements'.tr,
                          style: TextStyle(
                            fontFamily: Fonts.gilroy,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Kaç ölçü dolu
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B79F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${filledMeasurements.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3B79F6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Ok animasyonu
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
              ),

              // Açılır içerik
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                crossFadeState: _measurementsExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: filledMeasurements.asMap().entries.map((entry) {
                        final index = entry.key;
                        final measurement = entry.value;
                        final isLast = index == filledMeasurements.length - 1;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : Border(
                                    bottom: BorderSide(color: Colors.grey.shade100),
                                  ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  measurement.label,
                                  style: TextStyle(
                                    fontFamily: Fonts.gilroy,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B79F6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  measurement.value,
                                  style: TextStyle(
                                    fontFamily: Fonts.gilroy,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF3B79F6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                secondChild: const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: ColorConstants.redColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: ColorConstants.redColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'delete_customer'.tr,
                style: TextStyle(
                  fontFamily: Fonts.gilroy,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'confirm_delete_customer'.tr,
                style: TextStyle(
                  fontFamily: Fonts.gilroy,
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back<bool>(result: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'no'.tr,
                        style: TextStyle(
                          fontFamily: Fonts.gilroy,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back<bool>(result: true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: ColorConstants.redColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'yes'.tr,
                        style: TextStyle(
                          fontFamily: Fonts.gilroy,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmDelete != true) return;

    try {
      await service.deleteClient(client.id);
      Get.back<void>();
      Get.snackbar(
        'success'.tr,
        'client_deleted'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      onChanged();
    } catch (e) {
      print('❌ Delete Error: $e');
      Get.snackbar(
        'error'.tr,
        'client_error'.tr,
        backgroundColor: ColorConstants.redColor,
        colorText: Colors.white,
      );
    }
  }
}

// ── Küçük stat kartı ──────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          HugeIcon(icon: icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: Fonts.gilroy,
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: Fonts.gilroy,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
