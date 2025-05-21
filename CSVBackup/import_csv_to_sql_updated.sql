-- Import CSV files into SQL Server
-- Updated script to remove MenuItemIngredients and update Inventory structure

-- Create the database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'KohiDB')
BEGIN
    CREATE DATABASE KohiDB;
END
GO

-- Use the newly created database
USE KohiDB;
GO

-- Drop tables if they exist to avoid errors on recreating the database
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS MenuItems;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Staff;

-- Create Categories table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName VARCHAR(50) NOT NULL,
    Description VARCHAR(200),
    ParentCategoryID INT,
    Active BIT DEFAULT 1,
    CONSTRAINT UC_CategoryName UNIQUE (CategoryName),
    FOREIGN KEY (ParentCategoryID) REFERENCES Categories(CategoryID)
);

-- Create Inventory table (updated with status and unit but no quantity tracking)
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY IDENTITY(1,1),
    ItemName VARCHAR(100) NOT NULL,
    CategoryID INT,
    Unit VARCHAR(20),
    Status VARCHAR(20) CHECK (Status IN ('Available', 'Not Available', 'Low Stock')),
    Notes TEXT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Create Staff table (simplified)
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL
);

-- Create Customers table (simplified)
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    Notes TEXT
);

-- Create MenuItems table (simplified)
CREATE TABLE MenuItems (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    ItemName VARCHAR(100) NOT NULL,
    CategoryID INT,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL,
    Active BIT DEFAULT 1,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Create Orders table (simplified)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    StaffID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    OrderType VARCHAR(20) CHECK (OrderType IN ('Dine-in', 'Takeout')),
    OrderStatus VARCHAR(20) DEFAULT 'Pending' CHECK (OrderStatus IN ('Pending', 'Completed')),
    TotalAmount DECIMAL(10,2) NOT NULL,
    Notes TEXT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

-- Create OrderItems table (simplified)
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ItemID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Notes TEXT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ItemID) REFERENCES MenuItems(ItemID)
);

-- Create Transactions table
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    TransactionDate DATETIME DEFAULT GETDATE(),
    Amount DECIMAL(10,2) NOT NULL,
    TransactionStatus VARCHAR(20) DEFAULT 'Completed' CHECK (TransactionStatus IN ('Completed', 'Refunded')),
    ReceiptNumber VARCHAR(50),
    Notes TEXT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Create stored procedures for common operations

-- Stored procedure for creating a new order
CREATE PROCEDURE sp_CreateOrder
    @CustomerID INT = NULL,
    @StaffID INT,
    @OrderType VARCHAR(20),
    @Notes VARCHAR(200) = NULL
AS
BEGIN
    DECLARE @OrderID INT;
    
    INSERT INTO Orders (CustomerID, StaffID, OrderType, TotalAmount, Notes)
    VALUES (@CustomerID, @StaffID, @OrderType, 0, @Notes);
    
    SET @OrderID = SCOPE_IDENTITY();
    
    SELECT 'Order created successfully with ID: ' + CAST(@OrderID AS VARCHAR(10)) AS Result;
    
    RETURN @OrderID;
END;
GO

-- Stored procedure for adding items to an order
CREATE PROCEDURE sp_AddOrderItem
    @OrderID INT,
    @ItemID INT,
    @Quantity INT,
    @Notes VARCHAR(200) = NULL
AS
BEGIN
    DECLARE @UnitPrice DECIMAL(10,2);
    
    -- Get current price of the menu item
    SELECT @UnitPrice = Price FROM MenuItems WHERE ItemID = @ItemID;
    
    -- Add item to order
    INSERT INTO OrderItems (OrderID, ItemID, Quantity, UnitPrice, Notes)
    VALUES (@OrderID, @ItemID, @Quantity, @UnitPrice, @Notes);
    
    -- Update total amount in the order
    UPDATE Orders
    SET TotalAmount = TotalAmount + (@UnitPrice * @Quantity)
    WHERE OrderID = @OrderID;
    
    SELECT 'Item added to order successfully' AS Result;
END;
GO

