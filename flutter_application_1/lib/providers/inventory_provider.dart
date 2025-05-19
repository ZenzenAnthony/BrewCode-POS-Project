// lib/providers/inventory_provider.dart

import 'package:flutter/material.dart';
import '../models/inventory.dart';
import '../services/inventory_service_placeholder.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryServicePlaceholder _inventoryService = InventoryServicePlaceholder();
  List<Inventory> _inventoryItems = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Inventory> get inventoryItems => [..._inventoryItems];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load inventory items
  Future<void> loadInventory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final inventoryList = await _inventoryService.getAllInventoryItems();
      _inventoryItems = inventoryList;
    } catch (e) {
      _error = 'Failed to load inventory: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update inventory status
  Future<bool> updateInventoryStatus(String inventoryId, String newStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _inventoryService.updateInventoryStatus(inventoryId, newStatus);
      
      if (success) {
        // Update the local inventory item
        final itemIndex = _inventoryItems.indexWhere((item) => item.id == inventoryId);
        
        if (itemIndex != -1) {
          _inventoryItems[itemIndex] = Inventory(
            id: _inventoryItems[itemIndex].id,
            itemName: _inventoryItems[itemIndex].itemName,
            categoryId: _inventoryItems[itemIndex].categoryId,
            unit: _inventoryItems[itemIndex].unit,
            status: newStatus,
            notes: _inventoryItems[itemIndex].notes,
          );
          
          // After updating inventory, refresh menu item availability
          await _inventoryService.updateAllMenuItemAvailability();
          
          notifyListeners();
          return true;
        }
      }
      
      return false;
    } catch (e) {
      _error = 'Failed to update inventory status: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get inventory items by category
  List<Inventory> getInventoryByCategory(String categoryId) {
    return _inventoryItems
        .where((item) => item.categoryId == categoryId)
        .toList();
  }

  // Get inventory items by status
  List<Inventory> getInventoryByStatus(String status) {
    return _inventoryItems
        .where((item) => item.status == status)
        .toList();
  }

  // Get inventory item by ID
  Inventory? getInventoryById(String inventoryId) {
    try {
      return _inventoryItems.firstWhere((item) => item.id == inventoryId);
    } catch (e) {
      return null;
    }
  }
}
