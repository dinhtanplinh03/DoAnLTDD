class Category {
  int? categoryId;
  String name;
  String? description;

  Category({
    this.categoryId,
    required this.name,
    this.description,
  });

  // Convert Category object to Map
  Map<String, dynamic> toMap() {
    return {
      'category_id': categoryId,
      'name': name,
      'description': description,
    };
  }

  // Convert Map to Category object
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      categoryId: map['category_id'],
      name: map['name'],
      description: map['description'],
    );
  }
}
