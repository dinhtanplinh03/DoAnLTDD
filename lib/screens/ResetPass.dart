import 'package:flutter/material.dart';
import 'package:untitled7/Models/databasehelper.dart'; // Ensure you have the DatabaseHelper to query the database
import 'package:shared_preferences/shared_preferences.dart';

class ResetPassPage extends StatefulWidget {
  const ResetPassPage({super.key});

  @override
  _ResetPassPageState createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  Future<void> _resetPassword() async {
    final phone = _phoneController.text;
    final newPassword = _newPasswordController.text;

    if (phone.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    // Check if phone number exists in the database
    final result = await db.query(
      'Customers',
      where: 'phone = ? AND status = 1', // Ensure account is active
      whereArgs: [phone],
    );

    if (result.isNotEmpty) {
      // Update password in the database
      final customerId = result[0]['customer_id'] as int;
      await db.update(
        'Customers',
        {'password': newPassword},
        where: 'customer_id = ?',
        whereArgs: [customerId],
      );

      // Optionally, you can save the userId to SharedPreferences again
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', customerId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu đã được đặt lại thành công')),
      );

      Navigator.pop(context); // Navigate back to the login screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số điện thoại không tồn tại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lại mật khẩu'),
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
                      'Đặt lại mật khẩu',
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

                    // New Password Field
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu mới',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu mới';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Reset Password Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                      onPressed: _resetPassword,
                      child: const Text('Đặt lại mật khẩu', style: TextStyle(fontSize: 16)),
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
