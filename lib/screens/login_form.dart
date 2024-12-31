import 'package:flutter/material.dart';
import 'package:untitled4/database/customers_repository.dart'; // Import repository để kiểm tra đăng nhập
import 'home.dart';
import 'registration_form.dart';  // Dẫn đến trang đăng ký
import 'package:untitled4/admin/admin.dart';  // Import trang Admin (tạo trang Admin ở đây)
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';  // Đảm bảo bạn đã import sqflite để làm việc với cơ sở dữ liệu
import 'package:untitled4/database/database_helper.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final CustomersRepository _customersRepository = CustomersRepository();
  late DatabaseHelper _dbHelper; // Khai báo _dbHelper

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper(); // Khởi tạo _dbHelper
  }

  Future<bool> _login(String phone, String password) async {
    Database db = await _dbHelper.database;
    List<Map<String, dynamic>> result = await db.query(
      'Customers',
      where: 'phone = ? AND password = ?',
      whereArgs: [phone, password],
    );

    if (result.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', result.first['customer_id']); // Lưu ID vào SharedPreferences
      return true;
    }
    return false;
  }



  // Hàm gọi để thực hiện đăng nhập
  void _loginUser(BuildContext context) async {
    final phone = _phoneController.text;
    final password = _passwordController.text;

    if (phone == '0123456789' && password == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminPage()), // Trang AdminPage
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      bool success = await _login(phone, password);
      if (success) {
        // Điều hướng đến màn hình chính hoặc trang Admin nếu cần
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),  // Giả sử bạn có một trang HomePage
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập không thành công.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng Nhập')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _loginUser(context),
                child: Text('Đăng Nhập'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Điều hướng đến trang đăng ký
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationForm()),
                  );
                },
                child: Text('Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
