import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


// Ensure that you have a database initialization method (_initDatabase)
Future<Database> _initDatabase() async {
  String path = join(await getDatabasesPath(), 'myapp.db');
  return openDatabase(path, version: 1, onCreate: (db, version) async {
    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS Customers (
        customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT DEFAULT 'user',
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        status INTEGER
      )
    ''');
  });
}
Future<List<Map<String, dynamic>>> fetchCustomers() async {
  final db = await _initDatabase(); // Make sure this points to your database initialization method
  final result = await db.query('Customers'); // Query all customers from the table
  return result;
}
class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    final db = await _initDatabase(); // Ensure your database initialization method is called here
    final result = await db.query('Customers');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách khách hàng'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCustomers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Có lỗi xảy ra'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có khách hàng nào.'));
          } else {
            final customers = snapshot.data!;
            return ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ListTile(
                  title: Text(customer['name'] ?? 'Không có tên'),
                  subtitle: Text('Phone: ${customer['phone']}'),
                  trailing: Text('Status: ${customer['status']}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
