import 'package:flutter/material.dart';
import 'package:untitled7/Models/databasehelper.dart'; // Đảm bảo bạn có lớp DatabaseHelper để truy vấn dữ liệu từ DB
import 'package:untitled7/screens/Home.dart';  // Giả sử bạn có trang HomePage cho người dùng
import 'package:untitled7/screens/Admin/Admin.dart';
import 'package:untitled7/screens/Register.dart';// Giả sử bạn có trang AdminPage cho quản trị viên
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? 0; // Trả về 0 nếu không tìm thấy 'userId'
  }


  Future<void> _loginUser() async {
    final phone = _phoneController.text;
    final password = _passwordController.text;

    // Kiểm tra thông tin đăng nhập, chỉ lấy tài khoản có status = 1 (mở khóa)
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final result = await db.query(
      'Customers',
      where: 'phone = ? AND password = ? AND status = 1', // Thêm điều kiện status = 1
      whereArgs: [phone, password],
    );

    if (result.isNotEmpty) {
      // Lưu id vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = result[0]['customer_id'] as int;  // Ép kiểu từ Object? sang int
      await prefs.setInt('userId', userId);  // Lưu ID người dùng

      // Kiểm tra role
      String role = result[0]['role'] as String;
      if (role == 'admin') {
        // Nếu là admin, điều hướng đến trang admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else {
        // Nếu là user, điều hướng đến trang chủ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } else {
      // Nếu không tìm thấy người dùng trong DB hoặc tài khoản bị khóa
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập không thành công hoặc tài khoản bị khóa.')),
      );
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng Nhập'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Mật khẩu'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Login Button
              ElevatedButton(
                onPressed: _loginUser,
                child: Text('Đăng nhập'),
              ),

              // Register Button (optional)
              TextButton(
                onPressed: () {
                  // Điều hướng đến trang đăng ký (nếu có)
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),);
                },
                child: Text('Chưa có tài khoản? Đăng ký ngay'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
