# BrewCode POS Database Integration Plan

## Overview

This document outlines the plan for integrating the Flutter application with the SQL Server database according to the updated database structure. Currently, the application uses placeholder services that simulate database operations while allowing the front-end to function independently.

## Current Architecture

1. **Flutter Application**
   - Uses Provider pattern for state management
   - Has placeholder service classes that simulate database operations
   - Models match the updated database schema

2. **SQL Server Database**
   - Simplified structure with status-based inventory tracking
   - Stored procedures for key operations (sp_CompleteOrder, sp_GetCompletedTransactions)
   - CSV files for initial data population

## Integration Steps

### 1. Database Connection Setup

1. **Add Required Dependencies**
   ```yaml
   dependencies:
     # For SQL Server
     mssql: ^1.0.0
   ```

2. **Create Database Connection Class**
   ```dart
   // lib/services/database_connection.dart
   class DatabaseConnection {
     static final DatabaseConnection _instance = DatabaseConnection._internal();
     factory DatabaseConnection() => _instance;
     DatabaseConnection._internal();
     
     late Connection _connection;
     
     Future<Connection> get connection async {
       if (_connection != null) return _connection;
       _connection = await _openConnection();
       return _connection;
     }
     
     Future<Connection> _openConnection() async {
       // Connection details
       final conn = await SqlConnection.connect(
         host: 'your_server',
         port: 1433,
         db: 'KohiDB',
         user: 'your_user',
         password: 'your_password',
       );
       return conn;
     }
   }
   ```

### 2. Replace Placeholder Services with Real Implementations

#### Product Service
```dart
// lib/services/product_service.dart
class ProductService {
  final _dbConnection = DatabaseConnection();
  
  Future<List<Product>> getProducts() async {
    final conn = await _dbConnection.connection;
    final results = await conn.query('SELECT m.*, c.CategoryName FROM MenuItems m JOIN Categories c ON m.CategoryID = c.CategoryID WHERE m.Active = 1');
    
    return results.map((row) => Product.fromJson(row)).toList();
  }
}
```

#### Inventory Service
```dart
// lib/services/inventory_service.dart
class InventoryService {
  final _dbConnection = DatabaseConnection();
  
  Future<List<Inventory>> getAllInventoryItems() async {
    final conn = await _dbConnection.connection;
    final results = await conn.query('SELECT * FROM Inventory');
    
    return results.map((row) => Inventory.fromJson(row)).toList();
  }
  
  Future<bool> updateInventoryStatus(String inventoryId, String newStatus) async {
    final conn = await _dbConnection.connection;
    
    try {
      // Start a transaction
      await conn.startTransaction();
      
      // Update inventory status
      final result = await conn.execute(
        'UPDATE Inventory SET Status = @newStatus WHERE InventoryID = @inventoryId',
        {'newStatus': newStatus, 'inventoryId': inventoryId}
      );
      
      // If status was updated, also update menu availability
      if (result.affectedRows > 0) {
        await conn.execute('EXEC sp_UpdateMenuAvailabilityByIngredients');
      }
      
      // Commit the transaction
      await conn.commit();
      
      return result.affectedRows > 0;
    } catch (e) {
      // Rollback on error
      await conn.rollback();
      print('Error updating inventory status: $e');
      return false;
    }
  }
}
```

#### Menu Ingredient Service
```dart
// lib/services/menu_ingredient_service.dart
class MenuIngredientService {
  final _dbConnection = DatabaseConnection();
  
  Future<List<MenuItemIngredient>> getIngredientsForMenuItem(String menuItemId) async {
    final conn = await _dbConnection.connection;
    final results = await conn.query(
      'SELECT * FROM MenuItemIngredients WHERE MenuItemID = @menuItemId',
      {'menuItemId': menuItemId}
    );
    
    return results.map((row) => MenuItemIngredient.fromJson(row)).toList();
  }

  Future<List<String>> getMenuItemsUsingIngredient(String inventoryId) async {
    final conn = await _dbConnection.connection;
    final results = await conn.query(
      'SELECT m.ItemName FROM MenuItems m ' +
      'JOIN MenuItemIngredients mi ON m.ItemID = mi.MenuItemID ' +
      'WHERE mi.InventoryID = @inventoryId',
      {'inventoryId': inventoryId}
    );
    
    return results.map((row) => row['ItemName'] as String).toList();
  }

  Future<bool> linkMenuItemToIngredient(String menuItemId, String inventoryId) async {
    final conn = await _dbConnection.connection;
    
    try {
      await conn.execute(
        'EXEC sp_LinkMenuItemToIngredient @MenuItemID, @InventoryID',
        {'MenuItemID': menuItemId, 'InventoryID': inventoryId}
      );
      
      return true;
    } catch (e) {
      print('Error linking menu item to ingredient: $e');
      return false;
    }
  }
}
```

