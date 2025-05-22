# CSV Database Files for Kohi Database

This folder contains CSV files extracted from the KohiDB SQL database to make customization easier.

## Files Included

1. `categories.csv` - Food and menu categories
2. `inventory.csv` - Inventory items (ingredients, packaging)
3. `staff.csv` - Staff members
4. `customers.csv` - Customer information
5. `menu_items.csv` - Menu items with prices
6. `orders.csv` - Order information
7. `order_items.csv` - Items included in orders
8. `menu_item_ingredients.csv` - Links menu items to their inventory ingredients

## How to Use

1. Edit these CSV files using a spreadsheet program like Microsoft Excel or Google Sheets.
2. You can add, remove, or modify rows as needed.
3. Make sure to maintain the CSV format (comma-separated values).
4. For new entries, you can leave the ID fields empty and they will be auto-assigned when imported.
5. For relationships between tables, use the appropriate ID values that exist in the referenced tables.

## Importing Back to SQL

Once you've customized the CSV files, you can import them back into your SQL database using:

1. SQL Server's bulk import capabilities
2. SQL Server Management Studio's import wizard
3. A custom import script

## Common Customizations

1. Add new menu items by editing `menu_items.csv`
2. Add new inventory items in `inventory.csv`
3. Define ingredients for menu items in `menu_item_ingredients.csv`
4. Add or modify food categories in `categories.csv`

## Field Descriptions

### categories.csv
- CategoryID: Unique identifier
- CategoryName: Name of the category
- Description: Description of the category
- ParentCategoryID: ID of the parent category (if this is a subcategory)
- Active: 1 = active, 0 = inactive

### inventory.csv
- InventoryID: Unique identifier
- ItemName: Name of the inventory item
- CategoryID: Category this item belongs to
- Notes: Additional notes about the item

### staff.csv
- StaffID: Unique identifier
- FirstName: Staff member's first name
- LastName: Staff member's last name

### customers.csv
- CustomerID: Unique identifier
- FirstName: Customer's first name
- LastName: Customer's last name
- Notes: Additional information about the customer

### menu_items.csv
- ItemID: Unique identifier
- ItemName: Name of the menu item
- CategoryID: Category this menu item belongs to
- Description: Description of the menu item
- Price: Price of the item
- Recipe: Preparation instructions (optional)
- ImagePath: Path to image file (optional)
- Active: 1 = active, 0 = inactive

### orders.csv
- OrderID: Unique identifier
- CustomerID: ID of the customer who placed the order
- StaffID: ID of the staff who handled the order
- OrderDate: Date and time of the order
- OrderType: 'Dine-in', 'Takeout', or 'Delivery'
- OrderStatus: 'Pending', 'Preparing', 'Ready', 'Delivered', 'Completed', or 'Cancelled'
- TotalAmount: Total amount of the order
- PaymentStatus: 'Unpaid', 'Paid', or 'Refunded'
- Notes: Additional order notes

### order_items.csv
- OrderItemID: Unique identifier
- OrderID: ID of the order this item belongs to
- ItemID: ID of the menu item
- Quantity: Number of items ordered
- UnitPrice: Price per item
- Notes: Special instructions for this item

### menu_item_ingredients.csv
- MenuItemID: ID of the menu item
- InventoryID: ID of the inventory item used
- Quantity: Amount of the inventory item needed
