class OrderItem {
  final int id;
  final int client;
  final String clientName;
  final String orderName;
  final String status;
  final double price;
  final double due;
  final String created;
  final String? image;

  const OrderItem({
    required this.id,
    required this.client,
    required this.clientName,
    required this.orderName,
    required this.status,
    required this.price,
    required this.due,
    required this.created,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      client: json['client'] as int,
      clientName: json['client_name'] as String? ?? '',
      orderName: json['order_name'] as String? ?? '',
      status: json['status'] as String? ?? 'new',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      due: double.tryParse(json['due']?.toString() ?? '0') ?? 0.0,
      created: json['created'] as String? ?? '',
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'client': client,
      'client_name': clientName,
      'order_name': orderName,
      'status': status,
      'price': price.toString(),
      'due': due.toString(),
      'created': created,
      'image': image,
    };
  }
}

const allOrders = <OrderItem>[];
