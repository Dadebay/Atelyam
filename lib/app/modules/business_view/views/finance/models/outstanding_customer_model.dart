class OutstandingCustomer {
  final int id;
  final String name;
  final double outstanding;

  const OutstandingCustomer({
    required this.id,
    required this.name,
    required this.outstanding,
  });

  String get initial => name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';

  factory OutstandingCustomer.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['id'] ?? json['customer_id'] ?? json['customer'] ?? json['client'];
    final dynamic rawName = json['name'] ?? json['customer_name'] ?? json['client_name'] ?? json['full_name'] ?? json['customer'];
    final dynamic rawOutstanding = json['outstanding'] ?? json['outstanding_sum'] ?? json['outstanding_amount'] ?? json['total_due'] ?? json['due'] ?? json['amount'];

    return OutstandingCustomer(
      id: _parseInt(rawId),
      name: _parseName(rawName),
      outstanding: _parseFlexibleDouble(rawOutstanding),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _parseName(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

double _parseFlexibleDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) {
    var sanitized = value.trim();
    if (sanitized.isEmpty) return 0.0;

    sanitized = sanitized.replaceAll(RegExp(r'[^0-9,.-]'), '');
    final hasComma = sanitized.contains(',');
    final hasDot = sanitized.contains('.');

    if (hasComma && hasDot) {
      if (sanitized.lastIndexOf(',') > sanitized.lastIndexOf('.')) {
        sanitized = sanitized.replaceAll('.', '').replaceAll(',', '.');
      } else {
        sanitized = sanitized.replaceAll(',', '');
      }
    } else if (hasComma && !hasDot) {
      sanitized = sanitized.replaceAll(',', '.');
    }

    return double.tryParse(sanitized) ?? 0.0;
  }
  return 0.0;
}
