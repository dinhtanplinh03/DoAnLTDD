import 'package:flutter/material.dart';
import 'package:untitled7/preferences/preferences_helper.dart';  // Import file PreferencesHelper
import 'package:untitled7/Models/databasehelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled7/screens/Login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _userProfile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();


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
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Phương thức cập nhật thông tin người dùng
  Future<void> _updateUserProfile() async {
    final userId = await PreferencesHelper.getUserId();
    if (userId == null) {
      throw Exception("User not logged in");
    }

    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    // Cập nhật dữ liệu
    await db.update(
      'Customers',
      {
        'name': _nameController.text,
        'phone': _phoneController.text,
      },
      where: 'customer_id = ?',
      whereArgs: [userId],
    );

    // Cập nhật dữ liệu mới vào giao diện
    setState(() {
      _userProfile = _getUserProfile();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cập nhật thông tin thành công!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Không có dữ liệu'));
          } else {
            final user = snapshot.data!;
            _nameController.text = user['name'];
            _phoneController.text = user['phone'];
            _passwordController.text = user['password'];
            _addressController.text = user['address'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Họ tên'),
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Số điện thoại'),
                    keyboardType: TextInputType.phone,
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Mật khẩu'),
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Địa chỉ'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateUserProfile,
                    child: const Text('Cập nhật thông tin'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
