# Menu-Inventory Relationship in BrewCode POS

## Current vs. Enhanced Approach

### Current Implementation
In the current implementation, menu items and inventory are indirectly connected through categories:

1. Both MenuItems and Inventory have a CategoryID field
2. The `sp_UpdateMenuItemAvailability` procedure marks menu items inactive based on category-level inventory status
3. This is a simplified approach that does not track which exact ingredients are needed for each menu item

### Enhanced Implementation
The enhanced approach (provided in `clear_tables_and_enhance.sql`) adds a direct relationship between menu items and inventory:

1. A new `MenuItemIngredients` junction table that simply links menu items to their required ingredients (without quantity tracking)
2. Updated stored procedures that use this relationship to determine menu item availability
3. Helper functions to manage these relationships

## How to Use the Enhanced System

### 1. Run the Script

Run the `clear_tables_and_enhance.sql` script to:
- Empty unnecessary data (customers, orders, most staff)
- Create the new junction table
- Create stored procedures for managing the relationship

```sql
-- From SQL Server Management Studio or another SQL client
USE KohiDB;
GO
-- Execute the full script
```

### 2. Link Menu Items to Ingredients

After creating menu items and inventory items, use the `sp_LinkMenuItemToIngredient` procedure to establish relationships:

```sql
-- Example: Link "Espresso" menu item to "Coffee Beans" inventory item
EXEC sp_LinkMenuItemToIngredient 
    @MenuItemID = 1,    -- Your menu item ID
    @InventoryID = 1;   -- Your inventory item ID
```

### 3. Update Menu Availability

When inventory status changes, call the procedure to update menu availability:

```sql
-- Update all menu items' availability based on ingredient status
EXEC sp_UpdateMenuAvailabilityByIngredients;
```

## Integration with Flutter App

To integrate this enhanced approach with your Flutter application:

### 1. Update Your Models

Add a new model for the menu-ingredient relationship:

```dart
// lib/models/menu_item_ingredient.dart
class MenuItemIngredient {
  final String menuItemId;
  final String inventoryId;
  final double quantity;
  
  MenuItemIngredient({
    required this.menuItemId,
    required this.inventoryId,
    required this.quantity,
  });
  
  factory MenuItemIngredient.fromJson(Map<String, dynamic> json) {
    return MenuItemIngredient(
      menuItemId: json['MenuItemID'].toString(),
      inventoryId: json['InventoryID'].toString(),
      quantity: double.parse(json['Quantity'].toString()),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'MenuItemID': menuItemId,
      'InventoryID': inventoryId,
      'Quantity': quantity,
    };
  }
}
```

### 2. Add Service Methods

Add methods to your services to manage these relationships:

```dart
// In your inventory_service.dart or product_service.dart

Future<void> linkMenuItemToIngredient(String menuItemId, String inventoryId, double quantity) async {
  final conn = await _dbConnection.connection;
  await conn.execute(
    'EXEC sp_LinkMenuItemToIngredient @MenuItemID, @InventoryID, @Quantity',
    {
      'MenuItemID': menuItemId,
      'InventoryID': inventoryId,
      'Quantity': quantity
    }
  );
}

Future<void> updateMenuAvailability() async {
  final conn = await _dbConnection.connection;
  await conn.execute('EXEC sp_UpdateMenuAvailabilityByIngredients');
}
```

### 3. Enhanced UI Components

Add UI components to manage these relationships, such as:

- A screen to assign ingredients to menu items
- Quantity inputs for each ingredient
- Real-time updates of menu availability when ingredient status changes

## Benefits of This Approach

1. **Precise Availability**: Menu items are only available if ALL their required ingredients are available
2. **Flexible Relationships**: Each menu item can require multiple ingredients in specific quantities
3. **Better Inventory Management**: Clear understanding of which ingredients are used in which products

## Example Scenario

1. You have a "Cappuccino" menu item
2. It requires:
   - Coffee Beans (30g)
   - Milk (150ml)
3. If either Coffee Beans or Milk inventory status becomes "Not Available":
   - The Cappuccino menu item is automatically marked as inactive
   - It will not appear in the menu or will show as unavailable
