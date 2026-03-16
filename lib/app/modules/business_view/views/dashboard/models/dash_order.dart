class DashOrder {
  final String customer;
  final String item;
  final String status;
  final double price;
  final double due;
  final String date;

  const DashOrder({
    required this.customer,
    required this.item,
    required this.status,
    required this.price,
    required this.due,
    required this.date,
  });
}

const recentOrders = [
  DashOrder(customer: 'Amina Hassan', item: 'Dress', status: 'In Progress', price: 120, due: 60, date: 'Mar 7'),
  DashOrder(customer: 'John Mwangi', item: 'Suit', status: 'Ready', price: 250, due: 0, date: 'Mar 5'),
  DashOrder(customer: 'Grace Wanjiku', item: 'Pants', status: 'New', price: 45, due: 25, date: 'Mar 10'),
  DashOrder(customer: 'David Ochieng', item: 'Suit', status: 'In Progress', price: 280, due: 140, date: 'Mar 8'),
];
