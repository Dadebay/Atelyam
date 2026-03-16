class ClientMeasurement {
  final int id;
  final String label;
  final String value;

  const ClientMeasurement({
    required this.id,
    required this.label,
    required this.value,
  });

  factory ClientMeasurement.fromJson(Map<String, dynamic> json) {
    final dynamic labelRaw = json['label'] ?? json['value_name'] ?? json['name'];
    final dynamic valueRaw = json['value'] ?? json['measurement'] ?? json['amount'];
    return ClientMeasurement(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: labelRaw?.toString() ?? '',
      value: valueRaw?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'value': value,
    };
  }
}
