import 'package:flutter/material.dart';
import 'package:untitled7/Models/Order.dart';
import 'package:untitled7/Models/databasehelper.dart'; // Đảm bảo đã import đúng DatabaseHelper
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
      ),
      body: FutureBuilder<List<OrderDetail>>(
        future: fetchOrderDetails(order.orderId!), // Lấy chi tiết đơn hàng từ database
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
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final orderDetail = snapshot.data![index];
              return FutureBuilder<String>(
                future: fetchProductName(orderDetail.productId), // Lấy tên sản phẩm theo productId
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (productSnapshot.hasError) {
                    return const Center(child: Text('Lỗi khi tải tên sản phẩm'));
                  }

                  final productName = productSnapshot.data ?? 'Tên sản phẩm không có';

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Sản phẩm: $productName'),
                      subtitle: Text('Số lượng: ${orderDetail.quantity} x ${orderDetail.price} VNĐ'),
                      trailing: Text('Tổng: ${orderDetail.quantity * orderDetail.price} VNĐ'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Hàm lấy chi tiết đơn hàng từ database
  Future<List<OrderDetail>> fetchOrderDetails(int orderId) async {
    final db = await DatabaseHelper().database; // Sử dụng DatabaseHelper để truy vấn cơ sở dữ liệu
    final List<Map<String, dynamic>> maps = await db.query(
      'OrderDetails', // Đảm bảo bạn có bảng 'OrderDetails' trong cơ sở dữ liệu
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    // Chuyển đổi kết quả từ database thành danh sách OrderDetail
    return List.generate(maps.length, (i) {
      return OrderDetail.fromMap(maps[i]);
    });
  }

  // Hàm lấy tên sản phẩm từ bảng 'Products' theo productId
  Future<String> fetchProductName(int productId) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> result = await db.query(
      'Products', // Bảng sản phẩm
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