#### Order Service
```dart
// lib/services/order_service.dart
class OrderService {
  final _dbConnection = DatabaseConnection();
  
  Future<String?> createOrder({
    String? customerId,
    required String staffId,
    required String orderType,
    required List<CartItem> items,
    required double totalAmount,
    String? notes,
  }) async {
    final conn = await _dbConnection.connection;
    
    // Start a transaction
    await conn.startTransaction();
    
    try {
      // Create order
      final orderResult = await conn.execute(
        'INSERT INTO Orders (CustomerID, StaffID, OrderType, TotalAmount, Notes) VALUES (@customerId, @staffId, @orderType, @totalAmount, @notes); SELECT SCOPE_IDENTITY() AS OrderID',
        {
          'customerId': customerId,
          'staffId': staffId,
          'orderType': orderType,
          'totalAmount': totalAmount,
          'notes': notes
        }
      );
      
      final orderId = orderResult.first['OrderID'];
      
      // Add order items
      for (var item in items) {
        await conn.execute(
          'INSERT INTO OrderItems (OrderID, ItemID, Quantity, UnitPrice, Notes) VALUES (@orderId, @itemId, @quantity, @unitPrice, @notes)',
          {
            'orderId': orderId,
            'itemId': item.product.id,
            'quantity': item.quantity,
            'unitPrice': item.product.price,
            'notes': null
          }
        );
      }
      
      // Commit the transaction
      await conn.commit();
      
      return orderId.toString();
    } catch (e) {
      // Rollback on error
      await conn.rollback();
      print('Error creating order: $e');
      return null;
    }
  }
  
  Future<Map<String, dynamic>> completeOrder(String orderId, String customerInitials) async {
    final conn = await _dbConnection.connection;
    
    try {
      // Execute stored procedure
      final result = await conn.execute(
        'EXEC sp_CompleteOrder @OrderID, @CustomerInitials',
        {'OrderID': orderId, 'CustomerInitials': customerInitials}
      );
      
      return {
        'success': true,
        'receiptNumber': result.first['ReceiptNumber'],
        'message': result.first['Result']
      };
    } catch (e) {
      print('Error completing order: $e');
      return {'success': false, 'message': 'Failed to complete order: $e'};
    }
  }
}
```

### 3. Update Provider Classes to Use Real Services

Modify the provider classes to use the real service implementations instead of the placeholders.

### 4. Testing Plan

1. **Unit Tests**
   - Create unit tests for each service method
   - Use mock database connections for testing

2. **Integration Tests**
   - Set up a test database with sample data
   - Test the end-to-end flow from creating an order to completing it

3. **UI Tests**
   - Ensure the UI correctly displays data from the database
   - Test error handling and loading states

## Fallback Strategy

In case of database connection issues, implement a fallback strategy:

1. **Offline Support**
   - Cache frequently accessed data like menu items
   - Implement a queue for pending operations

2. **Error Handling**
   - Display user-friendly error messages
   - Retry failed operations with exponential backoff

## Timeline

1. **Phase 1 (Week 1-2)**
   - Set up database connection
   - Implement basic read operations

2. **Phase 2 (Week 3-4)**
   - Implement write operations
   - Connect providers to real services

3. **Phase 3 (Week 5)**
   - Testing and debugging
   - Optimization and performance tuning

## Conclusion

This integration plan provides a structured approach to connecting the Flutter application to the SQL Server database. By following these steps, we can ensure a smooth transition from the placeholder services to real database operations while maintaining the application's functionality and user experience.
