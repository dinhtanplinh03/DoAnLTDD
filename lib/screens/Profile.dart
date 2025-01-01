import 'package:flutter/material.dart';
import 'package:untitled7/preferences/preferences_helper.dart';  // Import file PreferencesHelper
import 'package:untitled7/Models/databasehelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled7/screens/Login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _userProfile;

  @override
  void initState() {
    super.initState();
    _userProfile = _getUserProfile();
  }

  // Lấy thông tin người dùng từ SharedPreferences
  Future<Map<String, dynamic>> _getUserProfile() async {
    final userId = await PreferencesHelper.getUserId();  // Gọi phương thức lấy userId từ PreferencesHelper
    if (userId == null) {
      throw Exception("User not logged in");
    }

    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final result = await db.query(
      'Customers',
      where: 'customer_id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result[0];  // Trả về thông tin người dùng
    } else {
      throw Exception("User not found");
    }
  }

  // Phương thức đăng xuất
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Xóa userId khỏi SharedPreferences
    await prefs.remove('userId');

    // Điều hướng về trang đăng nhập
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trang cá nhân'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _logout(context), // Gọi phương thức đăng xuất
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Không có dữ liệu'));
          } else {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Số điện thoại: ${user['phone']}'),
                  Text('Họ tên: ${user['name']}'),
                  Text('Vai trò: ${user['role']}'),
                  // Các thông tin khác của người dùng
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
