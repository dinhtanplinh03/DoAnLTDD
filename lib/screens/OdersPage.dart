import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đơn Hàng')),
      body: Center(child: Text('Danh sách đơn hàng')),
    );
  }
}