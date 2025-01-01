import 'package:flutter/material.dart';
import 'package:untitled7/Models/databasehelper.dart'; // Đảm bảo bạn có lớp DatabaseHelper để truy vấn dữ liệu từ DB
import 'package:untitled7/screens/Admin/AddProduct.dart';
import 'package:untitled7/screens/Login.dart';

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
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
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
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Có lỗi xảy ra.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có người dùng.'));
                } else {
                  final customers = snapshot.data!;
                  return ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      final customerId = customer['customer_id'] ?? -1;
                      final customerPhone = customer['phone'] ?? 'Không có số điện thoại';
                      final customerRole = customer['role'] ?? 'Không xác định';

                      return ListTile(
                        title: Text(customerPhone),
                        subtitle: Text('Role: $customerRole'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.lock_clock),
                              onPressed: () {
                                if (customerId != -1) _blockCustomer(customerId);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.lock_open),
                              onPressed: () {
                                if (customerId != -1) _unblockCustomer(customerId);
                              },
                            ),
                          ],
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
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Có lỗi xảy ra.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có sản phẩm.'));
                } else {
                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final productId = product['product_id'] ?? -1;
                      final productName = product['name'] ?? 'Không có tên';
                      final productPrice = product['price'] ?? 'Không có giá';

                      return ListTile(
                        title: Text(productName),
                        subtitle: Text('Giá: $productPrice'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            if (productId != -1) _blockProduct(productId);
                          },
                          child: const Text('Khóa/Mở khóa'),
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
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductPage()),
          );

          if (result == true) {
            setState(() {
              _products = _fetchProducts();
            });
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Thêm sản phẩm mới',
      ),
    );
  }


  // Hàm chặn (khóa) người dùng
  Future<void> _blockCustomer(int id) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    // Cập nhật trạng thái của người dùng từ 1 (mở khóa) thành 0 (khóa)
    await db.update(
      'Customers',
      {'status': 0}, // Đổi trạng thái thành 0 (khóa)
      where: 'customer_id = ?',
      whereArgs: [id],
    );

    // Cập nhật lại danh sách người dùng sau khi thay đổi trạng thái
    setState(() {
      _customers = _fetchCustomers(); // Cập nhật lại danh sách người dùng
    });
  }

  // Hàm mở khóa người dùng
  Future<void> _unblockCustomer(int id) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    // Cập nhật trạng thái của người dùng từ 0 (khóa) thành 1 (mở khóa)
    await db.update(
      'Customers',
      {'status': 1}, // Đổi trạng thái thành 1 (mở khóa)
      where: 'customer_id = ?',
      whereArgs: [id],
    );

    // Cập nhật lại danh sách người dùng sau khi thay đổi trạng thái
    setState(() {
      _customers = _fetchCustomers(); // Cập nhật lại danh sách người dùng
    });
  }


  Future<void> _blockProduct(int productId) async {
    try {
      // Lấy đối tượng db
      DatabaseHelper dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Truy vấn sản phẩm hiện tại để kiểm tra trạng thái
      final result = await db.query(
        'Products',
        where: 'product_id = ?',
        whereArgs: [productId],
      );

      if (result.isNotEmpty) {
        // Lấy trạng thái hiện tại của sản phẩm
        int currentStatus = result.first['status'] as int;

        // Đảo ngược trạng thái: nếu là 1 thì đổi thành 0, nếu là 0 thì đổi thành 1
        int newStatus = currentStatus == 1 ? 0 : 1;

        // Cập nhật trạng thái của sản phẩm
        await db.update(
          'Products',
          {'status': newStatus},
          where: 'product_id = ?',
          whereArgs: [productId],
        );

        // Thông báo thành công
        String message = newStatus == 1
            ? 'Sản phẩm đã được mở khóa.'
            : 'Sản phẩm đã bị khóa.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

        // Làm mới danh sách sản phẩm
        setState(() {
          _products = _fetchProducts();
        });
      } else {
        // Thông báo nếu không tìm thấy sản phẩm
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không tìm thấy sản phẩm.')));
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra khi cập nhật trạng thái sản phẩm.')));
    }
  }

}
