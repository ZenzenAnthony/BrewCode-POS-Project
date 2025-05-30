import 'package:flutter/foundation.dart';
import '../models/inventory.dart';

class InventoryService {
  // Singleton pattern
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;
  InventoryService._internal();

  // Callback for notifying when inventory status changes
  VoidCallback? _onInventoryChanged;

  // Set callback for inventory changes
  void setInventoryChangeCallback(VoidCallback callback) {
    _onInventoryChanged = callback;
  }

  // Trigger inventory change callback
  void _notifyInventoryChanged() {
    _onInventoryChanged?.call();
  }

  // Complete inventory data from CSV inventory_updated.csv (76 items)
  final List<Inventory> _inventory = [
    Inventory(id: '1', itemName: 'Chicken', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '2', itemName: 'Sugar', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '3', itemName: 'Black Pepper', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '4', itemName: 'Garlic', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '5', itemName: 'Kalamansi', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '6', itemName: 'Egg', categoryId: '1', category: 'Food', unit: 'tray', status: 'Available'),
    Inventory(id: '7', itemName: 'Salt', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '8', itemName: 'Sesame Oil', categoryId: '1', category: 'Food', unit: 'bottle', status: 'Available'),
    Inventory(id: '9', itemName: 'Nam2/Magic Sarap', categoryId: '1', category: 'Food', unit: 'pack', status: 'Available'),
    Inventory(id: '10', itemName: 'Cassava Flour', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '11', itemName: 'Ground Beef', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '12', itemName: 'Onion', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '13', itemName: 'All Purpose Flour', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '14', itemName: 'Bread Crumbs', categoryId: '1', category: 'Food', unit: 'pack', status: 'Available'),
    Inventory(id: '15', itemName: 'Oyster', categoryId: '1', category: 'Food', unit: 'gallon', status: 'Available'),
    Inventory(id: '16', itemName: 'Cups', categoryId: '3', category: 'Supplies', unit: 'pcs', status: 'Available'),
    Inventory(id: '17', itemName: 'Straws', categoryId: '3', category: 'Supplies', unit: 'pcs', status: 'Available'),
    Inventory(id: '18', itemName: 'Plastics Single', categoryId: '3', category: 'Supplies', unit: 'pcs', status: 'Available'),
    Inventory(id: '19', itemName: 'Plastics Double', categoryId: '3', category: 'Supplies', unit: 'pcs', status: 'Available'),
    Inventory(id: '20', itemName: 'Tiny Plastic', categoryId: '3', category: 'Supplies', unit: 'pcs', status: 'Available'),
    Inventory(id: '21', itemName: 'Medium Plastic', categoryId: '3', category: 'Supplies', unit: 'pcs', status: 'Available'),
    Inventory(id: '22', itemName: 'Caramel', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
    Inventory(id: '23', itemName: 'Chocolate', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
    Inventory(id: '24', itemName: 'Ube', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
    Inventory(id: '25', itemName: 'Matcha Powder', categoryId: '2', category: 'Beverages', unit: 'kilo', status: 'Available'),
    Inventory(id: '26', itemName: 'French Vanilla', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
    Inventory(id: '27', itemName: 'Salted Caramel', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
    Inventory(id: '28', itemName: 'Milk', categoryId: '2', category: 'Beverages', unit: 'liter', status: 'Available'),
    Inventory(id: '29', itemName: 'Coffee Beans', categoryId: '2', category: 'Beverages', unit: 'kilo', status: 'Available'),
    Inventory(id: '30', itemName: 'Condensed Milk', categoryId: '2', category: 'Beverages', unit: 'can', status: 'Available'),
    Inventory(id: '31', itemName: 'Strawberry Syrup', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
    Inventory(id: '32', itemName: 'Mixed Berries Syrup', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
    Inventory(id: '33', itemName: 'Lemon Syrup', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
    Inventory(id: '34', itemName: 'Lychee Syrup', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
    Inventory(id: '35', itemName: 'Green Apple Syrup', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
    Inventory(id: '36', itemName: 'Wintermelon Syrup', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
    Inventory(id: '37', itemName: 'Oreos', categoryId: '2', category: 'Beverages', unit: 'pack', status: 'Available'),
    Inventory(id: '38', itemName: 'Cinnamon Powder', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '39', itemName: 'Mango Jam', categoryId: '1', category: 'Food', unit: 'bottle', status: 'Available'),
    Inventory(id: '40', itemName: 'Strawberry Jam', categoryId: '1', category: 'Food', unit: 'bottle', status: 'Available'),
    Inventory(id: '41', itemName: 'Blueberry Jam', categoryId: '1', category: 'Food', unit: 'bottle', status: 'Available'),
    Inventory(id: '42', itemName: 'Parmesan', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '43', itemName: 'Honey Glazed', categoryId: '1', category: 'Food', unit: 'bottle', status: 'Available'),
    Inventory(id: '44', itemName: 'Margarine', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '45', itemName: 'Buffalo Sauce', categoryId: '1', category: 'Food', unit: 'bottle', status: 'Available'),
    Inventory(id: '46', itemName: 'Soy Sauce', categoryId: '1', category: 'Food', unit: 'bottle', status: 'Available'),
    Inventory(id: '47', itemName: 'Teriyaki Sauce', categoryId: '1', category: 'Food', unit: 'bottle', status: 'Available'),
    Inventory(id: '48', itemName: 'Sweet Chili Sauce', categoryId: '1', category: 'Food', unit: 'bottle', status: 'Available'),
    Inventory(id: '49', itemName: 'BBQ Sauce', categoryId: '1', category: 'Food', unit: 'bottle', status: 'Available'),
    Inventory(id: '50', itemName: 'Rice', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '51', itemName: 'Corned Beef', categoryId: '1', category: 'Food', unit: 'can', status: 'Available'),
    Inventory(id: '52', itemName: 'Ham', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '53', itemName: 'Hotdog', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '54', itemName: 'Chorizo', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '55', itemName: 'Tocino', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '56', itemName: 'Spam', categoryId: '1', category: 'Food', unit: 'can', status: 'Available'),
    Inventory(id: '57', itemName: 'Bacon', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '58', itemName: 'Bread', categoryId: '1', category: 'Food', unit: 'loaf', status: 'Available'),
    Inventory(id: '59', itemName: 'Cheese', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '60', itemName: 'Lettuce', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '61', itemName: 'Tomato', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '62', itemName: 'Tortilla Chips', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '63', itemName: 'Potatoes', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '64', itemName: 'Ground Meat', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '65', itemName: 'Waffle Mix', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '66', itemName: 'Pineapple', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '67', itemName: 'Pasta', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '68', itemName: 'Cream', categoryId: '2', category: 'Beverages', unit: 'liter', status: 'Available'),
    Inventory(id: '69', itemName: 'Nutella', categoryId: '1', category: 'Food', unit: 'bottle', status: 'Available'),
    Inventory(id: '70', itemName: 'Marshmallows', categoryId: '1', category: 'Food', unit: 'pack', status: 'Available'),
    Inventory(id: '71', itemName: 'Chocolate Chips', categoryId: '1', category: 'Food', unit: 'kilo', status: 'Available'),
    Inventory(id: '72', itemName: 'Soda', categoryId: '2', category: 'Beverages', unit: 'liter', status: 'Available'),
    Inventory(id: '73', itemName: 'Passionfruit Syrup', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
    Inventory(id: '74', itemName: 'Cherry Syrup', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
    Inventory(id: '75', itemName: 'Ice Cream', categoryId: '2', category: 'Beverages', unit: 'liter', status: 'Available'),
    Inventory(id: '76', itemName: 'Hazelnut Syrup', categoryId: '2', category: 'Beverages', unit: 'bottle', status: 'Available'),
  ];

  // Getters
  List<Inventory> get inventory => [..._inventory]; // Return a mutable copy for provider updates

  // Inventory operations
  List<Inventory> getInventoryByStatus(String status) {
    return _inventory.where((item) => item.status == status).toList();
  }

  List<Inventory> getInventoryByCategory(String categoryId) {
    return _inventory.where((item) => item.categoryId == categoryId).toList();
  }

  Inventory? getInventoryById(String id) {
    try {
      return _inventory.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  Inventory? getInventoryByName(String itemName) {
    try {
      return _inventory.firstWhere((item) => item.itemName == itemName);
    } catch (e) {
      return null;
    }
  }

  List<Inventory> searchInventory(String query) {
    final lowerQuery = query.toLowerCase();
    return _inventory.where((item) =>
        item.itemName.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  bool updateInventoryStatus(int inventoryId, String newStatus) {
    try {
      final index = _inventory.indexWhere((item) => item.id == inventoryId.toString());
      if (index != -1) {
        // Create new inventory item with updated status
        final oldItem = _inventory[index];
        final updatedItem = Inventory(
          id: oldItem.id,
          itemName: oldItem.itemName,
          categoryId: oldItem.categoryId,
          category: oldItem.category,
          unit: oldItem.unit,
          status: newStatus,
          notes: oldItem.notes,
        );        // Replace the item in the list
        _inventory[index] = updatedItem;
        debugPrint('Updated inventory item ${oldItem.itemName} status from ${oldItem.status} to $newStatus');
        
        // Notify that inventory has changed
        _notifyInventoryChanged();
        
        return true;
      }
      debugPrint('Inventory item with ID $inventoryId not found');
      return false;
    } catch (e) {
      debugPrint('Error updating inventory status: $e');
      return false;
    }
  }

  // Analytics
  Map<String, dynamic> getInventoryStatistics() {
    final totalItems = _inventory.length;
    final available = _inventory.where((item) => item.status == 'Available').length;
    final lowStock = _inventory.where((item) => item.status == 'Low Stock').length;
    final notAvailable = _inventory.where((item) => item.status == 'Not Available').length;
    
    final categoryCount = <String, int>{};
    for (final item in _inventory) {
      categoryCount[item.category] = (categoryCount[item.category] ?? 0) + 1;
    }

    return {
      'totalItems': totalItems,
      'available': available,
      'lowStock': lowStock,
      'notAvailable': notAvailable,
      'itemsByCategory': categoryCount,
    };
  }

  // Get all food ingredients
  List<Inventory> getFoodIngredients() {
    return _inventory.where((item) => item.categoryId == '1').toList();
  }

  // Get all beverage ingredients
  List<Inventory> getBeverageIngredients() {
    return _inventory.where((item) => item.categoryId == '2').toList();
  }

  // Get all supplies
  List<Inventory> getSupplies() {
    return _inventory.where((item) => item.categoryId == '3').toList();
  }

  // Get low stock items
  List<Inventory> getLowStockItems() {
    return getInventoryByStatus('Low Stock');
  }

  // Get out of stock items
  List<Inventory> getOutOfStockItems() {
    return getInventoryByStatus('Not Available');
  }

  // Get available items
  List<Inventory> getAvailableItems() {
    return getInventoryByStatus('Available');
  }
}
