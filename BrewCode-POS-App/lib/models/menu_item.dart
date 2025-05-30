class MenuItem {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int categoryId;
  final bool active;
  
  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.categoryId,
    required this.active
  });
  
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      categoryId: int.parse(json['category_id'].toString()),
      active: json['active'] == "1" || json['active'] == 1 || json['active'] == true
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category_id': categoryId,
      'active': active,
    };
  }
}
