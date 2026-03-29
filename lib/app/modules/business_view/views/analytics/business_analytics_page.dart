import 'dart:math' as math;

import 'package:atelyam/app/modules/business_view/views/analytics/controllers/analytics_controller.dart';
import 'package:atelyam/app/modules/business_view/views/analytics/models/analytics_data.dart';
import 'package:atelyam/app/modules/business_view/views/business_currency_controller.dart';
import 'package:atelyam/app/product/theme/color_constants.dart';
import 'package:atelyam/app/product/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BusinessAnalyticsPage extends StatelessWidget {
  const BusinessAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalyticsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error.value.isNotEmpty && controller.analyticsData.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: ColorConstants.redColor),
                  const SizedBox(height: 12),
                  Text(
                    'analytics_load_failed'.tr,
                    style: TextStyle(fontFamily: Fonts.gilroy, fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: controller.loadAnalyticsData,
                    icon: const Icon(Icons.refresh),
                    label: Text('retry'.tr),
                    style: ElevatedButton.styleFrom(backgroundColor: ColorConstants.kPrimaryColor),
                  ),
                ],
              ),
            );
          }

          final data = controller.analyticsData.value;
          if (data == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'analytics'.tr,
                    style: TextStyle(
                      fontFamily: Fonts.gilroy,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _MonthlyProfitChart(chartData: data.chartData),
                  const SizedBox(height: 16),
                  _IncomeExpenseLineChart(chartData: data.chartData),
                  const SizedBox(height: 16),
                  _BestCustomersList(customers: data.bestCustomers),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MonthlyProfitChart extends StatelessWidget {
  final List<ChartPoint> chartData;
  const _MonthlyProfitChart({required this.chartData});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'monthly_profit'.tr,
      icon: Icons.trending_up_rounded,
      iconColor: const Color(0xFF2563EB),
      child: Column(
        children: [
          SizedBox(
            height: 212,
            width: double.infinity,
            child: CustomPaint(
              painter: _BarChartPainter(points: chartData),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: const Color(0xFF22C55E), label: 'income'.tr),
              const SizedBox(width: 20),
              _LegendDot(color: const Color(0xFFE23A3D), label: 'expenses'.tr),
              const SizedBox(width: 20),
              _LegendDot(color: const Color(0xFF2B6FDE), label: 'profit'.tr),
            ],
          ),
        ],
      ),
    );
  }
}

class _IncomeExpenseLineChart extends StatelessWidget {
  final List<ChartPoint> chartData;
  const _IncomeExpenseLineChart({required this.chartData});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'income_vs_expenses'.tr,
      child: Column(
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _LineChartPainter(points: chartData),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: Colors.green, label: 'income'.tr),
              const SizedBox(width: 28),
              _LegendDot(color: Colors.red, label: 'expenses'.tr),
            ],
          ),
        ],
      ),
    );
  }
}

