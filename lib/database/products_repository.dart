import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled4/product.dart';

class ProductsRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await dbHelper.database;
    return await db.query('Products');
  }

  Future<List<Product>> getAllProducts() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Products');

    // Chuyển đổi danh sách bản đồ (Map) thành danh sách đối tượng Product
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  /// Thêm một sản phẩm mới vào bảng Products
  Future<int> addProduct({
    required String name,
    String? description,
    required double price,
    required int stock,
    String? imageUrl,
  }) async {
    final db = await dbHelper.database;

    final newProduct = {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
    };

    try {
      return await db.insert(
        'Products',
        newProduct,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (e) {
      throw Exception('Lỗi khi thêm sản phẩm: $e');
    }
  }

  /// Xóa một sản phẩm khỏi bảng Products
  Future<int> deleteProduct(int productId) async {
    final db = await dbHelper.database;

    try {
      return await db.delete(
        'Products',
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      throw Exception('Lỗi khi xóa sản phẩm: $e');
    }
  }
}
