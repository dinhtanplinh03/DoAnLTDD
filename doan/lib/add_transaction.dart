import 'package:flutter/material.dart';

class AddTransactionScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCategory = 'Ăn uống';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm giao dịch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ['Ăn uống', 'Đi lại', 'Hóa đơn', 'Giải trí']
                    .map((category) =>
                    DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) {
                  _selectedCategory = value!;
                },
                decoration: InputDecoration(labelText: 'Danh mục'),
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Số tiền'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: 'Ghi chú'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Xử lý logic thêm giao dịch
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Giao dịch đã được thêm!')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Thêm giao dịch'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
