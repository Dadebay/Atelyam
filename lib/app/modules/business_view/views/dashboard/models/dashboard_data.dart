class DashboardData {
  final DashboardCards cards;
  final DashboardFinancials financials;
  final List<DashboardOrder> recentOrders;

  DashboardData({
    required this.cards,
    required this.financials,
    required this.recentOrders,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      cards: DashboardCards.fromJson(json['cards'] ?? {}),
      financials: DashboardFinancials.fromJson(json['financials'] ?? {}),
      recentOrders: (json['recent_orders'] as List<dynamic>?)?.map((e) => DashboardOrder.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}

class DashboardCards {
  final int newOrders;
  final int inProgress;
  final int ready;
  final int completed;

  DashboardCards({
    required this.newOrders,
    required this.inProgress,
    required this.ready,
    required this.completed,
  });

  factory DashboardCards.fromJson(Map<String, dynamic> json) {
    return DashboardCards(
      newOrders: json['new_orders'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      ready: json['ready'] ?? 0,
      completed: json['completed'] ?? 0,
    );
  }
}

class DashboardFinancials {
  final double today;
  final double thisMonth;
  final double outstanding;

  DashboardFinancials({
    required this.today,
    required this.thisMonth,
    required this.outstanding,
  });

  factory DashboardFinancials.fromJson(Map<String, dynamic> json) {
    return DashboardFinancials(
      today: (json['today'] ?? 0).toDouble(),
      thisMonth: (json['this_month'] ?? 0).toDouble(),
      outstanding: (json['outstanding'] ?? 0).toDouble(),
    );
  }
}

class DashboardOrder {
  final int id;
  final int client;
  final String clientName;
  final String orderName;
  final String status;
  final double price;
  final double due;
  final String date;
  final DateTime? deadline;

  DashboardOrder({
    required this.id,
    required this.client,
    required this.clientName,
    required this.orderName,
    required this.status,
    required this.price,
    required this.due,
    required this.date,
    this.deadline,
  });

  DashboardOrder copyWith({
    int? id,
    int? client,
    DateTime? deadline,
  }) =>
      DashboardOrder(
        id: id ?? this.id,
        client: client ?? this.client,
        clientName: clientName,
        orderName: orderName,
        status: status,
        price: price,
        due: due,
        date: date,
        deadline: deadline ?? this.deadline,
      );

  DashboardOrder withDeadline(DateTime dl) => copyWith(deadline: dl);

  factory DashboardOrder.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    print('📊 DashboardOrder parsed: id=$id, client=${json['client_name']}');
    return DashboardOrder(
      id: id,
      client: json['client'] as int? ?? 0,
      clientName: json['client_name'] ?? '',
      orderName: json['order_name'] ?? '',
      status: json['status'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      due: (json['due'] ?? 0).toDouble(),
      date: json['date'] ?? '',
    );
  }
}
