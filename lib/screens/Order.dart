import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int? userId;

  // Method to get the userId from SharedPreferences
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  @override
  void initState() {
    super.initState();
    // Fetch the userId when the page is initialized
    getUserId().then((id) {
      setState(() {
        userId = id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Page'),
      ),
      body: Center(
        child: userId == null
            ? CircularProgressIndicator()  // Show loading indicator while fetching userId
            : FutureBuilder(
          future: _fetchOrders(userId!),  // Fetch orders based on the userId
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No orders found');
            } else {
              var orders = snapshot.data;
              return ListView.builder(
                itemCount: orders?.length,
                itemBuilder: (context, index) {
                  // Customize how you display each order item
                  return ListTile(
                    title: Text('Order ID: ${orders?[index].id}'),
                    subtitle: Text('Order details: ${orders?[index].details}'),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  // Method to fetch orders from an API or database based on the userId
  Future<List<Order>> _fetchOrders(int userId) async {
    // Replace with your API call or database query to fetch orders
    // Example:
    await Future.delayed(Duration(seconds: 2));  // Simulating network delay

    // Return a sample list of orders
    return [
      Order(id: 1, details: 'Order 1 details'),
      Order(id: 2, details: 'Order 2 details'),
    ];
  }
}

class Order {
  final int id;
  final String details;

  Order({required this.id, required this.details});
}
