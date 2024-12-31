import 'package:flutter/material.dart';
import 'package:untitled5/Models/databeshelper.dart'; // Đảm bảo bạn có lớp DatabaseHelper để truy vấn dữ liệu từ DB
import 'package:untitled5/screens/Admin/AddProductPage.dart';
import 'package:untitled5/screens/Login.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _customers;
  late Future<List<Map<String, dynamic>>> _products;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _customers = _fetchCustomers();
    _products = _fetchProducts();
    _tabController = TabController(length: 2, vsync: this); // Khởi tạo TabController với 2 tab
  }

  // Hàm lấy danh sách người dùng
  Future<List<Map<String, dynamic>>> _fetchCustomers() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final result = await db.query('Customers');
    return result;
  }

  // Hàm lấy danh sách sản phẩm
  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final result = await db.query('Products');
    return result;
  }

  // Hàm đăng xuất
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Quay về trang chủ
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Người Dùng'),
            Tab(text: 'Sản Phẩm'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Danh sách người dùng
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _customers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Có lỗi xảy ra.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có người dùng.'));
                } else {
                  final customers = snapshot.data!;
                  return ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return ListTile(
                        title: Text(customer['phone']),
                        subtitle: Text('Role: ${customer['role']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteCustomer(customer['id']);
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
            // Tab 2: Danh sách sản phẩm
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Có lỗi xảy ra.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có sản phẩm.'));
                } else {
                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product['name']),
                        subtitle: Text('Giá: ${product['price']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteProduct(product['id']);
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Thêm sản phẩm mới',
      ),
    );
  }

  // Hàm xóa người dùng
  Future<void> _deleteCustomer(int id) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete(
      'Customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    setState(() {
      _customers = _fetchCustomers(); // Cập nhật lại danh sách sau khi xóa
    });
  }

  // Hàm xóa sản phẩm
  Future<void> _deleteProduct(int id) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete(
      'Products',
      where: 'id = ?',
      whereArgs: [id],
    );
    setState(() {
      _products = _fetchProducts(); // Cập nhật lại danh sách sau khi xóa
    });
  }
}
