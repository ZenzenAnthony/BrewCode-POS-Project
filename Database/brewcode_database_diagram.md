# BrewCode POS Database Diagram (Mermaid)

## Entity Relationship Diagram

```mermaid
erDiagram
    Categories {
        int CategoryID PK
        varchar CategoryName
        varchar Description
        int ParentCategoryID FK
        bit Active
    }
      Transactions {
        int TransactionID PK
        int OrderID FK
        datetime TransactionDate
        decimal Amount
        varchar TransactionStatus
        varchar ReceiptNumber
        text Notes
    }

    Inventory {
        int InventoryID PK
        varchar ItemName
        int CategoryID FK
        varchar Unit
        varchar Status
        text Notes
    }    MenuItems {
        int ItemID PK
        varchar ItemName
        int CategoryID FK
        text Description
        decimal Price
        bit Active
    }

    Staff {
        int StaffID PK
        varchar FirstName
        varchar LastName
    }    Customers {
        int CustomerID PK
        varchar FirstName
        text Notes
    }    Orders {
        int OrderID PK
        int CustomerID FK
        int StaffID FK
        datetime OrderDate
        varchar OrderType
        varchar OrderStatus
        decimal TotalAmount
        text Notes
    }

    OrderItems {
        int OrderItemID PK
        int OrderID FK
        int ItemID FK
        int Quantity
        decimal UnitPrice
        text Notes
    }

    Categories ||--o{ Categories : "Parent-Child"
    Categories ||--o{ Inventory : "Categorizes"
    Categories ||--o{ MenuItems : "Categorizes"
    Staff ||--o{ Orders : "Processes"
    Customers ||--o{ Orders : "Places"
    Orders ||--o{ OrderItems : "Contains"    MenuItems ||--o{ OrderItems : "Ordered"
    Orders ||--o{ Transactions : "Has"
```

## Flow Diagram

```mermaid
flowchart TD
    User([User/Staff])
    Inventory[(Inventory)]
    MenuItems[(Menu Items)]
    OrderCreation[Order Creation]
    OrderStatus[Order Status]
    Transactions[Transactions]
    
    User -->|Updates Status| Inventory
    Inventory -->|Affects| MenuItems
    User -->|Selects from| MenuItems
    MenuItems -->|Added to| OrderCreation
    OrderCreation -->|Creates| OrderStatus
    
    OrderStatus -->|When Marked Completed| Transactions
    User -->|Confirms Completion| OrderStatus
```

## Key Database Features:

1. **Status-Based Inventory System**:
   - Ingredients can be marked as "Available", "Not Available", or "Low Stock"
   - No automatic quantity tracking - status is updated manually by staff

2. **Menu Availability Logic**:
   - Menu item availability is determined by ingredient status
   - When key ingredients are unavailable, related menu items become inactive

3. **Order Processing Workflow**:
   - Orders move through defined statuses: Pending → Preparing → Ready → Delivered → Completed
   - Payment status tracked separately: Unpaid → Paid → Refunded (if needed)

4. **Hierarchical Categories**:
   - Categories can have parent-child relationships
   - Allows for organizing both menu items and inventory items
