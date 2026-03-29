class ExpenseModel {
  final int id;
  final String title;
  final String category;
  final double amount;
  final String date;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    print('🔍 ExpenseModel.fromJson keys: ${json.keys.toList()}');
    print('🔍 ExpenseModel.fromJson id field: ${json['id']} (type: ${json['id'].runtimeType})');
    return ExpenseModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'category': category,
      'amount': amount.toString(),
      'date': date,
    };
  }
}
