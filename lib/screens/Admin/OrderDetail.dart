import 'package:flutter/material.dart';
import 'package:untitled7/Models/databasehelper.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;
  final String orderDate;
  final double totalAmount;
  final int status;

  const OrderDetailPage({
    Key? key,
    required this.orderId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
  }) : super(key: key);

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late int status;

  @override
  void initState() {
    super.initState();
    status = widget.status; // Initialize the status with the passed value
  }

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

  // Hàm cập nhật trạng thái đơn hàng
  Future<void> _updateOrderStatus(BuildContext context, int newStatus) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    // Cập nhật trạng thái đơn hàng trong cơ sở dữ liệu
    await db.update(
      'Orders',
      {'status': newStatus}, // Cập nhật trạng thái mới
      where: 'order_id = ?',
      whereArgs: [widget.orderId],
    );

    // Cập nhật trạng thái trong UI sau khi cập nhật cơ sở dữ liệu
    setState(() {
      status = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng #${widget.orderId}'),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đơn hàng #${widget.orderId}'),
            SizedBox(height: 8),
            Text('Ngày: ${widget.orderDate}'),
            SizedBox(height: 8),
            Text('Tổng tiền: ${widget.totalAmount} VNĐ'),
            SizedBox(height: 8),
            Text(
              'Trạng thái: ${getStatusText(status)}',
              style: TextStyle(color: getStatusColor(status), fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (status == 1) // Chỉ hiển thị nút khi đơn hàng đang giao
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateOrderStatus(context, 0); // Chuyển trạng thái thành đã hủy
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Hủy', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _updateOrderStatus(context, 2); // Chuyển trạng thái thành hoàn thành
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Hoàn thành', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