-- Create a new stored procedure to check ingredient availability and update menu item availability
CREATE PROCEDURE sp_UpdateMenuItemAvailability
AS
BEGIN
    -- This procedure can be used to check inventory status and update menu item availability
    -- When an ingredient is marked as "Not Available", related menu items should be marked as inactive
    
    -- Mark menu items as inactive based on ingredient status
    UPDATE MenuItems
    SET Active = 0
    WHERE EXISTS (
        SELECT 1 
        FROM Inventory 
        WHERE Status = 'Not Available' 
        AND CategoryID IN (SELECT CategoryID FROM Categories WHERE ParentCategoryID IS NULL)
    );
    
    -- Note: This is a simplified example. In a real system, you would need a more 
    -- sophisticated logic based on your specific requirements and item-ingredient relationships
END;
GO

-- Import data from CSV files
-- NOTE: Update these paths to the actual locations of your CSV files before running

-- Import Categories
BULK INSERT Categories
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\BrewCode POS Project\Database\CSV\categories_updated.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Staff
BULK INSERT Staff
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\BrewCode POS Project\Database\CSV\staff.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Customers
BULK INSERT Customers
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\BrewCode POS Project\Database\CSV\customers.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Inventory (updated with new structure)
BULK INSERT Inventory
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\BrewCode POS Project\Database\CSV\inventory_updated.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import MenuItems
BULK INSERT MenuItems
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\BrewCode POS Project\Database\CSV\menu_items_updated.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Orders
BULK INSERT Orders
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\BrewCode POS Project\Database\CSV\orders.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import OrderItems
BULK INSERT OrderItems
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\BrewCode POS Project\Database\CSV\order_items.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Transactions
BULK INSERT Transactions
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\BrewCode POS Project\Database\CSV\transactions.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Run the procedure to update menu item availability based on inventory status
EXEC sp_UpdateMenuItemAvailability;

-- Create a stored procedure to mark an order as complete and create a transaction record
CREATE PROCEDURE sp_CompleteOrder
    @OrderID INT,
    @CustomerInitials VARCHAR(10)
AS
BEGIN
    DECLARE @TotalAmount DECIMAL(10,2);
    DECLARE @ReceiptNumber VARCHAR(50);
    
    -- Get the total amount from the order
    SELECT @TotalAmount = TotalAmount
    FROM Orders
    WHERE OrderID = @OrderID;
    
    -- Generate receipt number based on date-time and customer initials
    SET @ReceiptNumber = FORMAT(GETDATE(), 'yyyyMMdd-HHmmss') + '-' + @CustomerInitials;
    
    -- Update the order status to completed
    UPDATE Orders
    SET OrderStatus = 'Completed'
    WHERE OrderID = @OrderID AND OrderStatus = 'Pending';
    
    -- Create a transaction record only if the order was successfully marked as completed
    IF @@ROWCOUNT > 0
    BEGIN
        INSERT INTO Transactions (OrderID, TransactionDate, Amount, TransactionStatus, ReceiptNumber, Notes)
        VALUES (@OrderID, GETDATE(), @TotalAmount, 'Completed', @ReceiptNumber, 'Auto-generated from order completion');
        
        SELECT 'Order ' + CAST(@OrderID AS VARCHAR) + ' completed successfully. Receipt: ' + @ReceiptNumber AS Result;
    END
    ELSE
    BEGIN
        SELECT 'Failed to complete order. Order may already be completed or does not exist.' AS Result;
    END
END;
GO

-- Create a stored procedure to retrieve completed transactions with order details
CREATE PROCEDURE sp_GetCompletedTransactions
AS
BEGIN
    SELECT 
        t.TransactionID, 
        t.OrderID, 
        t.TransactionDate,
        t.Amount,
        t.ReceiptNumber,
        o.OrderType,
        c.FirstName AS CustomerName,
        s.FirstName + ' ' + s.LastName AS StaffName
    FROM Transactions t
    JOIN Orders o ON t.OrderID = o.OrderID
    LEFT JOIN Customers c ON o.CustomerID = c.CustomerID
    JOIN Staff s ON o.StaffID = s.StaffID
    WHERE o.OrderStatus = 'Completed'
    ORDER BY t.TransactionDate DESC;
END;
GO

PRINT 'Database import completed successfully!';
