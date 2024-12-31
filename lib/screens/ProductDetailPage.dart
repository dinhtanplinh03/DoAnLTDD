import 'package:flutter/material.dart';
import 'package:untitled5/Models/databeshelper.dart'; // Import lớp DatabaseHelper nếu cần
import 'package:untitled5/screens/CartPage.dart'; // Giả sử bạn có trang giỏ hàng

class ProductDetailPage extends StatefulWidget {
  final int productId; // ID của sản phẩm được truyền vào

  const ProductDetailPage({Key? key, required this.productId}) : super(key: key);

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
    // Đảm bảo rằng bạn có logic cho giỏ hàng trong cơ sở dữ liệu
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    // Giả sử giỏ hàng là một bảng "Cart"
    await db.insert('Cart', {
      'product_id': product['product_id'],
      'name': product['name'],
      'price': product['price'],
      'quantity': 1, // Mặc định là 1
    });

    // Hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm vào giỏ hàng!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết sản phẩm'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _productDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Có lỗi xảy ra.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không tìm thấy sản phẩm.'));
          } else {
            final product = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hình ảnh sản phẩm
                  Center(
                    child: Image.network(
                      product['image_url'] ?? '',
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Tên sản phẩm
                  Text(
                    product['name'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // Giá sản phẩm
                  Text(
                    'Giá: \$${product['price']}',
                    style: TextStyle(fontSize: 20, color: Colors.green),
                  ),
                  SizedBox(height: 16),

                  // Mô tả sản phẩm
                  Text(
                    'Mô tả:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product['description'] ?? 'Không có mô tả',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),

                  // Nút Thêm vào giỏ hàng
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.shopping_cart),
                      label: Text('Thêm vào giỏ hàng'),
                      onPressed: () => _addToCart(product),
                    ),
                  ),

                  // Nút quay lại giỏ hàng
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.shopping_bag),
                      label: Text('Xem giỏ hàng'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CartPage()), // Giả sử bạn có trang CartPage
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
