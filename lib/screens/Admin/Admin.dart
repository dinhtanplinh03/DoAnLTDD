import 'package:flutter/material.dart';
import 'package:untitled7/Models/databasehelper.dart'; // Đảm bảo bạn có lớp DatabaseHelper để truy vấn dữ liệu từ DB
import 'package:untitled7/screens/Admin/AddProduct.dart';
import 'package:untitled7/screens/Login.dart';
import 'package:untitled7/screens/Order.dart';
import 'package:untitled7/screens/Admin/EditProduct.dart';
import 'package:untitled7/screens/Admin/OrderDetail.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _customers;
  late Future<List<Map<String, dynamic>>> _products;
  late TabController _tabController;

  late Future<List<Map<String, dynamic>>> _orders; // Biến để lưu đơn hàng

  @override
  void initState() {
    super.initState();
    _customers = _fetchCustomers();
    _products = _fetchProducts();
    _orders = _fetchOrders(); // Lấy danh sách đơn hàng
    _tabController = TabController(length: 3, vsync: this); // Cập nhật length thành 3
  }

// Hàm lấy danh sách đơn hàng
  Future<List<Map<String, dynamic>>> _fetchOrders({DateTime? selectedDate}) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    if (selectedDate != null) {
      // Lọc theo ngày đã chọn
      String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      return await db.query(
        'Orders',
        where: "DATE(orderDate) = ?",
        whereArgs: [formattedDate],
      );
    } else {
      // Lấy tất cả đơn hàng nếu không có ngày cụ thể
      return await db.query('Orders');
    }
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  DateTime? _selectedDate;

  void _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _orders = _fetchOrders(selectedDate: _selectedDate);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          Row(
            children: [
              IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _logout,
            ),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: _selectDate,
              ),
            ]
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Người Dùng'),
            Tab(text: 'Sản Phẩm'),
            Tab(text: 'Đơn hàng',)
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
                      final customerName = customer['name'];
                      final customerPhone = customer['phone'] ?? 'Không có số điện thoại';
                      final customerRole = customer['role'] ?? 'Không xác định';
                      final customerAddress = customer ['address'];

                      return ListTile(
                        title: Text(customerName),
                        subtitle: Column(
                            children:[
                              Text('Phone: $customerPhone'),
                              Text('Address: $customerAddress'),
                              Text('Role: $customerRole'),

                            ] 
                        ),
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
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                EditProductPage(productId: productId)),
                          );
                          if (result == true) {
                            // Khi quay lại và sản phẩm đã được chỉnh sửa, làm mới danh sách sản phẩm
                            setState(() {
                              _products = _fetchProducts(); // Cập nhật lại danh sách sản phẩm
                            });
                          }
                        }
                      );
                    },
                  );
                }
              },
            ),
            // Tab 3: Danh sách đơn hàng
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _orders,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Có lỗi xảy ra.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có đơn hàng.'));
                } else {
                  final orders = snapshot.data!;
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final orderId = order['order_id'] ?? -1;
                      final orderDate = order['orderDate'] ?? 'Không có ngày';
                      final totalAmount = order['totalAmount'];
                      final status = order['status'] ?? 0;
                      return ListTile(
                        title: Text('Đơn hàng #$orderId'),
                        subtitle: Text('Ngày: $orderDate'),
                        trailing: Column(
                          children:[
                            Text('Tổng: $totalAmount VND'),
                            Text(
                            getStatusText(status),
                            style: TextStyle(
                              color: getStatusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),]
                        ),
                        onTap: () {
                          // Điều hướng đến trang chi tiết đơn hàng và truyền dữ liệu
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailPage(
                                orderId: orderId,
                                orderDate: orderDate,
                                totalAmount: totalAmount,
                                status: status,
                              ),
                            ),
                          ).then((_){
                            // Sau khi quay lại, reload lại danh sách đơn hàng
                            setState(() {
                              _orders = _fetchOrders();
                            });
                          });
                        },
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
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );

          if (result == true) {
            setState(() {
              _products = _fetchProducts();
            });
          }
        },
        tooltip: 'Thêm sản phẩm mới',
        child: const Icon(Icons.add),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không tìm thấy sản phẩm.')));
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra khi cập nhật trạng thái sản phẩm.')));
    }
  }

}