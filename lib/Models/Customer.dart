class Customer {
  int? id;
  String phone;
  String password;
  String role;
  String name;
  String address;

  Customer({
    this.id,
    required this.phone,
    required this.password,
    this.role = 'user',  // Giả sử role mặc định là 'user'
    required this.name,
    required this.address,
  });

  // Chuyển đổi đối tượng Customer thành Map để lưu vào cơ sở dữ liệu
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone': phone,
      'password': password,
      'role': role,
      'name': name,
      'address': address,
    };
  }

  // Tạo Customer từ Map (khi lấy dữ liệu từ cơ sở dữ liệu)
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      phone: map['phone'],
      password: map['password'],
      role: map['role'] ?? 'user',  // Mặc định 'user' nếu role không có
      name: map['name'],
      address: map['address'],
    );
  }
}
