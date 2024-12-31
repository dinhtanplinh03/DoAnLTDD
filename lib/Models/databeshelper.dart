import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'QL.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS Customers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          phone TEXT NOT NULL,
          password TEXT NOT NULL,
          role TEXT DEFAULT 'user',
          name TEXT NOT NULL,
          address TEXT NOT NULL
        )
      ''');
      // Tạo bảng Products
      await db.execute('''
          CREATE TABLE Products (
            product_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            price REAL NOT NULL,
            stock INTEGER NOT NULL,
            image_url TEXT,
            category_id INTEGER,
            FOREIGN KEY (category_id) REFERENCES Categories (category_id)
          )
        ''');
      // Tạo bảng Orders
      await db.execute('''
          CREATE TABLE Orders (
            order_id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER NOT NULL,
            totalAmount REAL,
            status TEXT,
            orderDate TEXT,
            FOREIGN KEY (customer_id) REFERENCES Customers (customer_id)
          )
        ''');
      // Tạo bảng OrderDetails
      await db.execute('''
          CREATE TABLE OrderDetails (
            order_detail_id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            FOREIGN KEY (order_id) REFERENCES Orders (order_id),
            FOREIGN KEY (product_id) REFERENCES Products (product_id)
          )
        ''');
      await db.execute('''
          CREATE TABLE Categories (
            category_id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT
          )
        ''');
      await db.execute('''
          INSERT INTO Customers (phone, password, role, name, address)
          VALUES ('1234567890', 'password123', 'admin', 'Default Name', 'Default Address')
      ''');
    });
  }

  Future<void> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    print('Database path: $databasesPath');
  }
}
