import 'package:flutter/material.dart';
import 'package:untitled7/Models/databasehelper.dart';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final int productId;

  const EditProductPage({super.key, required this.productId});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String _productName;
  late String _productDescription;
  late double _productPrice;
  late int _productStock;
  late int _productStatus;
  String? _productimage_url; // Nullable image field

  final ImagePicker _picker = ImagePicker(); // For image selection

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  // Load product data from the database
  Future<void> _loadProductData() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    final result = await db.query(
      'Products',
      where: 'product_id = ?',
      whereArgs: [widget.productId],
    );

    if (result.isNotEmpty) {
      final product = result.first;
      setState(() {
        _productName = product['name'] is String ? product['name'] as String : '';
        _productDescription = product['description'] is String ? product['description'] as String : '';
        _productPrice = product['price'] is double ? product['price'] as double : 0.0;
        _productStock = product['stock'] is int ? product['stock'] as int : 0;
        _productStatus = product['status'] is int ? product['status'] as int : 1;
        _productimage_url = product['image_url'] is String ? product['image_url'] as String : null; // Nullable image
      });
    }
  }

  // Update product in the database
  Future<void> _updateProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      DatabaseHelper dbHelper = DatabaseHelper();
      final db = await dbHelper.database;

      await db.update(
        'Products',
        {
          'name': _productName,
          'description': _productDescription,
          'price': _productPrice,
          'stock': _productStock,
          'status': _productStatus,
          'image_url': _productimage_url, // Will be null if no image is selected
        },
        where: 'product_id = ?',
        whereArgs: [widget.productId],
      );

      Navigator.pop(context, true); // Return true to indicate that the product was updated
    }
  }

  // Pick an image from the device
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _productimage_url = pickedFile.path; // Set the image path
      });
    } else {
      setState(() {
        _productimage_url = null; // Set to null if no image is selected
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa sản phẩm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _productName,
                decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                onChanged: (value) {
                  _productName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên sản phẩm';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _productDescription,
                decoration: const InputDecoration(labelText: 'Mô tả sản phẩm'),
                onChanged: (value) {
                  _productDescription = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mô tả sản phẩm';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _productPrice.toString(),
                decoration: const InputDecoration(labelText: 'Giá sản phẩm'),
                onChanged: (value) {
                  _productPrice = double.tryParse(value) ?? 0.0;
                },
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá sản phẩm';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _productStock.toString(),
                decoration: const InputDecoration(labelText: 'Số lượng tồn kho'),
                onChanged: (value) {
                  _productStock = int.tryParse(value) ?? 0;
                },
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số lượng tồn kho';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _productimage_url ?? '',
                decoration: const InputDecoration(labelText: 'Hình ảnh sản phẩm (URL hoặc đường dẫn)'),
                onChanged: (value) {
                  _productimage_url = value.isNotEmpty ? value : null;
                },
              ),
              // Add image picker button
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Chọn hình ảnh từ thiết bị'),
              ),
              DropdownButtonFormField<int>(
                value: _productStatus,
                decoration: const InputDecoration(labelText: 'Trạng thái'),
                onChanged: (int? newValue) {
                  setState(() {
                    _productStatus = newValue!;
                  });
                },
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Mở khóa')),
                  DropdownMenuItem(value: 0, child: Text('Khóa')),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProduct,
                child: const Text('Cập nhật sản phẩm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
