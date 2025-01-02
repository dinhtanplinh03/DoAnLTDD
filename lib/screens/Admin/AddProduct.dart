import 'package:flutter/material.dart';
import 'package:untitled7/Models/databasehelper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? product;
  const AddProductPage({super.key, this.product});


  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _productDescriptionController = TextEditingController();
  final TextEditingController _productStockController = TextEditingController();
  final TextEditingController _productImageUrlController = TextEditingController();
  File? _image;

  // Chọn ảnh từ bộ sưu tập hoặc camera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Chọn ảnh từ thư viện

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _productImageUrlController.text = _image!.path;  // Lưu đường dẫn file vào controller
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm Sản Phẩm')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Các trường nhập liệu khác
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên sản phẩm' : null,
              ),
              TextFormField(
                controller: _productPriceController,
                decoration: const InputDecoration(labelText: 'Giá'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập giá sản phẩm' : null,
              ),
              TextFormField(
                controller: _productDescriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập mô tả' : null,
              ),
              TextFormField(
                controller: _productStockController,
                decoration: const InputDecoration(labelText: 'Số lượng trong kho'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập số lượng' : null,
              ),

              // Thêm button để chọn ảnh
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Chọn hình ảnh sản phẩm'),
              ),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.file(_image!, height: 100, width: 100),  // Hiển thị hình ảnh được chọn
                ),

              // Nút thêm sản phẩm
              ElevatedButton(
                onPressed: _addProduct,
                child: const Text('Thêm sản phẩm'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm thêm sản phẩm
  Future<void> _addProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      String name = _productNameController.text;
      double price = double.parse(_productPriceController.text);
      String description = _productDescriptionController.text;
      int stock = int.parse(_productStockController.text);
      String imageUrl = _productImageUrlController.text;  // Lấy đường dẫn của hình ảnh

      // Tạo đối tượng sản phẩm
      var product = {
        'name': name,
        'price': price,
        'description': description,
        'stock': stock,
        'image_url': imageUrl,
        'status': 1,
      };

      // Lấy database và thêm sản phẩm mới
      DatabaseHelper dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      await db.insert('Products', product);

      // Thông báo thêm sản phẩm thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm sản phẩm thành công!')),
      );

      // Truyền kết quả thành công về trang trước
      Navigator.pop(context, true); // true để báo danh sách cần làm mới
    }
  }

}
