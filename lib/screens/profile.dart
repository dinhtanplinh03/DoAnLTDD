import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled4/database/database_helper.dart';
import 'package:untitled4/database/customers_repository.dart';  // Import repository
import 'package:untitled4/screens/login_form.dart';  // Import màn hình đăng nhập
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId'); // Lấy ID từ SharedPreferences

    if (userId != null) {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> result = await db.query(
        'Customers',
        where: 'customer_id = ?', // Truy vấn theo ID
        whereArgs: [userId],
      );

      if (result.isNotEmpty) {
        setState(() {
          _userData = result.first;
          _nameController.text = _userData['name'];
          _phoneController.text = _userData['phone'];
          _addressController.text = _userData['address'] ?? '';
          _passwordController.text = _userData['password'];
        });
      }
    } else {
      // Xử lý trường hợp không tìm thấy ID
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy thông tin người dùng!')),
      );
    }
  }

  // Cập nhật thông tin người dùng
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
          // Cập nhật thành công trong cơ sở dữ liệu
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cập nhật thành công!')));

          // Cập nhật SharedPreferences sau khi cập nhật thành công
          _updateSharedPreferences(updatedPhone);

          // Tải lại thông tin người dùng
          _fetchUserData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không có thay đổi nào được thực hiện!')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  // Hàm cập nhật SharedPreferences
  void _updateSharedPreferences(String updatedPhone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userPhone', updatedPhone);  // Cập nhật số điện thoại mới vào SharedPreferences
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Xóa ID người dùng khỏi SharedPreferences

    // Chuyển hướng về màn hình đăng nhập
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginForm()),
    );
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logout,  // Xử lý đăng xuất
              child: Text("Đăng xuất"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Màu đỏ để nổi bật
              ),
            ),
          ],
        ),
      ),
    );
  }
}
