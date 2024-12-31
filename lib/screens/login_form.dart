import 'package:flutter/material.dart';
import 'package:untitled4/database/customers_repository.dart'; // Import repository để kiểm tra đăng nhập
import 'home.dart';
import 'registration_form.dart';  // Dẫn đến trang đăng ký
import 'package:untitled4/admin/admin.dart';  // Import trang Admin (tạo trang Admin ở đây)

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final CustomersRepository _customersRepository = CustomersRepository();

  Future<void> _loginUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Kiểm tra nếu số điện thoại là "0123456789" và mật khẩu là "admin"
        if (_phoneController.text == "0123456789" && _passwordController.text == "admin") {
          // Điều hướng đến trang Admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()), // Chuyển đến trang Admin
          );
        } else {
          // Kiểm tra số điện thoại và mật khẩu trong cơ sở dữ liệu
          final isExist = await _customersRepository.isPhoneExist(_phoneController.text);

          if (isExist) {
            final db = await _customersRepository.dbHelper.database;
            final List<Map<String, dynamic>> users = await db.query(
              'Customers',
              where: 'phone = ? AND password = ?',
              whereArgs: [_phoneController.text, _passwordController.text],
            );

            if (users.isNotEmpty) {
              // Đăng nhập thành công
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đăng nhập thành công!')),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()), // Điều hướng tới trang Home
              );
            } else {
              // Mật khẩu không đúng
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mật khẩu không đúng!')),
              );
            }
          } else {
            // Số điện thoại không tồn tại
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Số điện thoại không tồn tại!')),
            );
          }
        }
      } catch (e) {
        // Xử lý lỗi nếu có
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng nhập thất bại: $e')),
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
