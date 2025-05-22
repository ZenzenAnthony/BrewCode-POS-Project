# BrewCode POS Application User Guide

## Overview

This guide walks you through using the updated BrewCode POS application that has been designed to work with the revised database structure. The application supports the following key features:

1. Menu item browsing and ordering
2. Inventory status management
3. Order tracking and completion
4. Transaction history and reporting

## Getting Started

### Launching the Application

After installing the Flutter application, launch it to see the home screen with the BrewCode logo and three main navigation icons in the app bar:

- **Inventory Management**: Check and update the availability of ingredients
- **Transaction History**: View completed orders and their details
- **Order Tracking**: Monitor and manage active and completed orders

### Creating a New Order

1. On the home screen, enter the customer's name in the text field
2. Select either "Dine-In" or "Take-Out" to continue
3. Browse the menu categorized by food/drink type
4. Add items to the cart by tapping on them
5. Adjust quantities as needed in the cart
6. Complete the order to generate a receipt number

## Inventory Management

The inventory management system now uses a status-based approach rather than tracking exact quantities:

### Statuses

- **Available**: Item is fully stocked and available for use
- **Low Stock**: Item is running low and needs to be restocked soon
- **Not Available**: Item is out of stock and cannot be used

### Updating Inventory

1. Navigate to the Inventory Management screen
2. Browse the list of all inventory items
3. Change an item's status by tapping the corresponding button:
   - Green = Available
   - Orange = Low Stock
   - Red = Not Available

When an inventory item is marked as "Not Available", any menu items using that ingredient will automatically be disabled.

## Order Processing

### Order Status Values

Orders now have two possible statuses:
- **Pending**: Order has been created but not yet completed
- **Completed**: Order has been finalized and payment received

### Completing an Order

1. Navigate to the Order Tracking screen
2. Find the pending order in the list
3. Tap "Complete Order"
4. Enter the customer's initials (for the receipt number)
5. Confirm to update the status and create a transaction record

## Transaction Records

Transaction records are only created when an order is marked as completed:

### Transaction Details

- Transaction ID
- Order ID
- Date and time
- Amount
- Receipt number (auto-generated from date-time and customer initials)
- Order type (Dine-in or Takeout)
- Customer name
- Staff name

### Viewing Transactions

1. Navigate to the Transaction History screen
2. View the list of all completed transactions
3. Print receipts as needed using the Print button

## System Limitations

- The system does not track detailed item quantities, only status
- Only cash payments are accepted
- Only Dine-in and Takeout orders are supported (no Delivery)
- Customer tracking is limited to first name only

## Future Integration

This application is currently using mock data and placeholder services that simulate database operations. In the future, it will be connected to the SQL Server database following the integration plan outlined in the `database_integration_plan.md` document.

## Support

If you encounter any issues with the application, please contact the BrewCode POS system administrator.
