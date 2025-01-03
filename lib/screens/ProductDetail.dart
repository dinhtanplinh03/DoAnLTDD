import 'package:flutter/material.dart';
import 'package:untitled7/Models/databasehelper.dart';
import 'package:untitled7/Models/Cart.dart';
import 'package:untitled7/screens/Cart.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

class ProductDetailPage extends StatefulWidget {
  final int productId;

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

  Future<void> _addToCart(Map<String, dynamic> product) async {
    try {
      final cartItem = Cart(
        productId: product['product_id'],
        name: product['name'],
        price: product['price'],
        quantity: 1,
      );

      DatabaseHelper dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      await db.insert(
        'Cart',
        cartItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sản phẩm đã được thêm vào giỏ hàng!')),
      );
    } catch (e) {
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
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        elevation: 0,
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
            String? imageUrl = product['image_url'];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.file(File(imageUrl), height: 250, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 100, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Giá: ${product['price']} VNĐ',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Mô tả:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product['description'] ?? 'Không có mô tả',
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 160,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Thêm vào giỏ hàng'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: () => _addToCart(product),
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.shopping_bag),
                            label: const Text('Xem giỏ hàng'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.lightBlueAccent, side: const BorderSide(color: Colors.lightBlueAccent),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CartPage()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
