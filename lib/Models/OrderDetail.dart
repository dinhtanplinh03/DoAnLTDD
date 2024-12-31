class OrderDetail {
  int? orderDetailId;
  int orderId;
  int productId;
  int quantity;
  double price;

  OrderDetail({
    this.orderDetailId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  // Convert OrderDetail object to Map
  Map<String, dynamic> toMap() {
    return {
      'order_detail_id': orderDetailId,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  // Convert Map to OrderDetail object
  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      orderDetailId: map['order_detail_id'],
      orderId: map['order_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
