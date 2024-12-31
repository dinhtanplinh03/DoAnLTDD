class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['product_id'],
      name: map['name'],
      description: map['description'] ?? '',
      price: map['price'],
      stock: map['stock'],
      imageUrl: map['image_url'],
    );
  }
}
