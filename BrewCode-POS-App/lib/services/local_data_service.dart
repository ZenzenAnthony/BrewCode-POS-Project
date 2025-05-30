// lib/services/local_data_service.dart
// Refactored LocalDataService - now orchestrates separate domain services

import 'package:flutter/foundation.dart' hide Category;
import '../models/menu_item.dart';
import '../models/inventory.dart';
import '../models/order.dart';
import '../models/transaction.dart';
import '../models/category.dart';

// Import the new domain services
import 'category_service.dart';
import 'menu_service.dart';
import 'inventory_service.dart';
import 'menu_ingredient_service.dart';

class LocalDataService {
  // Singleton pattern
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;
  LocalDataService._internal() {
    _initializeServices();
  }

  // Domain services
  late final CategoryService _categoryService;
  late final MenuService _menuService;
  late final InventoryService _inventoryService;
  final MenuIngredientService _menuIngredientService = MenuIngredientService();

  // Initialize all domain services
  void _initializeServices() {
    _categoryService = CategoryService();
    _menuService = MenuService();
    _inventoryService = InventoryService();

    // Set up inventory change callback for menu availability updates
    _inventoryService.setInventoryChangeCallback(_notifyMenuAvailabilityChanged);
  }
  // Callback for notifying when menu availability changes
  VoidCallback? _onMenuAvailabilityChanged;
  
  // Set callback for menu availability changes
  void setMenuAvailabilityChangeCallback(VoidCallback callback) {
    _onMenuAvailabilityChanged = callback;
  }
  
  // Trigger menu availability change callback
  void _notifyMenuAvailabilityChanged() {
    _onMenuAvailabilityChanged?.call();
  }

  // Local storage for orders and transactions (non-domain specific)
  final List<Order> _orders = [];
  final List<Transaction> _transactions = [];
  int _nextOrderId = 1;

  // ========== ORDER AND TRANSACTION GETTERS ==========
  List<Order> get orders => [..._orders];

  // ========== CATEGORY OPERATIONS ==========
  List<Category> get categories => _categoryService.categories;
  Category? getCategoryById(int categoryId) => _categoryService.getCategoryById(categoryId);
  List<Category> getFoodCategories() => _categoryService.getFoodCategories();
  List<Category> getDrinkCategories() => _categoryService.getDrinkCategories();
  List<Category> getMainCategories() => _categoryService.getMainCategories();
  List<Category> getSubCategories(int parentCategoryId) => _categoryService.getSubCategories(parentCategoryId);

  // ========== MENU OPERATIONS ==========
  List<MenuItem> get menuItems => _menuService.menuItems;
  MenuItem? getMenuItemById(int itemId) => _menuService.getMenuItemById(itemId);
  List<MenuItem> getMenuItemsByCategory(int categoryId) => _menuService.getMenuItemsByCategory(categoryId);
  List<MenuItem> searchMenuItems(String query) => _menuService.searchMenuItems(query);
  MenuItem? findMenuItemByName(String itemName) => _menuService.findMenuItemByName(itemName);

  // ========== MENU AVAILABILITY OPERATIONS ==========
    /// Check if a menu item is available based on ingredient availability
  bool isMenuItemAvailable(String menuItemId) {
    final ingredientIds = _menuIngredientService.getIngredientIdsForMenuItem(menuItemId);

    if (ingredientIds.isEmpty) {
      return true;
    }

    for (final ingredientId in ingredientIds) {
      final ingredient = getInventoryById(ingredientId);
      if (ingredient == null || ingredient.status == 'Not Available') {
        return false;
      }
    }

    return true;
  }
  
