// lib/models/menu_item_ingredient.dart
// Simple model for menu item - ingredient relationship without quantity tracking

class MenuItemIngredient {
  final String menuItemId;
  final String inventoryId;
  String status; // Added status field

  MenuItemIngredient({
    required this.menuItemId,
    required this.inventoryId,
    this.status = 'Available', // Default status
  });

  factory MenuItemIngredient.fromJson(Map<String, dynamic> json) {
    return MenuItemIngredient(
      menuItemId: json['MenuItemID'].toString(),
      inventoryId: json['InventoryID'].toString(),
      status: json['Status'] ?? 'Available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MenuItemID': menuItemId,
      'InventoryID': inventoryId,
      'Status': status,
    };
  }
}
