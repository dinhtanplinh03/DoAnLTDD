class Product {
  int? productId;
  String name;
  String? description;
  double price;
  int stock;
  String? imageUrl;
  int? categoryId;

  Product({
    this.productId,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.categoryId,
  });

  // Convert Product object to Map
  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'category_id': categoryId,
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
      categoryId: map['category_id'],
    );
  }
}