class _BestCustomersList extends StatelessWidget {
  final List<BestCustomer> customers;
  const _BestCustomersList({required this.customers});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'best_customers'.tr,
      icon: Icons.workspace_premium_outlined,
      iconColor: const Color(0xFF2D79FF),
      child: Column(
        children: customers.asMap().entries.map((entry) {
          final i = entry.key;
          final customer = entry.value;
          return Column(
            children: [
              if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
              _CustomerTile(customer: customer),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final Color? iconColor;

  const _SectionCard({
    required this.title,
    required this.child,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: iconColor ?? Colors.black54),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: Fonts.gilroy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final BestCustomer customer;
  const _CustomerTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    final avatarBg = customer.initial.toUpperCase() == 'D' ? const Color(0xFF2D79FF) : const Color(0xFFE9EEF5);
    final avatarText = customer.initial.toUpperCase() == 'D' ? Colors.white : const Color(0xFF374151);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarBg,
            child: Text(
              customer.initial.isEmpty ? '?' : customer.initial[0].toUpperCase(),
              style: TextStyle(
                fontFamily: Fonts.gilroy,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: avatarText,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: TextStyle(
                    fontFamily: Fonts.gilroy,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${customer.orders} ${'orders'.tr}',
                  style: TextStyle(
                    fontFamily: Fonts.gilroy,
                    fontSize: 13,
                    color: const Color(0xFF8A97A8),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final currency = Get.find<BusinessCurrencyController>().currency.value;
            return Text(
              currency.format(customer.spent),
              style: TextStyle(
                fontFamily: Fonts.gilroy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13,
          height: 13,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontFamily: Fonts.gilroy,
            fontSize: 14,
            color: const Color(0xFF8A97A8),
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ChartPoint> points;
  const _BarChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const leftPad = 50.0;
    const rightPad = 8.0;
    const topPad = 6.0;
    const bottomPad = 28.0;
    final width = size.width - leftPad - rightPad;
    final height = size.height - topPad - bottomPad;

    // max across income, expenses and abs(profit)
    final rawMax = points.fold<double>(1, (p, e) => math.max(p, math.max(e.income, math.max(e.expenses, e.profit.abs()))));
    final rawMin = points.fold<double>(0, (p, e) => math.min(p, e.profit));
    final minVal = rawMin < 0 ? -_niceMax(rawMin.abs()) : 0.0;
    final maxVal = _niceMax(rawMax);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);
    final zeroY = topPad + (maxVal / range) * height;
    const stepCount = 4;

    final axisPaint = Paint()
      ..color = const Color(0xFF8B96A7)
      ..strokeWidth = 1;

    final gridPaint = Paint()
      ..color = const Color(0xFFD7DFEA)
      ..strokeWidth = 1;

    final labelStyle = TextStyle(
      fontFamily: Fonts.gilroy,
      fontSize: 11,
      color: const Color(0xFF8A97A8),
    );

    for (int i = 0; i <= stepCount; i++) {
      final value = minVal + (range * i / stepCount);
      final y = topPad + ((maxVal - value) / range) * height;
      _drawDashedLine(canvas, Offset(leftPad, y), Offset(leftPad + width, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: '${value.round()}', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 7, y - tp.height / 2));
    }

    canvas.drawLine(Offset(leftPad, topPad), Offset(leftPad, topPad + height), axisPaint);
    canvas.drawLine(Offset(leftPad, topPad + height), Offset(leftPad + width, topPad + height), axisPaint);

    // 3 bars per slot: income, expenses, profit
    const barColors = [
      Color(0xFF22C55E), // income – green
      Color(0xFFE23A3D), // expenses – red
      Color(0xFF2B6FDE), // profit – blue
    ];

    final slotW = width / points.length;
    const barCount = 3;
    const gapRatio = 0.08; // gap between bars as fraction of slotW
    final totalGap = slotW * gapRatio * (barCount + 1);
    final barW = (slotW - totalGap) / barCount;

    void drawBar(double x, double value, Color color) {
      final targetY = topPad + ((maxVal - value) / range) * height;
      final y = math.min(zeroY, targetY);
      final barH = (zeroY - targetY).abs().clamp(1.0, height);
      final isNeg = value < 0;
      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barW, barH),
        topLeft: isNeg ? Radius.zero : const Radius.circular(5),
        topRight: isNeg ? Radius.zero : const Radius.circular(5),
        bottomLeft: isNeg ? const Radius.circular(5) : Radius.zero,
        bottomRight: isNeg ? const Radius.circular(5) : Radius.zero,
      );
      canvas.drawRRect(rrect, Paint()..color = color);
    }

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final slotX = leftPad + i * slotW;
      final values = [pt.income, pt.expenses, pt.profit];

      for (int b = 0; b < barCount; b++) {
        final x = slotX + slotW * gapRatio * (b + 1) + barW * b;
        drawBar(x, values[b], barColors[b]);
      }

      // X label centred under group
      final lp = TextPainter(
        text: TextSpan(text: pt.month, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      lp.paint(canvas, Offset(slotX + (slotW - lp.width) / 2, topPad + height + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => oldDelegate.points != points;
}

class _LineChartPainter extends CustomPainter {
  final List<ChartPoint> points;
  const _LineChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const leftPad = 50.0;
    const rightPad = 8.0;
    const topPad = 6.0;
    const bottomPad = 30.0;
    final width = size.width - leftPad - rightPad;
    final height = size.height - topPad - bottomPad;

    final maxVal = _niceMax(points.fold<double>(1, (p, e) => math.max(p, math.max(e.income, e.expenses))));
    const steps = 4;

    final axisPaint = Paint()
      ..color = const Color(0xFF8B96A7)
      ..strokeWidth = 1;

    final gridPaint = Paint()
      ..color = const Color(0xFFD7DFEA)
      ..strokeWidth = 1;

    final labelStyle = TextStyle(
      fontFamily: Fonts.gilroy,
      fontSize: 11,
      color: const Color(0xFF8A97A8),
    );

    for (int i = 0; i <= steps; i++) {
      final y = topPad + height - (i / steps) * height;
      final value = (maxVal * i / steps).round();
      _drawDashedLine(canvas, Offset(leftPad, y), Offset(leftPad + width, y), gridPaint);

      final tp = TextPainter(
        text: TextSpan(text: '$value', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftPad - tp.width - 7, y - tp.height / 2));
    }

    final n = points.length;
    final slotW = n == 1 ? 0.0 : width / (n - 1);

    for (int i = 0; i < n; i++) {
      final x = leftPad + i * slotW;
      _drawDashedLine(canvas, Offset(x, topPad), Offset(x, topPad + height), gridPaint);

      final tp = TextPainter(
        text: TextSpan(text: points[i].month, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, topPad + height + 5));
    }

    canvas.drawLine(Offset(leftPad, topPad + height), Offset(leftPad + width, topPad + height), axisPaint);
    canvas.drawLine(Offset(leftPad, topPad), Offset(leftPad, topPad + height), axisPaint);

    Offset pointOffset(int i, double value) {
      final x = leftPad + i * slotW;
      final y = topPad + height - (value.clamp(0, maxVal) / maxVal) * height;
      return Offset(x, y);
    }

    _drawSmoothSeries(
      canvas,
      points.map((e) => e.expenses).toList(),
      pointOffset,
      const Color(0xFFE23A3D),
    );

    _drawSmoothSeries(
      canvas,
      points.map((e) => e.income).toList(),
      pointOffset,
      Colors.green,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => oldDelegate.points != points;
}

void _drawSmoothSeries(
  Canvas canvas,
  List<double> values,
  Offset Function(int i, double value) pointOffset,
  Color color,
) {
  final path = Path();
  final first = pointOffset(0, values.first);
  path.moveTo(first.dx, first.dy);

  for (int i = 0; i < values.length - 1; i++) {
    final p0 = pointOffset(i, values[i]);
    final p1 = pointOffset(i + 1, values[i + 1]);
    final cpX = (p0.dx + p1.dx) / 2;
    path.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
  }

  final linePaint = Paint()
    ..color = color
    ..strokeWidth = 2.6
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  canvas.drawPath(path, linePaint);

  final dotFill = Paint()..color = Colors.white;
  final dotStroke = Paint()
    ..color = color
    ..strokeWidth = 2.4
    ..style = PaintingStyle.stroke;

  for (int i = 0; i < values.length; i++) {
    final o = pointOffset(i, values[i]);
    canvas.drawCircle(o, 4.3, dotFill);
    canvas.drawCircle(o, 4.3, dotStroke);
  }
}

void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
  const dashWidth = 5.0;
  const dashSpace = 4.0;
  final totalLength = (to - from).distance;
  if (totalLength == 0) return;
  final direction = (to - from) / totalLength;
  double distance = 0;

  while (distance < totalLength) {
    final start = from + direction * distance;
    final end = from + direction * math.min(distance + dashWidth, totalLength);
    canvas.drawLine(start, end, paint);
    distance += dashWidth + dashSpace;
  }
}

double _niceMax(double val) {
  if (val <= 0) return 100;
  final magnitude = math.pow(10, (math.log(val) / math.ln10).floor()).toDouble();
  final normalized = val / magnitude;
  final nice = normalized <= 1
      ? 1
      : normalized <= 2
          ? 2
          : normalized <= 5
              ? 5
              : 10;
  return nice * magnitude;
}
