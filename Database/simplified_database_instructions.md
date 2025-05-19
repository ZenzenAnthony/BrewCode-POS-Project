# Simplified Food Business Database - Documentation

## Overview

This is a simplified database for a food and beverage business. It has been modified to focus on essential data while removing unnecessary complexity. The database manages:

- Basic inventory of ingredients and supplies
- Menu items/products
- Basic customer information
- Staff records
- Orders and order details
- Categories for organizing products and inventory

## Changes Made

The following simplifications have been made to the database:

1. **Removed Units of Measure** - Items are now tracked without specific units
2. **Removed Supplier Information** - Supplier management has been removed
3. **Removed Stock Management** - No tracking of current stock or minimum stock levels
4. **Removed Discounts and Tax** - Pricing is simplified without these components
5. **Simplified Inventory** - Removed expiry dates and storage locations
6. **Simplified Staff Records** - Only names are stored, removed position, contact info, etc.
7. **Simplified Menu Items** - Removed cost and preparation time tracking
8. **Simplified Orders** - Removed table numbers, payment methods, and tax info
9. **Simplified Customer Info** - Only storing names and notes

## Database Structure

The simplified database consists of the following tables:

### Core Tables

1. **Categories** - Hierarchical categories for both inventory and menu items
   - CategoryID, CategoryName, Description, ParentCategoryID, Active

2. **Inventory** - All ingredients and supplies
   - InventoryID, ItemName, CategoryID, Notes

3. **Staff** - Basic employee information
   - StaffID, FirstName, LastName

4. **Customers** - Basic customer information
   - CustomerID, FirstName, LastName, Notes

5. **MenuItems** - Products you sell to customers
   - ItemID, ItemName, CategoryID, Description, Price, Recipe, ImagePath, Active

6. **MenuItemIngredients** - Links menu items to their required ingredients
   - MenuItemID, InventoryID, Quantity

7. **Orders** - Order header information
   - OrderID, CustomerID, StaffID, OrderDate, OrderType, OrderStatus, TotalAmount, PaymentStatus, Notes

8. **OrderItems** - Individual items within each order
   - OrderItemID, OrderID, ItemID, Quantity, UnitPrice, Notes

## Basic Usage

### Working with Orders

**Create a new order:**
```sql
-- Create a new order
DECLARE @OrderID INT;
EXEC @OrderID = sp_PlaceOrder 
    @CustomerID = 1, 
    @StaffID = 3, 
    @OrderType = 'Dine-in';

-- Add items to the order
EXEC sp_AddOrderItem @OrderID = @OrderID, @ItemID = 1, @Quantity = 2;
EXEC sp_AddOrderItem @OrderID = @OrderID, @ItemID = 3, @Quantity = 1;
```

**Query orders by customer:**
```sql
SELECT o.OrderID, o.OrderDate, o.TotalAmount, o.OrderStatus, 
       c.FirstName + ' ' + c.LastName AS CustomerName
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.CustomerID = 1
ORDER BY o.OrderDate DESC;
```

### Menu Management

**Add a new menu item:**
```sql
INSERT INTO MenuItems (ItemName, CategoryID, Description, Price, Active)
VALUES ('New Dish', 1, 'Description of the dish', 150.00, 1);
```

**Get all menu items in a category:**
```sql
SELECT * FROM vw_MenuItemsWithCategories 
WHERE CategoryName = 'Chicken Dishes'
ORDER BY Price;
```

### Working with Inventory

**Add new inventory items:**
```sql
INSERT INTO Inventory (ItemName, CategoryID)
VALUES ('New Ingredient', 1);
```

**Get all ingredients in a category:**
```sql
SELECT i.InventoryID, i.ItemName, c.CategoryName
FROM Inventory i
JOIN Categories c ON i.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Food Ingredients'
ORDER BY i.ItemName;
```

## Views and Reports

The database includes the following views for reporting:

1. **vw_MenuItemsWithCategories** - Shows menu items with their categories
2. **vw_DailySalesReport** - Provides daily sales summary information
3. **vw_TopSellingItems** - Shows best-selling products by quantity and revenue

Example usage:
```sql
-- Get sales breakdown by day
SELECT * FROM vw_DailySalesReport 
ORDER BY OrderDate DESC;

-- Get top selling items
SELECT TOP 5 * FROM vw_TopSellingItems 
ORDER BY TotalQuantitySold DESC;
```

## Setup Instructions

1. Open SQL Server Management Studio (SSMS)
2. Connect to your SQL Server instance
3. Open the `simplified_food_business_database.sql` file
4. Click the "Execute" button (or press F5)
5. The database will be created with all tables, views, and sample data

If you don't see the database in Object Explorer after running the script:
- Refresh the Databases node in Object Explorer
- Check for error messages in the Messages tab
- Make sure you have permission to create databases
