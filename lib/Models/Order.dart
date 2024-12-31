class Order {
  int? orderId;
  int customerId;
  double? totalAmount;
  String? status;
  String? orderDate;

  Order({
    this.orderId,
    required this.customerId,
    this.totalAmount,
    this.status,
    this.orderDate,
  });

  // Convert Order object to Map
  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'customer_id': customerId,
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': orderDate,
    };
  }

  // Convert Map to Order object
  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['order_id'],
      customerId: map['customer_id'],
      totalAmount: map['totalAmount'],
      status: map['status'],
      orderDate: map['orderDate'],
    );
  }
}
