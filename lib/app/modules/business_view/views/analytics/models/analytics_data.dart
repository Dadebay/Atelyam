class ChartPoint {
  final String month;
  final double income;
  final double expenses;
  final double profit;

  const ChartPoint({
    required this.month,
    required this.income,
    required this.expenses,
    required this.profit,
  });

  factory ChartPoint.fromJson(Map<String, dynamic> json) {
    return ChartPoint(
      month: json['month'] as String,
      income: (json['income'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
    );
  }
}

class TopGarment {
  final String name;
  final int orders;
  final double revenue;

  const TopGarment({
    required this.name,
    required this.orders,
    required this.revenue,
  });

  factory TopGarment.fromJson(Map<String, dynamic> json) {
    return TopGarment(
      name: json['name'] as String,
      orders: (json['orders'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
    );
  }
}

class BestCustomer {
  final int id;
  final String initial;
  final String name;
  final int orders;
  final double spent;

  const BestCustomer({
    required this.id,
    required this.initial,
    required this.name,
    required this.orders,
    required this.spent,
  });

  factory BestCustomer.fromJson(Map<String, dynamic> json) {
    return BestCustomer(
      id: (json['id'] as num).toInt(),
      initial: json['initial'] as String,
      name: json['name'] as String,
      orders: (json['orders'] as num).toInt(),
      spent: (json['spent'] as num).toDouble(),
    );
  }
}

class AnalyticsData {
  final List<ChartPoint> chartData;
  final List<TopGarment> topGarments;
  final List<BestCustomer> bestCustomers;

  const AnalyticsData({
    required this.chartData,
    required this.topGarments,
    required this.bestCustomers,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      chartData: (json['chart_data'] as List)
          .map((e) => ChartPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      topGarments: (json['top_garments'] as List)
          .map((e) => TopGarment.fromJson(e as Map<String, dynamic>))
          .toList(),
      bestCustomers: (json['best_customers'] as List)
          .map((e) => BestCustomer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
