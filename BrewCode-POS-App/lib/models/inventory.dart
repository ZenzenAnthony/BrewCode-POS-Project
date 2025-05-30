// lib/models/inventory.dart

class Inventory {
  final String id;
  final String itemName;
  final String? categoryId;
  final String category;
  final String? unit;
  final String status;  // Available, Not Available, Low Stock
  final String? notes;

  Inventory({
    required this.id,
    required this.itemName,
    this.categoryId,
    required this.category,
    this.unit,
    required this.status,
    this.notes,
  });

  // Create from JSON
  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['InventoryID'].toString(),
      itemName: json['ItemName'],
      categoryId: json['CategoryID']?.toString(),
      category: json['CategoryName'] ?? 'Uncategorized',
      unit: json['Unit'],
      status: json['Status'],
      notes: json['Notes'],
    );
  }

  // Convert to JSON for sending to API
  Map<String, dynamic> toJson() {
    return {
      'ItemName': itemName,
      'CategoryID': categoryId,
      'CategoryName': category,
      'Unit': unit,
      'Status': status,
      'Notes': notes,
    };
  }
}
