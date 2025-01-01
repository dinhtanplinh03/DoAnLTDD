import 'package:flutter/material.dart';
import 'package:untitled7/Models/databasehelper.dart'; // Import lớp DatabaseHelper nếu cần
import 'package:untitled7/Models/Cart.dart'; // Import model Cart
import 'package:untitled7/screens/Cart.dart'; // Giả sử bạn có trang giỏ hàng
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class ProductDetailPage extends StatefulWidget {
  final int productId; // ID của sản phẩm được truyền vào

  const ProductDetailPage({super.key, required this.productId});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<Map<String, dynamic>> _productDetails;

  @override
  void initState() {
    super.initState();
    _productDetails = _fetchProductDetails();
  }

  // Hàm lấy thông tin chi tiết sản phẩm
  Future<Map<String, dynamic>> _fetchProductDetails() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final result = await db.query(
      'Products',
      where: 'product_id = ?',
      whereArgs: [widget.productId],
    );
    return result.isNotEmpty ? result.first : {};
  }

  // Hàm thêm sản phẩm vào giỏ hàng
  Future<void> _addToCart(Map<String, dynamic> product) async {
    try {
      final cartItem = Cart(
        productId: product['product_id'],
        name: product['name'],
        price: product['price'],
        quantity: 1, // Mặc định thêm 1 sản phẩm vào giỏ
      );

      DatabaseHelper dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      await db.insert(
        'Cart',
        cartItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sản phẩm đã được thêm vào giỏ hàng!')),
      );
    } catch (e) {
      // Hiển thị thông báo lỗi nếu thêm không thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không thể thêm sản phẩm vào giỏ hàng.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _productDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Có lỗi xảy ra.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không tìm thấy sản phẩm.'));
          } else {
            final product = snapshot.data!;
            String? imageUrl = product['image_url']; // Lấy đường dẫn hình ảnh từ CSDL

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hình ảnh sản phẩm từ file
                  Center(
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.file(File(imageUrl), height: 200, fit: BoxFit.cover)
                        : const Text('Không có hình ảnh'), // Hiển thị thông báo nếu không có hình ảnh
                  ),
                  const SizedBox(height: 16),

                  // Tên sản phẩm
                  Text(
                    product['name'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Giá sản phẩm
                  Text(
                    'Giá: \$${product['price']}',
                    style: const TextStyle(fontSize: 20, color: Colors.green),
                  ),
                  const SizedBox(height: 16),

                  // Mô tả sản phẩm
                  const Text(
                    'Mô tả:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['description'] ?? 'Không có mô tả',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Nút Thêm vào giỏ hàng
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Thêm vào giỏ hàng'),
                      onPressed: () => _addToCart(product),
                    ),
                  ),

                  // Nút quay lại giỏ hàng
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Xem giỏ hàng'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CartPage()), // Giả sử bạn có trang CartPage
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}