import 'package:flutter/material.dart';
import 'package:untitled7/Models/databasehelper.dart'; // Đảm bảo bạn có lớp DatabaseHelper để truy vấn dữ liệu từ DB
import 'package:untitled7/screens/Home.dart';  // Giả sử bạn có trang HomePage cho người dùng
import 'package:untitled7/screens/Admin/Admin.dart';
import 'package:untitled7/screens/Register.dart';// Giả sử bạn có trang AdminPage cho quản trị viên
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled7/screens/ResetPass.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser() async {
    final phone = _phoneController.text;
    final password = _passwordController.text;

    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final result = await db.query(
      'Customers',
      where: 'phone = ? AND password = ? AND status = 1', // Thêm điều kiện status = 1
      whereArgs: [phone, password],
    );

    if (result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final userId = result[0]['customer_id'] as int;  // Ép kiểu từ Object? sang int
      await prefs.setInt('userId', userId);  // Lưu ID người dùng

      String role = result[0]['role'] as String;
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập không thành công hoặc tài khoản bị khóa.')),
      );
    }
  }


  Future<void> _resetPassword() async {
    final phone = _phoneController.text;

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số điện thoại')),
      );
      return;
    }

    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final result = await db.query(
      'Customers',
      where: 'phone = ? AND status = 1', // Check if the phone number exists and status = 1
      whereArgs: [phone],
    );

    if (result.isNotEmpty) {
      // If the phone exists, show a dialog to set a new password
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final _newPasswordController = TextEditingController();
          return AlertDialog(
            title: const Text('Đặt mật khẩu mới'),
            content: TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu mới';
                }
                return null;
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  final newPassword = _newPasswordController.text;
                  if (newPassword.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập mật khẩu mới')),
                    );
                    return;
                  }

                  // Update password in the database
                  await db.update(
                    'Customers',
                    {'password': newPassword},
                    where: 'phone = ?',
                    whereArgs: [phone],
                  );

                  Navigator.pop(context);  // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mật khẩu đã được thay đổi thành công')),
                  );
                },
                child: const Text('Đặt lại mật khẩu'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại không tồn tại hoặc tài khoản bị khóa')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HUSUKA', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Đăng Nhập',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                      onPressed: _loginUser,
                      child: const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                    ),

                    const SizedBox(height: 12),

                    // Register Button
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        'Chưa có tài khoản? Đăng ký ngay',
                        style: TextStyle(color: Colors.lightBlueAccent),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Reset Pass
                    TextButton(
                      onPressed: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const ResetPassPage()),
                        );
                        },
                      child: const Text(
                        'Quên mật khẩu',
                        style: TextStyle(color: Colors.lightBlueAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
