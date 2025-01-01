class OrderDetail {
  int? orderDetailId;  // ID của chi tiết đơn hàng (khóa chính, tự động tăng)
  int orderId;         // ID đơn hàng
  int productId;       // ID sản phẩm
  int quantity;        // Số lượng sản phẩm
  double price;        // Giá sản phẩm

  // Constructor
  OrderDetail({
    this.orderDetailId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  // Hàm chuyển đổi dữ liệu từ Map sang đối tượng OrderDetail
  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      orderDetailId: map['order_detail_id'],
      orderId: map['order_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }

  // Hàm chuyển đổi đối tượng OrderDetail thành Map để lưu vào cơ sở dữ liệu
  Map<String, dynamic> toMap() {
    return {
      'order_detail_id': orderDetailId,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}
