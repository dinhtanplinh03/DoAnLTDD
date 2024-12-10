import 'package:flutter/material.dart';

class TransactionListScreen extends StatelessWidget {
  final List<Map<String, String>> transactions = [
    {'date': '10/12/2024', 'category': 'Ăn uống', 'amount': '100,000'},
    {'date': '09/12/2024', 'category': 'Đi lại', 'amount': '50,000'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          title: Text('${transaction['category']} - ${transaction['amount']} VND'),
          subtitle: Text('Ngày: ${transaction['date']}'),
        );
      },
    );
  }
}
