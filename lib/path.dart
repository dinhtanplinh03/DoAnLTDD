import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Để sử dụng getDatabasesPath
import 'package:sqflite/sqflite.dart';
import 'database/database_helper.dart';

class Pathcsdl extends StatelessWidget {
  // Hàm lấy đường dẫn cơ sở dữ liệu và in ra console
  Future<void> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    print('Database path: $databasesPath');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng ký'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Gọi phương thức getDatabasePath khi nhấn nút
            await getDatabasePath();
            // Bạn có thể thực hiện các hành động khác như mở màn hình mới hoặc thực hiện thao tác khác
          },
          child: Text('Đăng Ký2'),
        ),
      ),
    );
  }
}
