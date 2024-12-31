import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';

class CustomersRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getCustomers() async {
    final db = await dbHelper.database;
    return await db.query('Customers');
  }

  /// Đăng ký tài khoản khách hàng mới
  Future<int> registerCustomer({
    required String name,
    required String phone,
    required String password,
    String? address,
  }) async {
    final db = await dbHelper.database;

    // Tạo dữ liệu để thêm vào bảng Customers
    final newCustomer = {
      'name': name,
      'phone': phone,
      'address': address,
      'password': password,
    };

    try {
      // Thêm khách hàng mới và trả về ID
      return await db.insert(
        'Customers',
        newCustomer,
        conflictAlgorithm: ConflictAlgorithm.abort, // Xử lý lỗi nếu trùng phone
      );
    } catch (e) {
      throw Exception('Lỗi khi đăng ký tài khoản: $e');
    }
  }

  /// Kiểm tra số điện thoại đã tồn tại
  Future<bool> isPhoneExist(String phone) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'Customers',
      where: 'phone = ?',
      whereArgs: [phone],
    );

    return result.isNotEmpty;
  }

  /// Cập nhật thông tin khách hàng
  Future<int> updateCustomer({
    required int customerId,
    required String name,
    String? phone,
    String? address,
    String? password,
  }) async {
    final db = await dbHelper.database;

    // Tạo dữ liệu mới để cập nhật
    final updatedCustomer = {
      'name': name,
      'phone': phone,
      'address': address,
      'password': password,
    };

    // Xóa các giá trị null khỏi map
    updatedCustomer.removeWhere((key, value) => value == null);

    try {
      // Cập nhật thông tin khách hàng và trả về số lượng bản ghi bị ảnh hưởng
      return await db.update(
        'Customers',
        updatedCustomer,
        where: 'customer_id = ?',
        whereArgs: [customerId],
      );
    } catch (e) {
      throw Exception('Lỗi khi cập nhật thông tin khách hàng: $e');
    }
  }
// Thêm các phương thức xử lý khác cho bảng Customers nếu cần
}
