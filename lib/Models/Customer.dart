class Customer {
  // Các thuộc tính của bảng 'Customers'
  int? customer_id;  // Sử dụng int? vì id có thể null khi tạo mới (do AUTOINCREMENT)
  String phone;
  String password;
  String role;
  String name;
  String address;
  int status;  // Đã thay đổi thành int và không cần null vì có giá trị mặc định

  // Constructor
  Customer({
    this.customer_id,
    required this.phone,
    required this.password,
    this.role = 'user',  // Giá trị mặc định cho role là 'user'
    required this.name,
    required this.address,
    this.status = 1,  // Giá trị mặc định cho status là 1
  });

  // Phương thức chuyển đối tượng Customer thành Map để lưu vào cơ sở dữ liệu
  Map<String, dynamic> toMap() {
    return {
      'customer_id': customer_id,
      'phone': phone,
      'password': password,
      'role': role,
      'name': name,
      'address': address,
      'status': status,
    };
  }

  // Phương thức tạo đối tượng Customer từ một Map (kết quả truy vấn cơ sở dữ liệu)
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      customer_id: map['id'],
      phone: map['phone'],
      password: map['password'],
      role: map['role'] ?? 'user',  // Nếu role là null, mặc định là 'user'
      name: map['name'],
      address: map['address'],
      status: map['status'] ?? 1,  // Nếu status là null, mặc định là 1
    );
  }
}
