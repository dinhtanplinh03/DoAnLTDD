import 'package:flutter/material.dart';
import 'package:untitled7/Models/Order.dart';
import 'package:untitled7/Models/databasehelper.dart';
import 'package:untitled7/Models/OrderDetails.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;

  // Constructor nhận thông tin đơn hàng
  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng #${order.orderId}'),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<OrderDetail>>(
        future: fetchOrderDetails(order.orderId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Lỗi khi tải chi tiết đơn hàng'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có chi tiết cho đơn hàng này'));
          }

          // Hiển thị danh sách chi tiết đơn hàng
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final orderDetail = snapshot.data![index];
                return FutureBuilder<String>(
                  future: fetchProductName(orderDetail.productId),
                  builder: (context, productSnapshot) {
                    if (productSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (productSnapshot.hasError) {
                      return const Center(child: Text('Lỗi khi tải tên sản phẩm'));
                    }

                    final productName = productSnapshot.data ?? 'Tên sản phẩm không có';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          '$productName',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Số lượng: ${orderDetail.quantity} x ${orderDetail.price} VNĐ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        trailing: Text(
                          'Tổng: ${orderDetail.quantity * orderDetail.price} VNĐ',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Hàm lấy chi tiết đơn hàng từ database
  Future<List<OrderDetail>> fetchOrderDetails(int orderId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'OrderDetails',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    return List.generate(maps.length, (i) {
      return OrderDetail.fromMap(maps[i]);
    });
  }

  // Hàm lấy tên sản phẩm từ bảng 'Products' theo productId
  Future<String> fetchProductName(int productId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> result = await db.query(
      'Products',
      columns: ['name'],
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    if (result.isNotEmpty) {
      return result.first['name'];
    } else {
      return 'Sản phẩm không tồn tại';
    }
  }
}