  /// Check if a menu item has any low stock ingredients
  bool hasMenuItemLowStockIngredients(String menuItemId) {
    final ingredientIds = _menuIngredientService.getIngredientIdsForMenuItem(menuItemId);

    for (final ingredientId in ingredientIds) {
      final ingredient = getInventoryById(ingredientId);
      if (ingredient != null && ingredient.status == 'Low Stock') {
        return true;
      }
    }

    return false;
  }
    /// Get ingredient objects for a menu item
  List<Inventory> getIngredientsForMenuItem(String menuItemId) {
    final ingredientIds = _menuIngredientService.getIngredientIdsForMenuItem(menuItemId);
    final ingredients = <Inventory>[];
    
    for (final ingredientId in ingredientIds) {
      final ingredient = getInventoryById(ingredientId);
      if (ingredient != null) {
        ingredients.add(ingredient);
      }
    }
    
    return ingredients;
  }
  
  // ========== INVENTORY OPERATIONS ==========
  List<Inventory> get inventory => _inventoryService.inventory;
  Inventory? getInventoryById(String inventoryId) => _inventoryService.getInventoryById(inventoryId);
  List<Inventory> getInventoryByCategory(int categoryId) => _inventoryService.getInventoryByCategory(categoryId.toString());
  List<Inventory> getInventoryByStatus(String status) => _inventoryService.getInventoryByStatus(status);
  List<Inventory> searchInventory(String query) => _inventoryService.searchInventory(query);
  
  bool updateInventoryStatus(int inventoryId, String newStatus) {
    return _inventoryService.updateInventoryStatus(inventoryId, newStatus);
  }  bool updateInventoryStatusWithMenuCheck(int inventoryId, String newStatus) {
    final success = updateInventoryStatus(inventoryId, newStatus);
    
    if (success) {
      // Notify that menu availability has changed
      _notifyMenuAvailabilityChanged();
    }
    return success;
  }

