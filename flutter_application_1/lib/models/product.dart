// lib/models/product.dart

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.isAvailable = true,
  });
  
  // Create from database row
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['ItemID'].toString(),
      name: json['ItemName'],
      price: double.parse(json['Price'].toString()),
      category: json['CategoryName'],
      isAvailable: json['Active'] == 1,
    );
  }
}
