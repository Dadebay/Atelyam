import 'expense_model.dart';

class FinanceData {
  final double income;
  final double expenses;
  final double netProfit;
  final double outstanding;
  final List<ExpenseModel> recentExpenses;

  const FinanceData({
    required this.income,
    required this.expenses,
    required this.netProfit,
    required this.outstanding,
    required this.recentExpenses,
  });

  factory FinanceData.fromJson(Map<String, dynamic> json) {
    final expensesList = json['recent_expenses'] as List<dynamic>? ?? [];
    final expenses = expensesList.map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList();

    return FinanceData(
      income: double.tryParse(json['income']?.toString() ?? '0') ?? 0.0,
      expenses: double.tryParse(json['expenses']?.toString() ?? '0') ?? 0.0,
      netProfit: double.tryParse(json['net_profit']?.toString() ?? '0') ?? 0.0,
      outstanding: double.tryParse(json['outstanding']?.toString() ?? '0') ?? 0.0,
      recentExpenses: expenses,
    );
  }
}
