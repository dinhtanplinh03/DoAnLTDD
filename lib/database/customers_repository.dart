import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';

class CustomersRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getCustomers() async {
    try {
      final db = await dbHelper.database; // Lấy cơ sở dữ liệu từ dbHelper
      final result = await db.query('Customers'); // Thực hiện truy vấn bảng 'Customers'
      return result; // Trả về danh sách các dòng dữ liệu
    } catch (e) {
      print('Error fetching customers: $e'); // Log lỗi để dễ dàng phát hiện vấn đề
      return []; // Trả về danh sách rỗng nếu có lỗi
    }
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

  // Cập nhật thông tin khách hàng
  Future<int> updateCustomer({
    required int customerId,
    required String name,
    required String phone,
    required String address,
    required String password,
  }) async {
    final db = await dbHelper.database;
    return await db.update(
      'Customers',
      {
        'name': name,
        'phone': phone,
        'address': address,
        'password': password,
      },
      where: 'customer_id = ?',
      whereArgs: [customerId],
    );
  }
// Thêm các phương thức xử lý khác cho bảng Customers nếu cần
}
