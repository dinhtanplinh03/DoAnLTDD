class Cart {
  int? id; // ID của giỏ hàng, tự động tăng
  int productId; // ID của sản phẩm, liên kết với bảng Products
  String name; // Tên sản phẩm
  double price; // Giá sản phẩm
  int quantity; // Số lượng sản phẩm

  // Constructor
  Cart({
    this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  // Hàm chuyển đổi đối tượng Cart thành Map (Dùng khi thêm vào cơ sở dữ liệu)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id có thể là null vì là AUTOINCREMENT
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  // Hàm chuyển đổi từ Map thành đối tượng Cart (Dùng khi lấy dữ liệu từ cơ sở dữ liệu)
  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'],
      productId: map['product_id'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}