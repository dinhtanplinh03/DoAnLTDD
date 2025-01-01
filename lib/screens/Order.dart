import 'package:flutter/material.dart';
import 'package:untitled7/preferences/preferences_helper.dart';
import 'package:untitled7/Models/databasehelper.dart'; // Đảm bảo đã import DatabaseHelper và Order model
import 'package:untitled7/Models/Order.dart';
import 'package:untitled7/screens/OrderDetail.dart';

// Hàm trả về trạng thái tương ứng với status
String getStatusText(int status) {
  switch (status) {
    case 0:
      return 'Đã hủy';
    case 1:
      return 'Đang giao';
    case 2:
      return 'Hoàn thành';
    default:
      return 'Không xác định';
  }
}

// Hàm trả về màu sắc tương ứng với status
Color getStatusColor(int status) {
  switch (status) {
    case 0:
      return Colors.red; // Màu đỏ cho trạng thái đã hủy
    case 1:
      return Colors.orange; // Màu cam cho trạng thái đang giao
    case 2:
      return Colors.green; // Màu xanh cho trạng thái hoàn thành
    default:
      return Colors.black; // Màu đen nếu không xác định
  }
}

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng'),
      ),
      body: FutureBuilder<int?>(
        future: PreferencesHelper.getUserId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Lỗi khi lấy userId'));
          }

          final customerId = snapshot.data;
          if (customerId == null) {
            return const Center(child: Text('Chưa đăng nhập'));
          }

          // Truy vấn đơn hàng theo customerId
          return FutureBuilder<List<Order>>(
            future: DatabaseHelper().getOrdersByCustomerId(customerId),
            builder: (context, orderSnapshot) {
              if (orderSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (orderSnapshot.hasError) {
                return const Center(child: Text('Lỗi khi tải đơn hàng'));
              }

              if (!orderSnapshot.hasData || orderSnapshot.data!.isEmpty) {
                return const Center(child: Text('Không có đơn hàng'));
              }

              // Hiển thị danh sách đơn hàng
              return ListView.builder(
                itemCount: orderSnapshot.data!.length,
                itemBuilder: (context, index) {
                  final order = orderSnapshot.data![index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Đơn hàng ${order.orderId}'),
                      subtitle: Text('Ngày: ${order.orderDate}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Tổng: ${order.totalAmount} VNĐ'),
                          Text(
                            getStatusText(order.status), // Hiển thị trạng thái
                            style: TextStyle(
                              color: getStatusColor(order.status),
                              // Màu sắc tùy thuộc vào trạng thái
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Điều hướng đến màn hình chi tiết đơn hàng
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailPage(order: order),
                          ),
                        );
                      },
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
}
