import 'package:flutter/material.dart';
import 'package:untitled5/Models/databeshelper.dart'; // Import lớp DatabaseHelper nếu cần

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<Map<String, dynamic>>> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = _fetchCartItems();
  }

  // Hàm lấy danh sách sản phẩm trong giỏ hàng
  Future<List<Map<String, dynamic>>> _fetchCartItems() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    return await db.query('Cart'); // Giả sử bảng giỏ hàng là "Cart"
  }

  // Hàm xóa một sản phẩm khỏi giỏ hàng
  Future<void> _removeItem(int cartItemId) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete(
      'Cart',
      where: 'id = ?', // Giả sử mỗi mục giỏ hàng có cột "id"
      whereArgs: [cartItemId],
    );
    setState(() {
      _cartItems = _fetchCartItems();
    });
  }

  // Hàm cập nhật số lượng sản phẩm
  Future<void> _updateQuantity(int cartItemId, int quantity) async {
    if (quantity > 0) {
      DatabaseHelper dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      await db.update(
        'Cart',
        {'quantity': quantity},
        where: 'id = ?',
        whereArgs: [cartItemId],
      );
      setState(() {
        _cartItems = _fetchCartItems();
      });
    }
  }

  // Hàm tính tổng giá trị giỏ hàng
  Future<double> _calculateTotalAmount() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT SUM(price * quantity) as total FROM Cart');

    // Ép kiểu giá trị total thành double
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Có lỗi xảy ra.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Giỏ hàng trống.'));
          } else {
            final cartItems = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: Image.network(
                          item['image_url'] ?? '',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item['name']),
                        subtitle: Text('Giá: \$${item['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => _updateQuantity(item['id'], item['quantity'] - 1),
                            ),
                            Text('${item['quantity']}'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => _updateQuantity(item['id'], item['quantity'] + 1),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _removeItem(item['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                FutureBuilder<double>(
                  future: _calculateTotalAmount(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Có lỗi xảy ra.');
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng cộng:',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '\$${snapshot.data!.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 20, color: Colors.green),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Xử lý logic thanh toán
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã thực hiện thanh toán.')),
                      );
                    },
                    child: Text('Thanh toán'),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
