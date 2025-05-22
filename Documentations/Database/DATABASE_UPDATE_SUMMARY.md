# BrewCode POS System - Database and Model Updates

## Overview

This document summarizes the changes made to the BrewCode POS system to simplify the database structure and implement a direct relationship between menu items and inventory items without quantity tracking.

## Changes Made

### 1. CSV Files Cleanup

The following CSV files have been emptied to provide a clean start (headers only):
- `customers.csv` - Customer records
- `order_items.csv` - Order item details
- `orders.csv` - Order records
- `transactions.csv` - Transaction records

Staff data has been reduced to a single entry:
- `staff.csv` - Only one staff member retained (Anna Garcia)

### 2. Menu-Inventory Relationship Enhancement

We've created a simplified direct relationship between menu items and their required ingredients:

**Added Tables:**
- `MenuItemIngredients` - A junction table that links menu items to their required inventory items (without quantity tracking)

**Added Stored Procedures:**
- `sp_LinkMenuItemToIngredient` - Links a menu item to an inventory item
- `sp_UpdateMenuAvailabilityByIngredients` - Updates menu item availability based on ingredient status

**How It Works:**
1. Menu items are linked to their required inventory items in the junction table
2. When an inventory item's status changes to "Not Available", all menu items that require that ingredient are marked as inactive
3. When all ingredients for a menu item are "Available", the menu item is marked as active

### 3. Flutter App Integration

Added new model and service classes to support the menu-inventory relationship:

**New Model:**
- `MenuItemIngredient` - Represents the relationship between a menu item and an inventory item

**New Service:**
- `MenuIngredientService` - Provides methods to:
  - Get ingredients for a menu item
  - Find menu items using a specific ingredient
  - Link/unlink menu items and ingredients
  - Update menu item availability based on ingredient status

## Implementation Files

1. **Database Scripts:**
   - `Database/clear_tables_and_enhance.sql` - Script to clear tables and create the menu-inventory relationship
   - `Database/menu_ingredient_examples.sql` - Examples of how to use the new relationship

2. **Documentation:**
   - `Database/MENU_INVENTORY_RELATIONSHIP.md` - Detailed documentation of the menu-inventory relationship

3. **Flutter Model/Service:**
   - `lib/models/menu_item_ingredient.dart` - Model class for the menu-inventory relationship
   - `lib/services/menu_ingredient_service.dart` - Service class for managing the relationship

## How to Use the New Menu-Inventory Relationship

### In SQL Server

1. **Link a menu item to an ingredient:**
   ```sql
   EXEC sp_LinkMenuItemToIngredient 
       @MenuItemID = 1,   -- Your menu item ID
       @InventoryID = 2;  -- Your inventory item ID
   ```

2. **Update menu item availability based on ingredients:**
   ```sql
   EXEC sp_UpdateMenuAvailabilityByIngredients;
   ```

### In the Flutter App

1. **Link a menu item to an ingredient:**
   ```dart
   final menuIngredientService = MenuIngredientService();
   await menuIngredientService.linkMenuItemToIngredient('1', '2');
   ```

2. **Update availability when inventory status changes:**
   ```dart
   final menuIngredientService = MenuIngredientService();
   await menuIngredientService.updateMenuItemAvailability();
   ```

## Benefits of This Approach

1. **Simplified Data Model** - No need to track quantities, just the presence or absence of a relationship
2. **Clear Dependencies** - Menu items explicitly depend on their required ingredients
3. **Automatic Availability** - Menu item availability is automatically updated based on ingredient status
4. **Reduced Complexity** - Easier to maintain and understand than a more complex inventory system

## Next Steps

1. Complete the implementation of the database integration
2. Add UI components to manage menu-ingredient relationships
3. Test the system to ensure menu items are correctly marked as available/unavailable based on ingredient status
