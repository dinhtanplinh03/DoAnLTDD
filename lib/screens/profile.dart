import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled4/database/database_helper.dart';
import 'package:untitled4/database/customers_repository.dart';  // Import repository

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late DatabaseHelper _dbHelper;
  late CustomersRepository _customersRepository;
  Map<String, dynamic> _userData = {};
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _customersRepository = CustomersRepository();
    _fetchUserData();
  }

  // Fetch user data from database
  Future<void> _fetchUserData() async {
    Database db = await _dbHelper.database;
    List<Map<String, dynamic>> result = await db.query('Customers', limit: 1);  // Adjust to 'Customers' table

    if (result.isNotEmpty) {
      setState(() {
        _userData = result.first;
        _nameController.text = _userData['name'];
        _phoneController.text = _userData['phone'];
        _addressController.text = _userData['address'] ?? '';
        _passwordController.text = _userData['password'];
      });
    }
  }

  // Update user data in the database
  Future<void> _updateUserData() async {
    final updatedName = _nameController.text;
    final updatedPhone = _phoneController.text;
    final updatedAddress = _addressController.text;
    final updatedPassword = _passwordController.text;

    if (updatedName.isNotEmpty && updatedPhone.isNotEmpty && updatedPassword.isNotEmpty) {
      try {
        final result = await _customersRepository.updateCustomer(
          customerId: _userData['customer_id'],
          name: updatedName,
          phone: updatedPhone,
          address: updatedAddress,
          password: updatedPassword,
        );

        if (result > 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cập nhật thành công!')));
          _fetchUserData(); // Reload user data after update
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không có thay đổi nào được thực hiện!')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ Sơ Người Dùng'),
      ),
      body: _userData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Họ tên'),
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Số điện thoại'),
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Địa chỉ'),
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateUserData,
              child: Text("Lưu thay đổi"),
            ),
          ],
        ),
      ),
    );
  }
}
