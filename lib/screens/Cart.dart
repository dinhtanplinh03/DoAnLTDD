import 'package:flutter/material.dart';
import 'package:untitled7/Models/databasehelper.dart'; // Import DatabaseHelper class if necessary
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<Map<String, dynamic>>> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = _fetchCartItems(); // Initialize cart items
  }

  // Fetch cart items from the database
  Future<List<Map<String, dynamic>>> _fetchCartItems() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    return await db.query('Cart'); // Assume cart table is "Cart"
  }

  // Remove an item from the cart
  Future<void> _removeItem(int cartItemId) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete(
      'Cart',
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
    setState(() {
      _cartItems = _fetchCartItems();
    });
  }

  // Update the quantity of a product in the cart
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

  // Calculate the total price of the cart
  Future<double> _calculateTotalAmount() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT SUM(price * quantity) as total FROM Cart');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Hàm lấy số lượng tồn kho từ bảng Products
  Future<int> _fetchStockFromProduct(int productId) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    // Truy vấn sản phẩm từ bảng Products
    final result = await db.query(
      'Products',
      columns: ['stock'],
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    // Nếu có dữ liệu trả về, trả về stock, nếu không trả về 0
    if (result.isNotEmpty) {
      return result.first['stock'] as int? ?? 0; // Ensure stock is casted to int
    } else {
      return 0; // Nếu không tìm thấy sản phẩm, trả về 0
    }
  }

  // Get the userId from SharedPreferences
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');  // Trả về userId từ SharedPreferences
  }

  // Place an order
  Future<void> _placeOrder() async {
    // Get the userId from SharedPreferences
    int? userId = await getUserId();

    // Check if userId is null (i.e., not found)
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy thông tin người dùng!')), // User information not found
      );
      return; // Exit the function if userId is not available
    }

    bool canProceedWithOrder = true; // Flag to check if the order can proceed
    List<Map<String, dynamic>> cartItems = await _cartItems;

    // Check if any item in the cart exceeds the available stock
    for (var item in cartItems) {
      int productId = item['product_id']; // Get the product_id from cart item
      int stock = await _fetchStockFromProduct(productId); // Fetch stock from Products table

      // If quantity in cart exceeds stock, prevent proceeding with the order
      if (item['quantity'] > stock) {
        canProceedWithOrder = false;
        break; // Stop the check if stock is insufficient
      }
    }

    if (canProceedWithOrder) {
      // Proceed with the order if stock is sufficient
      DatabaseHelper dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      // Insert order into the Orders table
      int orderId = await db.insert(
        'Orders',
        {
          'customer_id': userId, // Use the retrieved userId
          'totalAmount': 0.0, // We'll calculate total later
          'status': 1, // Status 1: Order placed successfully
          'orderDate': DateTime.now().toString(),
        },
      );

      double totalAmount = 0.0;

      // Insert each item from the cart as a separate order detail
      for (var item in cartItems) {
        int productId = item['product_id'];
        int quantity = item['quantity'];
        double price = item['price'];
        double total = price * quantity;
        totalAmount += total;

        // Insert into OrderDetails table
        await db.insert(
          'OrderDetails',
          {
            'order_id': orderId,
            'product_id': productId,
            'quantity': quantity,
            'price': price,
          },
        );

        // Update stock after placing the order
        int stock = await _fetchStockFromProduct(productId); // Fetch current stock
        await db.update(
          'Products',
          {'stock': stock - quantity}, // Decrease stock based on quantity ordered
          where: 'product_id = ?',
          whereArgs: [productId],
        );
      }

      // Update the total amount in the Orders table
      await db.update(
        'Orders',
        {'totalAmount': totalAmount}, // Update the total amount
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      // Clear the cart after placing the order successfully
      await _clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đặt hàng thành công!')), // Order placed successfully
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không đủ số lượng sản phẩm trong kho.')), // Insufficient stock
      );
    }
  }

  // Clear the cart after order placement
  Future<void> _clearCart() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    await db.delete('Cart'); // Delete all items from the cart

    setState(() {
      _cartItems = _fetchCartItems(); // Update the cart after clearing
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ hàng'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( // FutureBuilder to load cart items
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
                        leading: item['image_path'] != null && item['image_path'] != ''
                            ? Image.file(
                          File(item['image_path']),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                            : Icon(Icons.image, size: 50),
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
                FutureBuilder<double>( // FutureBuilder for calculating total amount
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
                    onPressed: _placeOrder, // Place the order
                    child: Text('Đặt hàng'),
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
