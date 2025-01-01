class Order {
  int? orderId;
  int customerId;
  double totalAmount;
  int status;
  String orderDate;

  // Constructor với giá trị mặc định cho status là 1
  Order({
    this.orderId,
    required this.customerId,
    required this.totalAmount,
    this.status = 1, // Giá trị mặc định
    required this.orderDate,
  });

  // Chuyển đổi đối tượng thành Map
  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'customer_id': customerId,
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': orderDate,
    };
  }

  // Chuyển Map thành đối tượng Order
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['order_id'],
      customerId: map['customer_id'],
      totalAmount: map['totalAmount'],
      status: map['status'] ?? 1, // Nếu không có giá trị status, dùng giá trị mặc định là 1
      orderDate: map['orderDate'],
    );
  }
}
