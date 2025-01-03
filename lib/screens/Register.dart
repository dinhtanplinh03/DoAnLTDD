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
        backgroundColor: Colors.lightBlueAccent,
        centerTitle: true,
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
                  backgroundColor: Colors.blue, // Màu nền
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bo góc nút
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Tăng kích thước nút
                  elevation: 5, // Tạo hiệu ứng nổi
                  shadowColor: Colors.black54, // Màu bóng
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.person_add, color: Colors.white, size: 20), // Biểu tượng thêm người
                    SizedBox(width: 8), // Khoảng cách giữa biểu tượng và văn bản
                    Text(
                      'Đăng ký',
                      style: TextStyle(
                        color: Colors.white, // Màu chữ
                        fontSize: 18, // Kích thước chữ
                        fontWeight: FontWeight.bold, // Đậm chữ
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
