import 'database_helper.dart';

class OrdersRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getOrders() async {
    final db = await dbHelper.database;
    return await db.query('Orders');
  }

// Thêm các phương thức xử lý khác cho bảng Orders nếu cần
}
