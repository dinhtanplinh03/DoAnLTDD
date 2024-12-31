import 'package:flutter/material.dart';
import 'screens/Login.dart'; // Đảm bảo rằng đường dẫn đúng với file LoginPage.dart của bạn

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt banner debug
      title: 'App Bán Mỹ Phẩm',
      theme: ThemeData(
        primarySwatch: Colors.pink, // Tùy chỉnh màu sắc chính cho ứng dụng
      ),
      home: LoginPage(), // Màn hình đăng nhập là màn hình chính
    );
  }
}
