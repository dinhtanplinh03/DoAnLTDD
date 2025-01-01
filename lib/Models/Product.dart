class Product {
  int? productId;
  String name;
  String? description;
  double price;
  int stock;
  String? imageUrl;
  int status;

  // Constructor with default value for status
  Product({
    this.productId,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.status = 1, // Default value for status is 1
  });

  // Convert Product object to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'status': status,
    };
  }

  // Convert Map to Product object
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productId: map['product_id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      stock: map['stock'],
      imageUrl: map['image_url'],
      status: map['status'] ?? 1, // Ensure status defaults to 1 if null
    );
  }
}
