import 'client_measurement.dart';

class ClientModel {
  final int id;
  final int? categoryUser;
  final String name;
  final String phone;
  final double? outstanding;
  final double? totalSpend;
  final int orderCount;
  final String created;
  final List<ClientMeasurement> measurements;

  const ClientModel({
    required this.id,
    required this.categoryUser,
    required this.name,
    required this.phone,
    required this.outstanding,
    required this.totalSpend,
    required this.orderCount,
    required this.created,
    required this.measurements,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawMeasurements = (json['measurements'] as List<dynamic>?) ?? <dynamic>[];
    return ClientModel(
      id: (json['id'] as num).toInt(),
      categoryUser: (json['categoryuser'] as num?)?.toInt(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      outstanding: _toDouble(json['outstanding']),
      totalSpend: _toDouble(json['totalspend']),
      orderCount: (json['ordercount'] as num?)?.toInt() ?? 0,
      created: json['created']?.toString() ?? '',
      measurements: rawMeasurements.whereType<Map<String, dynamic>>().map(ClientMeasurement.fromJson).toList(),
    );
  }

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'categoryuser': categoryUser,
      'name': name,
      'phone': phone,
      'outstanding': outstanding,
      'totalspend': totalSpend,
      'ordercount': orderCount,
      'created': created,
      'measurements': measurements.map((m) => m.toJson()).toList(),
    };
  }
}
