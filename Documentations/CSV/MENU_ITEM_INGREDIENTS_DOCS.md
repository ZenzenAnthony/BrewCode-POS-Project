# Menu-Item-Ingredients CSV File Documentation

## Overview

The `menu_item_ingredients.csv` file defines the relationships between menu items and their required inventory items. This file is used to populate the `MenuItemIngredients` junction table in the database, which creates direct links between specific menu items and the inventory items they require.

## File Structure

The CSV file has a simple structure with three columns:

```
MenuItemIngredientID,MenuItemID,InventoryID
```

- **MenuItemIngredientID**: A unique identifier for each relationship record
- **MenuItemID**: The ID of the menu item (references `ItemID` in the `MenuItems` table)
- **InventoryID**: The ID of the inventory item (references `InventoryID` in the `Inventory` table)

## Example Data

The provided example data links menu items to their required ingredients. For example:

```
1,1,1    # Menu item 1 requires inventory item 1
2,1,3    # Menu item 1 also requires inventory item 3
```

This shows that Menu Item #1 (e.g., "Cappuccino") requires both Inventory Item #1 (e.g., "Coffee Beans") and Inventory Item #3 (e.g., "Milk").

## How This Data Is Used

When the database is initialized:
1. The CSV file is imported into the `MenuItemIngredients` table
2. These relationships are used to determine menu item availability
3. If any ingredient is marked as "Not Available", all menu items requiring it become unavailable

## Maintaining This File

When adding new menu items or inventory items:

1. **Add new menu items** to `menu_items_updated.csv`
2. **Add new inventory items** to `inventory_updated.csv`
3. **Add relationships** between them in `menu_item_ingredients.csv`

For example, if you add a new "Mocha" menu item with ID 10 that requires Coffee Beans (ID 1), Milk (ID 3), and Chocolate Syrup (ID 7):

```
20,10,1  # Mocha requires Coffee Beans
21,10,3  # Mocha requires Milk
22,10,7  # Mocha requires Chocolate Syrup
```

## Importing Into The Database

The relationships defined in this file are automatically imported into the database when running the import scripts:

- SQL Server script: `import_csv_to_sql_with_menu_inventory.sql`
- MySQL script: `mysql_import_script_with_menu_inventory.sql`

## Testing Relationships

After importing the data, you can test the relationships with:

```sql
-- Find all ingredients required for a specific menu item
SELECT i.ItemName AS InventoryItem, i.Status
FROM Inventory i
JOIN MenuItemIngredients mi ON i.InventoryID = mi.InventoryID
WHERE mi.MenuItemID = 1;  -- Change to the menu item you want to check

-- Find all menu items that require a specific ingredient
SELECT m.ItemName AS MenuItem, m.Active
FROM MenuItems m
JOIN MenuItemIngredients mi ON m.ItemID = mi.MenuItemID
WHERE mi.InventoryID = 3;  -- Change to the inventory item you want to check
```