  // ========== ORDER OPERATIONS ==========
  Future<Order> createOrder({
    required String customerId,
    required String orderType,
    required List<OrderItem> items,
    String? notes,
  }) async {
    final totalAmount = items.fold<double>(
      0.0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );

    final order = Order(
      id: _nextOrderId.toString(),
      customerId: customerId,
      orderDate: DateTime.now(),
      orderType: orderType,
      orderStatus: 'Pending',
      totalAmount: totalAmount,
      items: [],
      notes: notes,
    );

    _orders.add(order);
    _nextOrderId++;

    return order;
  }

  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.orderStatus == status).toList();
  }

  bool updateOrderStatus(String orderId, String newStatus) {
    try {
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        final oldOrder = _orders[orderIndex];
        final updatedOrder = Order(
          id: oldOrder.id,
          customerId: oldOrder.customerId,
          orderDate: oldOrder.orderDate,
          orderType: oldOrder.orderType,
          orderStatus: newStatus,
          totalAmount: oldOrder.totalAmount,
          items: oldOrder.items,
          notes: oldOrder.notes,
        );
        _orders[orderIndex] = updatedOrder;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ========== TRANSACTION OPERATIONS ==========
  void addOrder(Transaction transaction) {
    // Convert Transaction to Order for storage in orders list
    final order = Order(
      id: transaction.id?.toString(),
      customerId: transaction.customerName,
      orderDate: transaction.orderDate,
      orderType: 'Sale',
      orderStatus: 'Completed',
      totalAmount: transaction.totalAmount,
      items: [],
      notes: transaction.paymentMethod,
    );
    
    _orders.add(order);
    _transactions.add(transaction);
  }

  List<Transaction> get transactions => [..._transactions];

  // Update a transaction
  bool updateTransaction(Transaction updatedTransaction) {
    try {
      final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
      if (index >= 0) {
        _transactions[index] = updatedTransaction;
        
        // Also update corresponding order if it exists
        final orderIndex = _orders.indexWhere((o) => o.id == updatedTransaction.id?.toString());
        if (orderIndex >= 0) {
          final updatedOrder = Order(
            id: updatedTransaction.id?.toString(),
            customerId: updatedTransaction.customerName,
            orderDate: updatedTransaction.orderDate,
            orderType: updatedTransaction.orderType ?? 'Sale',
            orderStatus: updatedTransaction.isCompleted ? 'Completed' : 'Pending',
            totalAmount: updatedTransaction.totalAmount,
            items: [],
            notes: updatedTransaction.paymentMethod,
          );
          _orders[orderIndex] = updatedOrder;
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      return false;
    }
  }

  // Delete a transaction
  bool deleteTransaction(int transactionId) {
    try {
      final transactionIndex = _transactions.indexWhere((t) => t.id == transactionId);
      if (transactionIndex >= 0) {
        _transactions.removeAt(transactionIndex);
        
        // Also remove corresponding order if it exists
        final orderIndex = _orders.indexWhere((o) => o.id == transactionId.toString());
        if (orderIndex >= 0) {
          _orders.removeAt(orderIndex);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }

  // ========== ANALYTICS & REPORTS ==========
  Map<String, dynamic> getDashboardStats() {
    final totalOrders = _orders.length;
    final completedOrders = _orders.where((order) => order.orderStatus == 'Completed').length;
    final pendingOrders = _orders.where((order) => order.orderStatus == 'Pending').length;
    final totalRevenue = _transactions.fold<double>(0.0, (sum, transaction) => sum + transaction.totalAmount);
    
    final availableInventory = inventory.where((item) => item.status == 'Available').length;
    final lowStockInventory = inventory.where((item) => item.status == 'Low Stock').length;
    final outOfStockInventory = inventory.where((item) => item.status == 'Not Available').length;

    return {
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'pendingOrders': pendingOrders,
      'totalRevenue': totalRevenue,
      'availableInventory': availableInventory,
      'lowStockInventory': lowStockInventory,
      'outOfStockInventory': outOfStockInventory,
    };
  }

  List<Map<String, dynamic>> getTopSellingItems({int limit = 10}) {
    final Map<String, int> itemSales = {};
    final Map<String, double> itemRevenue = {};

    for (final transaction in _transactions) {
      for (final item in transaction.items) {
        itemSales[item.productName] = (itemSales[item.productName] ?? 0) + item.quantity;
        itemRevenue[item.productName] = (itemRevenue[item.productName] ?? 0.0) + (item.unitPrice * item.quantity);
      }
    }

    final sortedItems = itemSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedItems.take(limit).map((entry) => {
      'itemName': entry.key,
      'totalQuantitySold': entry.value,
      'totalRevenue': itemRevenue[entry.key] ?? 0.0,
    }).toList();
  }

  Map<String, double> getRevenueByCategory() {
    final Map<String, double> categoryRevenue = {};

    for (final transaction in _transactions) {
      for (final item in transaction.items) {
        // Find the menu item to get its category
        final menuItem = menuItems.where((mi) => mi.name == item.productName).firstOrNull;
        if (menuItem != null) {
          final category = categories.where((cat) => cat.categoryId == menuItem.categoryId).firstOrNull;
          if (category != null) {
            categoryRevenue[category.categoryName] = 
                (categoryRevenue[category.categoryName] ?? 0.0) + (item.unitPrice * item.quantity);
          }
        }
      }
    }

    return categoryRevenue;
  }
  // ========== UTILITY OPERATIONS ==========
  void clearAllData() {
    _orders.clear();
    _transactions.clear();
    _nextOrderId = 1;
  }

  Future<Map<String, dynamic>> testConnection() async {
    // Simulate connection test delay
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'success': true,
      'database': 'Local data service active',
      'menuItems': menuItems.length,
      'inventory': inventory.length,
      'categories': categories.length,
      'orders': _orders.length,
      'transactions': _transactions.length,
    };
  }

  Map<String, dynamic> getServiceStatus() {
    return {
      'status': 'active',
      'database': 'Local data service active',
      'menuItems': menuItems.length,
      'inventory': inventory.length,
      'categories': categories.length,
      'orders': _orders.length,
      'transactions': _transactions.length,
    };
  }
}

// OrderItem model for local use
class OrderItem {
  final int orderitemId;
  final int orderId;
  final String itemName;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.orderitemId,
    required this.orderId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
  });
}