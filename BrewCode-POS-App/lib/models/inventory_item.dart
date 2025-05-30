// lib/models/inventory_item.dart

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String status; // Available, Not Available, Low Stock

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
  });

  bool get isAvailable => status == 'Available';
  bool get isLowStock => status == 'Low Stock';
}
