import 'package:flutter/material.dart';
import 'screens/Login.dart';
import 'CustomerScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
