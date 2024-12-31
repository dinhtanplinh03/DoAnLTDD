import 'package:flutter/material.dart';
import 'package:untitled4/database/customers_repository.dart';

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final CustomersRepository _customersRepository = CustomersRepository();

  Future<void> _registerUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final password = _passwordController.text.trim();
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();

      try {
        // Kiểm tra số điện thoại đã tồn tại
        if (await _customersRepository.isPhoneExist(phone)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Số điện thoại đã được đăng ký!')),
          );
          return;
        }

        // Đăng ký tài khoản
        await _customersRepository.registerCustomer(
          name: name,
          password: password,
          phone: phone,
          address: address,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng ký thành công!')),
        );

        // Xóa form sau khi đăng ký
        _formKey.currentState!.reset();
        _nameController.clear();
        _passwordController.clear();
        _phoneController.clear();
        _addressController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng ký thất bại: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng Ký Tài Khoản'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Họ và Tên'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Số Điện Thoại'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Địa Chỉ'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mật Khẩu'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _registerUser(context),
                child: Text('Đăng Ký'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
