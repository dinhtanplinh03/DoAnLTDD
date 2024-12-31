import 'database_helper.dart';

class OrderDetailsRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getOrderDetails() async {
    final db = await dbHelper.database;
    return await db.query('OrderDetails');
  }

// Thêm các phương thức xử lý khác cho bảng OrderDetails nếu cần
}
