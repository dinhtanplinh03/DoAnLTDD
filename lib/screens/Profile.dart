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
  bool _isPasswordVisible = false; // Trạng thái hiển thị mật khẩu

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

    // Điều hướng về trang đăng nhập và xóa toàn bộ stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false, // Xóa tất cả các màn hình trước đó
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
        title: const Text('Trang cá nhân', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
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
            return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Không có dữ liệu', style: TextStyle(fontSize: 16)));
          } else {
            final user = snapshot.data!;
            _nameController.text = user['name'];
            _phoneController.text = user['phone'];
            _passwordController.text = user['password'];
            _addressController.text = user['address'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thông tin cá nhân',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Divider(thickness: 1, height: 20),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Họ tên',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Số điện thoại',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible; // Chuyển đổi trạng thái
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isPasswordVisible, // Kiểm soát hiển thị/ẩn mật khẩu
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Địa chỉ',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.location_on),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateUserProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: Colors.blue,
                        elevation: 3,
                      ),
                      child: const Text(
                        'Cập nhật thông tin',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
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
