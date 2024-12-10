import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin người dùng'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/user_avatar.png'), // Thay đổi ảnh đại diện
            ),
            const SizedBox(height: 20),
            const Text(
              'Tên người dùng',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Email: user@example.com'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Thêm logic chỉnh sửa thông tin hoặc đăng xuất
              },
              child: const Text('Chỉnh sửa thông tin'),
            ),
          ],
        ),
      ),
    );
  }
}
