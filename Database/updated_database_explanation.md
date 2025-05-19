# BrewCode POS System - Updated Database Structure

## Database Overview

The BrewCode POS system uses a streamlined database structure focused on ease of use while maintaining all necessary functionality for a café/restaurant operation. The database has been updated to reflect your specific requirements.

## Key Tables

### 1. Categories
Organizes both menu items and inventory into logical groups.
- **CategoryID**: Primary key
- **CategoryName**: Name of the category (e.g., "Rice Meal", "Kōhi Based", etc.)
- **Description**: Description of the category
- **ParentCategoryID**: Self-referencing foreign key for hierarchical categories
- **Active**: Boolean indicating if the category is active

### 2. Inventory
Tracks ingredients and their availability status.
- **InventoryID**: Primary key
- **ItemName**: Name of the ingredient (e.g., "Chicken", "Coffee Beans")
- **CategoryID**: Foreign key to Categories table
- **Unit**: Unit of measurement (e.g., "kilo", "bottle", "pack")
- **Status**: Current status ("Available", "Not Available", "Low Stock")
- **Notes**: Additional notes

### 3. MenuItems
Represents food and drink items available for order.
- **ItemID**: Primary key
- **ItemName**: Name of the menu item
- **CategoryID**: Foreign key to Categories table
- **Description**: Description of the menu item
- **Price**: Price of the menu item
- **Active**: Boolean indicating if the item is available

### 4. Orders
Tracks customer orders and their status.
- **OrderID**: Primary key
- **CustomerID**: Foreign key to Customers table (optional)
- **StaffID**: Foreign key to Staff table
- **OrderDate**: Date and time of the order
- **OrderType**: Type of order ("Dine-in", "Takeout")
- **OrderStatus**: Current status ("Pending", "Completed")
- **TotalAmount**: Total amount of the order
- **Notes**: Additional notes

### 5. OrderItems
Details of what items are in each order.
- **OrderItemID**: Primary key
- **OrderID**: Foreign key to Orders table
- **ItemID**: Foreign key to MenuItems table
- **Quantity**: Number of items ordered
- **UnitPrice**: Price of the item at the time of order
- **Notes**: Additional notes

### 6. Transactions
Records all payment transactions associated with completed orders.
- **TransactionID**: Primary key
- **OrderID**: Foreign key to Orders table
- **TransactionDate**: Date and time of the transaction
- **Amount**: Amount of the transaction
- **TransactionStatus**: Status of the transaction ("Completed", "Refunded")
- **ReceiptNumber**: Receipt number generated from date, time, and customer initials
- **Notes**: Additional notes

### 7. Staff
Records information about employees.
- **StaffID**: Primary key
- **FirstName**: First name of the staff member
- **LastName**: Last name of the staff member

### 8. Customers
Records information about customers.
- **CustomerID**: Primary key
- **FirstName**: First name of the customer
- **Notes**: Additional notes about the customer

## Key Changes Made

1. **Removed Recipe and ImagePath from MenuItems**:
   - Simplified the menu items table by removing these fields

2. **Updated Customer Information**:
   - Now only tracking customer's first name, as requested

3. **Simplified Order Status**:
   - Replaced separate ServiceStatus and PaymentStatus with single OrderStatus field
   - Order Status: "Pending" or "Completed" 
   - Orders are only marked completed when explicitly confirmed by user

4. **Limited Order Types**:
   - Restricted order types to only "Dine-in" and "Takeout"
   - Removed "Delivery" option as requested

5. **Simplified Transactions**:
   - Transactions are only created when an order is marked complete
   - Removed PaymentMethod field as only cash is accepted
   - Receipt numbers are auto-generated using date, time, and customer initials

5. **Status-Based Inventory**:
   - Using status tracking ("Available", "Not Available", "Low Stock") instead of quantity
   - This lets staff manually update ingredient availability

6. **Eliminated Menu-Ingredient Mapping**:
   - Removed direct mapping between menu items and ingredients
   - Menu availability determined by staff knowledge and status updates

## Key Business Logic

1. **Order Completion Logic**:
   - An order is only marked complete when explicitly confirmed by a user
   - The `sp_CompleteOrder` stored procedure handles this process
   - When an order is marked complete, a transaction record is automatically created
   - Receipt numbers follow the format: DateTimeStamp-CustomerInitials (e.g., 20230510-124500-JD)

2. **Menu Availability Logic**:
   - The `sp_UpdateMenuItemAvailability` stored procedure updates menu item availability
   - Based on ingredient availability status
   - When key ingredients are unavailable, related menu items become inactive

3. **Transaction Records**:
   - Transaction records only exist for completed orders
   - The system ensures transaction records maintain accurate financial history

## Database Relationships

1. **Categories**: Self-referencing for hierarchical organization
2. **Categories → MenuItems**: Each menu item belongs to a category
3. **Categories → Inventory**: Each inventory item belongs to a category
4. **Orders → OrderItems**: Each order contains one or more order items
5. **MenuItems → OrderItems**: Each order item references a menu item
6. **Staff → Orders**: Each order is processed by a staff member
7. **Customers → Orders**: Each order may be associated with a customer
8. **Orders → Transactions**: Each order may have one or more payment transactions

## Workflow Summary

1. **Inventory Management**:
   - Staff updates status of ingredients as "Available", "Not Available", or "Low Stock"
   - System adjusts menu availability based on ingredient status

2. **Order Processing**:
   - Customer orders items from the available menu (Dine-in or Takeout only)
   - Staff creates order and adds items
   - System calculates total amount

3. **Order Completion**:
   - Order remains in "Pending" status during preparation and service
   - When order is ready for completion, staff collects cash payment
   - Staff enters customer initials and confirms order completion
   - System automatically marks order as "Completed" and creates transaction record
   - Receipt number is auto-generated from current date, time, and customer initials

4. **Reporting**:
   - System can generate reports based on orders, transactions, and inventory
   - Only completed orders appear in transaction reports
   - Helps track sales, popular items, and completed orders

## Implementation Notes

1. All CSV files have been updated to match this structure
2. The import_csv_to_sql_updated.sql script is ready to create and populate the database
3. The structure supports the requested workflow where service and payment status are manually updated by users
