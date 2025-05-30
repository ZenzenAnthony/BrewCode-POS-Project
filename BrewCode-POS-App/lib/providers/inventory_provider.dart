// lib/providers/inventory_provider.dart

import 'package:flutter/material.dart';
import '../models/inventory.dart';
import '../services/local_data_service.dart';

class InventoryProvider with ChangeNotifier {
  final LocalDataService _localDataService;
  List<Inventory> _inventoryItems = [];
  bool _isLoading = false;
  String? _error;

  InventoryProvider(this._localDataService);

  // Getters
  List<Inventory> get inventoryItems => [..._inventoryItems];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load inventory items
  Future<void> loadInventory() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    // Notify only if not in build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _inventoryItems = _localDataService.inventory;
    } catch (e) {
      _error = 'Failed to load inventory: $e';
    } finally {
      _isLoading = false;
      // Notify only if not in build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }  // Update inventory status
  Future<bool> updateInventoryStatus(String inventoryId, String newStatus) async {
    if (_isLoading) {
      return false;
    }

    try {
      // Update using LocalDataService with menu check to trigger availability updates
      final success = _localDataService.updateInventoryStatusWithMenuCheck(int.parse(inventoryId), newStatus);
      
      if (success) {
        // Then update the local state
        final index = _inventoryItems.indexWhere((item) => item.id == inventoryId);
        
        if (index != -1) {
          _inventoryItems[index] = Inventory(
            id: _inventoryItems[index].id,
            itemName: _inventoryItems[index].itemName,
            categoryId: _inventoryItems[index].categoryId,
            category: _inventoryItems[index].category,
            unit: _inventoryItems[index].unit,
            status: newStatus,
            notes: _inventoryItems[index].notes,
          );
          // Notify listeners immediately to update UI
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update inventory status: $e';
      notifyListeners();
      return false;
    }
  }

  // Get inventory items by category
  List<Inventory> getInventoryByCategory(String categoryId) {
    return _inventoryItems.where((item) => item.categoryId == categoryId).toList();
  }

  // Get inventory items by status
  List<Inventory> getInventoryByStatus(String status) {
    return _inventoryItems.where((item) => item.status == status).toList();
  }
}
