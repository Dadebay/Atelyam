import 'package:atelyam/app/modules/business_view/views/orders/models/order_item.dart';
import 'package:atelyam/app/modules/business_view/views/orders/pages/add_order_page.dart';
import 'package:atelyam/app/modules/business_view/views/orders/services/deadline_storage.dart';
import 'package:atelyam/app/modules/business_view/views/orders/services/order_service.dart';
import 'package:atelyam/app/modules/business_view/views/orders/widgets/order_card.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class DeadlineNotificationsPage extends StatefulWidget {
  const DeadlineNotificationsPage({super.key});

  @override
  State<DeadlineNotificationsPage> createState() => _DeadlineNotificationsPageState();
}

class _DeadlineNotificationsPageState extends State<DeadlineNotificationsPage> {
  final OrderService _orderService = OrderService();
  List<_DeadlineEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderService.fetchOrders();
      final deadlines = DeadlineStorage.readAll(orders.map((o) => o.id).toList());

      final entries = orders
          .where((o) => deadlines.containsKey(o.id))
          .map((o) {
            final dl = deadlines[o.id]!;
            final now = DateTime.now();
            final daysLeft = dl.difference(DateTime(now.year, now.month, now.day)).inDays;
            return _DeadlineEntry(order: o, deadline: dl, daysLeft: daysLeft);
          })
          .toList()
        ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft)); // overdue first

      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                        ],
                      ),
                      child: const Icon(HugeIcons.strokeRoundedArrowLeft01, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'deadline'.tr,
                      style: TextStyle(
                        fontFamily: Fonts.gilroy,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // Badge — total count
                  if (_entries.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ColorConstants.kSecondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_entries.length}',
                        style: TextStyle(
                          fontFamily: Fonts.gilroy,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.kSecondaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: ColorConstants.kSecondaryColor))
                  : _entries.isEmpty
                      ? _EmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadEntries,
                          color: ColorConstants.kSecondaryColor,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: _entries.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final entry = _entries[i];
                              return _DeadlineCard(
                                entry: entry,
                                onTap: () async {
                                  final updated = await Get.to<bool>(
                                    () => AddOrderPage(
                                      service: _orderService,
                                      order: entry.order,
                                    ),
                                  );
                                  if (updated == true) await _loadEntries();
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────
class _DeadlineEntry {
  final OrderItem order;
  final DateTime deadline;
  final int daysLeft;
  const _DeadlineEntry({required this.order, required this.deadline, required this.daysLeft});
}

// ─── Deadline Card ─────────────────────────────────────────────────────────────
class _DeadlineCard extends StatelessWidget {
  final _DeadlineEntry entry;
  final VoidCallback onTap;
  const _DeadlineCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final days = entry.daysLeft;
    final Color accent;
    final String badgeText;
    final IconData badgeIcon;

    if (days < 0) {
      accent = const Color(0xFFE53935);
      badgeText = '${-days} ${'deadline_days_overdue'.tr}';
      badgeIcon = HugeIcons.strokeRoundedAlert02;
    } else if (days == 0) {
      accent = const Color(0xFFE53935);
      badgeText = 'deadline_today'.tr;
      badgeIcon = HugeIcons.strokeRoundedAlert02;
    } else if (days <= 3) {
      accent = const Color(0xFFF5A623);
      badgeText = '$days ${'deadline_days_left'.tr}';
      badgeIcon = HugeIcons.strokeRoundedClock01;
    } else {
      accent = const Color(0xFF27AE60);
      badgeText = '$days ${'deadline_days_left'.tr}';
      badgeIcon = HugeIcons.strokeRoundedClock01;
    }

    final statusColor = orderStatusColor(entry.order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(color: accent.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Colored urgency bar
            Container(
              width: 5,
              height: 56,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.order.clientName,
                          style: TextStyle(
                            fontFamily: Fonts.gilroy,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          getOrderStatusTranslation(entry.order.status),
                          style: TextStyle(
                            fontFamily: Fonts.gilroy,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.order.orderName,
                    style: TextStyle(
                      fontFamily: Fonts.gilroy,
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Deadline badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(badgeIcon, size: 13, color: accent),
                  const SizedBox(width: 4),
                  Text(
                    badgeText,
                    style: TextStyle(
                      fontFamily: Fonts.gilroy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              HugeIcons.strokeRoundedNotification01,
              size: 52,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'no_deadline'.tr,
            style: TextStyle(
              fontFamily: Fonts.gilroy,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
