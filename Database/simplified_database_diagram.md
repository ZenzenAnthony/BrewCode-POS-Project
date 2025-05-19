```
# BrewCode POS System Database - Entity Relationship Diagram (ERD)

+---------------+             +----------------+             +----------------+
| Categories    |             | Inventory      |             | Staff          |
+---------------+             +----------------+             +----------------+
| PK: CategoryID|             | PK: InventoryID|             | PK: StaffID    |
| CategoryName  |------------>| ItemName       |             | FirstName      |
| Description   |             | CategoryID     |             | LastName       |
| ParentCategoryID            | Unit           |             +----------------+
| Active        |             | Status         |                     |
+---------------+             | Notes          |                     |
      ▲                       +----------------+                     |
      |                               |                              |
      |                               |                              |
      |    +---------------------+    |                     +--------+------+
      |--->| MenuItems          |    |                     | Orders         |
      |    +---------------------+    |                     +-----------------+
      |--->| PK: ItemID         |    |                     | PK: OrderID     |
           | ItemName           |    |                     | CustomerID      |
           | CategoryID         |    |                     | StaffID         |
           | Description        |    |                     | OrderDate       |
           | Price              |    |                     | OrderType       |
           | Active             |    |                     | OrderStatus     |
           |                    |    |                     | TotalAmount     |
           |                    |    |                     |                 |
           +---------------------+    |                     | Notes           |
                    |                 |                     +-----------------+
                    |                 |                              ▲
                    |                 |                              |                    |                                                |
                    |    +-------------------+    +--------------+   |
                    |<---| OrderItems        |<---| Customers    |<--+
                         +-------------------+    +--------------+
                         | PK: OrderItemID   |    | PK: CustomerID|
                         | OrderID           |    | FirstName     |
                         | ItemID            |    | Notes         |
                         | Quantity          |    |               |
                         | UnitPrice         |    +--------------+                         | Notes             |
                         +-------------------+
                              |
                              |
                              v
                         +-------------------+                         | Transactions      |
                         +-------------------+
                         | PK: TransactionID |
                         | OrderID           |
                         | TransactionDate   |
                         | Amount            |
                         | TransactionStatus |
                         | ReceiptNumber     |
                         | Notes             |
                         +-------------------+
```
