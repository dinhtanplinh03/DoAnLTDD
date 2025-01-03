import 'package:flutter/material.dart';
import 'package:untitled7/Models/databasehelper.dart';
import 'package:untitled7/Models/Customer.dart';
import 'package:untitled7/screens/Login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  // Hàm đăng ký người dùng
  Future<void> _registerUser(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      // Lấy dữ liệu từ các TextEditingController
      String phone = _phoneController.text;
      String password = _passwordController.text;
      String name = _nameController.text;
      String address = _addressController.text;
      String role = 'user'; // Mặc định role là 'user'

      // Kiểm tra xem các trường name và address có bị trống không
      if (name.isEmpty || address.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tên và địa chỉ không thể để trống')),
        );
        return;
      }

      // Tạo đối tượng Customer
      Customer newCustomer = Customer(
        phone: phone,
        password: password,
        role: role,
        name: name,
        address: address,
      );

      // Lấy database và thêm người dùng mới
      DatabaseHelper dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      await db.insert('Customers', newCustomer.toMap());

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!')),
      );

      // Chuyển hướng sang màn hình đăng nhập sau một khoảng thời gian ngắn
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trường tên người dùng
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tên không thể để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Trường mật khẩu
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mật khẩu không thể để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Trường số điện thoại
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Số điện thoại không thể để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Trường địa chỉ người dùng
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Địa chỉ không thể để trống';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Nút đăng ký
              ElevatedButton(
                onPressed: () => _registerUser(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Đăng ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
