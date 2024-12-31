import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:untitled4/database/products_repository.dart';
import 'package:untitled4/screens/login_form.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late ProductsRepository _productsRepository;
  List<Map<String, dynamic>> _products = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _productsRepository = ProductsRepository();
    _loadProducts();
  }

  // Lấy danh sách sản phẩm từ cơ sở dữ liệu
  Future<void> _loadProducts() async {
    List<Map<String, dynamic>> products = await _productsRepository.getProducts();
    setState(() {
      _products = products;
    });
  }

  // Hàm hiển thị hộp thoại thêm sản phẩm mới
  void _showAddProductDialog() {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _priceController = TextEditingController();
    final _stockController = TextEditingController();
    String? _imageUrl;

    Future<void> _pickImage() async {
      try {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          // Resize the image
          final File imageFile = File(image.path);
          final img.Image? originalImage = img.decodeImage(imageFile.readAsBytesSync());
          if (originalImage != null) {
            final img.Image resizedImage = img.copyResize(originalImage, width: 300);
            final File resizedFile = await imageFile.writeAsBytes(img.encodeJpg(resizedImage));
            setState(() {
              _imageUrl = resizedFile.path;
            });
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Thêm Sản Phẩm'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Tên sản phẩm'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Mô tả'),
                    ),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: 'Giá'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _stockController,
                      decoration: InputDecoration(labelText: 'Số lượng'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await _pickImage();
                            setState(() {}); // Update the UI after picking the image
                          },
                          child: Text('Chọn ảnh'),
                        ),
                        SizedBox(width: 10),
                        _imageUrl != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(_imageUrl!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Text('Chưa chọn ảnh'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng hộp thoại
                  },
                  child: Text('Hủy'),
                ),
                TextButton(
                  onPressed: () async {
                    final name = _nameController.text;
                    final description = _descriptionController.text;
                    final price = double.tryParse(_priceController.text) ?? 0.0;
                    final stock = int.tryParse(_stockController.text) ?? 0;

                    if (name.isNotEmpty && price > 0 && stock > 0) {
                      try {
                        await _productsRepository.addProduct(
                          name: name,
                          description: description,
                          price: price,
                          stock: stock,
                          imageUrl: _imageUrl,
                        );
                        Navigator.pop(context); // Đóng hộp thoại
                        _loadProducts(); // Làm mới danh sách sản phẩm
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi khi thêm sản phẩm: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Vui lòng nhập thông tin hợp lệ!')),
                      );
                    }
                  },
                  child: Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginForm()),
            );
          },
        ),
          title: Text('Admin Page'),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Customers'),
                Tab(text: 'Products'),
                Tab(text: 'Orders'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text('Customers management here')),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _showAddProductDialog,
                        child: Text('Thêm Sản Phẩm'),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ListTile(
                              leading: product['imageUrl'] != null && product['imageUrl'].isNotEmpty
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(
                                  File(product['imageUrl']),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Icon(Icons.image, size: 50), // Hình ảnh mặc định nếu không có ảnh
                              title: Text(product['name']),
                              subtitle: Text('Giá: ${product['price']} VND'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  bool? confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Xác nhận'),
                                      content: Text('Bạn có chắc chắn muốn xóa sản phẩm này không?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Hủy'),
                                          onPressed: () => Navigator.pop(context, false),
                                        ),
                                        TextButton(
                                          child: Text('Xóa'),
                                          onPressed: () => Navigator.pop(context, true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    try {
                                      await _productsRepository.deleteProduct(product['product_id']);
                                      _loadProducts();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Sản phẩm đã được xóa thành công.')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Lỗi khi xóa sản phẩm: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Center(child: Text('Orders management here')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}