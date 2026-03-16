import 'package:flutter/material.dart';

class GarmentRow {
  final int rank;
  final String name;
  final int orders;
  final double revenue;
  const GarmentRow({required this.rank, required this.name, required this.orders, required this.revenue});
}

class CustomerRow {
  final String name;
  final int orders;
  final double spent;
  const CustomerRow({required this.name, required this.orders, required this.spent});
}

class LineSeries {
  final List<double> values;
  final Color color;
  const LineSeries({required this.values, required this.color});
}

const monthLabels = ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
const profitData = [900.0, 1100.0, 1800.0, 1350.0, 1750.0, 750.0];
const incomeData = [1650.0, 2350.0, 3200.0, 2450.0, 2900.0, 1600.0];
const expenseData = [850.0, 1000.0, 1550.0, 950.0, 1050.0, 750.0];

const topGarments = [
  GarmentRow(rank: 1, name: 'Suit', orders: 3, revenue: 830),
  GarmentRow(rank: 2, name: 'Dress', orders: 3, revenue: 365),
  GarmentRow(rank: 3, name: 'Pants', orders: 2, revenue: 100),
];

const bestCustomers = [
  CustomerRow(name: 'David Ochieng', orders: 4, spent: 950),
  CustomerRow(name: 'Amina Hassan', orders: 5, spent: 680),
  CustomerRow(name: 'John Mwangi', orders: 3, spent: 520),
];
