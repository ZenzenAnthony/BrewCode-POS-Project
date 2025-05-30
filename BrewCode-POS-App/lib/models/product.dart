// lib/models/product.dart

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final bool isAvailable;
  final bool hasLowStockIngredients;
  final String? description;
  final int categoryId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.categoryId,
    this.description,
    this.isAvailable = true,
    this.hasLowStockIngredients = false,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['ItemID'].toString(),
      name: json['ItemName'],
      description: json['Description'],
      price: double.parse(json['Price'].toString()),
      categoryId: int.parse(json['CategoryID'].toString()),
      category: json['CategoryName'] ?? '',
      isAvailable: json['Active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ItemID': id,
      'ItemName': name,
      'Description': description,
      'Price': price,
      'CategoryID': categoryId,
      'CategoryName': category,
      'Active': isAvailable ? 1 : 0,
    };
  }
}
