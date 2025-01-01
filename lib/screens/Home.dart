import 'package:flutter/material.dart';
import 'package:untitled7/Models/databasehelper.dart'; // Đảm bảo bạn có lớp DatabaseHelper để truy vấn dữ liệu từ DB
import 'package:untitled7/screens/ProductDetail.dart';
import 'package:untitled7/screens/Cart.dart';
import 'package:untitled7/screens/Profile.dart';
import 'package:untitled7/screens/Order.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _products;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _products = _fetchProducts();
  }

  // Hàm lấy danh sách sản phẩm
  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final result = await db.query(
      'Products',
      where: 'status = ?', // Filter by status = 1
      whereArgs: [1], // Pass 1 as the argument for status
    );
    return result;
  }


  // Hàm tìm kiếm sản phẩm
  Future<void> _searchProducts() async {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      DatabaseHelper dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      final result = await db.query(
        'Products',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
      );
      setState(() {
        _products = Future.value(result);
      });
    } else {
      setState(() {
        _products = _fetchProducts();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang Chủ'),
        actions: [
          IconButton(
            icon: Icon(Icons.receipt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(  // Thêm SingleChildScrollView để có thể cuộn
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tìm kiếm sản phẩm
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Tìm kiếm sản phẩm',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchProducts,
                  ),
                ),
                onChanged: (value) {
                  _searchProducts();
                },
              ),
              const SizedBox(height: 16),

              // Tiêu đề danh sách sản phẩm
              const Text(
                'Danh sách sản phẩm',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Hiển thị danh sách sản phẩm
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
                    return GridView.builder(
                      shrinkWrap: true, // Cho phép GridView lấy không gian cần thiết
                      physics: const NeverScrollableScrollPhysics(), // Ngừng cuộn GridView
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return GestureDetector(
                          onTap: () {
                            // Chuyển đến trang chi tiết sản phẩm
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(
                                  productId: product['product_id'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Kiểm tra nếu đường dẫn hình ảnh là một tệp local
                                product['image_url'] != null && product['image_url'].isNotEmpty
                                    ? Image.file(
                                  File(product['image_url']), // Đọc hình ảnh từ tệp
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                                    : Container(height: 100), // Nếu không có hình ảnh thì hiển thị khoảng trống
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    product['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '\$${product['price']}',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}
