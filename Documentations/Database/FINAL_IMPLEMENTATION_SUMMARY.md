# Menu-Inventory Relationship in BrewCode POS - Final Implementation

## Overview

This document explains the final implementation of the menu-inventory relationship in the BrewCode POS system.

## Original vs. Enhanced Approach

### Original Approach (Categories-Based)
In the original database structure, menu items and inventory were indirectly linked through categories:
- MenuItems had a CategoryID
- Inventory items had a CategoryID
- There was no direct link between specific menu items and the inventory items they required

This made it difficult to track which exact inventory items were needed for each menu item.

### Enhanced Approach (Direct Relationship)
The enhanced implementation adds a direct relationship between menu items and their required ingredients:
- A new `MenuItemIngredients` junction table links menu items directly to required inventory items
- No quantity tracking (simplified approach)
- Menu items are automatically marked as unavailable if any of their required ingredients are not available

## Database Structure

The new database structure includes:

```
MenuItemIngredients
- MenuItemIngredientID (PK)
- MenuItemID (FK to MenuItems.ItemID)
- InventoryID (FK to Inventory.InventoryID)
```

## Key Stored Procedures

1. **sp_LinkMenuItemToIngredient**
   - Links a menu item to an inventory item
   - Prevents duplicate relationships

2. **sp_UpdateMenuAvailabilityByIngredients**
   - Updates all menu items' availability based on their ingredients' status
   - Menu items are marked inactive if ANY of their required ingredients are "Not Available"

## Implementation Files

1. **SQL Import Scripts**
   - `import_csv_to_sql_with_menu_inventory.sql` (SQL Server version)
   - `mysql_import_script_with_menu_inventory.sql` (MySQL version)

2. **Model Files**
   - `models/menu_item_ingredient.dart` - Model class for the menu-inventory relationship

3. **Service Files**
   - `services/menu_ingredient_service.dart` - Service for managing menu-inventory relationships

## How to Use the Menu-Inventory Connection

### Using SQL

1. **Link a menu item to an ingredient:**
   ```sql
   EXEC sp_LinkMenuItemToIngredient @MenuItemID=1, @InventoryID=2;
   ```

2. **Update menu availability when inventory changes:**
   ```sql
   -- After changing an inventory item's status:
   UPDATE Inventory SET Status = 'Not Available' WHERE InventoryID = 1;
   
   -- Update menu item availability:
   EXEC sp_UpdateMenuAvailabilityByIngredients;
   ```

### Using Flutter App

1. **Link a menu item to an ingredient:**
   ```dart
   await menuIngredientService.linkMenuItemToIngredient(menuItemId, inventoryId);
   ```

2. **Update availability when inventory changes:**
   ```dart
   // When updating inventory status:
   await inventoryService.updateInventoryStatus(inventoryId, 'Not Available');
   // This will automatically call sp_UpdateMenuAvailabilityByIngredients
   ```

## Benefits

1. **Direct Relationship**: Each menu item explicitly defines which inventory items it requires
2. **Automatic Availability**: Menu items are automatically marked as available/unavailable
3. **Simplified Management**: No need to track quantities, just focus on ingredient availability
4. **Clear Dependencies**: Easy to see which menu items are affected by inventory changes

With these changes, the BrewCode POS system now has a proper relationship between menu items and inventory, ensuring customers can only order items that can actually be made.
