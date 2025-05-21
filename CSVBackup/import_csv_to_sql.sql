-- Import CSV files into SQL Server
-- This script will create the database structure and import data from CSV files

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
DROP TABLE IF EXISTS MenuItemIngredients;
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

-- Create Inventory table (simplified)
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY IDENTITY(1,1),
    ItemName VARCHAR(100) NOT NULL,
    CategoryID INT,
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
    LastName VARCHAR(50) NOT NULL,
    Notes TEXT
);

-- Create MenuItems table (simplified)
CREATE TABLE MenuItems (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    ItemName VARCHAR(100) NOT NULL,
    CategoryID INT,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL,
    Recipe TEXT,
    ImagePath VARCHAR(200),
    Active BIT DEFAULT 1,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Create a cross-reference table between MenuItems and Inventory
CREATE TABLE MenuItemIngredients (
    MenuItemID INT,
    InventoryID INT,
    Quantity DECIMAL(10,3) NOT NULL,
    PRIMARY KEY (MenuItemID, InventoryID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(ItemID),
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID)
);

-- Create Orders table (simplified)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT,
    StaffID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    OrderType VARCHAR(20) CHECK (OrderType IN ('Dine-in', 'Takeout', 'Delivery')),
    OrderStatus VARCHAR(20) DEFAULT 'Pending' CHECK (OrderStatus IN ('Pending', 'Preparing', 'Ready', 'Delivered', 'Completed', 'Cancelled')),
    TotalAmount DECIMAL(10,2) NOT NULL,
    PaymentStatus VARCHAR(20) DEFAULT 'Unpaid' CHECK (PaymentStatus IN ('Unpaid', 'Paid', 'Refunded')),
    Notes TEXT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

-- Create OrderItems table (simplified)
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    ItemID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Notes VARCHAR(200),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ItemID) REFERENCES MenuItems(ItemID)
);

-- Create views for common operations

-- View for menu items with their categories
CREATE VIEW vw_MenuItemsWithCategories AS
SELECT m.ItemID, m.ItemName, m.Price, c.CategoryName, m.Active
FROM MenuItems m
JOIN Categories c ON m.CategoryID = c.CategoryID;

-- View for daily sales report
CREATE VIEW vw_DailySalesReport AS
SELECT CAST(o.OrderDate AS DATE) AS OrderDate, 
       COUNT(DISTINCT o.OrderID) AS TotalOrders,
       SUM(o.TotalAmount) AS TotalSales,
       AVG(o.TotalAmount) AS AverageOrderValue
FROM Orders o
WHERE o.OrderStatus IN ('Completed', 'Delivered')
GROUP BY CAST(o.OrderDate AS DATE);

-- View for top selling items
CREATE VIEW vw_TopSellingItems AS
SELECT m.ItemID, m.ItemName, c.CategoryName,
       COUNT(oi.OrderItemID) AS TimesSold,
       SUM(oi.Quantity) AS TotalQuantitySold,
       SUM(oi.UnitPrice * oi.Quantity) AS TotalRevenue
FROM MenuItems m
JOIN OrderItems oi ON m.ItemID = oi.ItemID
JOIN Orders o ON oi.OrderID = o.OrderID
JOIN Categories c ON m.CategoryID = c.CategoryID
WHERE o.OrderStatus IN ('Completed', 'Delivered')
GROUP BY m.ItemID, m.ItemName, c.CategoryName;

-- Stored procedure for placing a new order
CREATE PROCEDURE sp_PlaceOrder
    @CustomerID INT,
    @StaffID INT,
    @OrderType VARCHAR(20),
    @Notes TEXT = NULL
AS
BEGIN
    -- Create the order
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

-- Import data from CSV files
-- NOTE: Update these paths to the actual locations of your CSV files before running

-- Import Categories
BULK INSERT Categories
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\2-A AI\2nd Sem\BrewCode POS Project\Database\CSV\categories.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Staff
BULK INSERT Staff
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\2-A AI\2nd Sem\BrewCode POS Project\Database\CSV\staff.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Customers
BULK INSERT Customers
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\2-A AI\2nd Sem\BrewCode POS Project\Database\CSV\customers.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Inventory
BULK INSERT Inventory
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\2-A AI\2nd Sem\BrewCode POS Project\Database\CSV\inventory.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import MenuItems
BULK INSERT MenuItems
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\2-A AI\2nd Sem\BrewCode POS Project\Database\CSV\menu_items.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Orders
BULK INSERT Orders
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\2-A AI\2nd Sem\BrewCode POS Project\Database\CSV\orders.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import OrderItems
BULK INSERT OrderItems
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\2-A AI\2nd Sem\BrewCode POS Project\Database\CSV\order_items.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import MenuItemIngredients (if you've added data to this file)
-- Remove the comment below and update the file path if you have data in this file
/*
BULK INSERT MenuItemIngredients
FROM 'C:\Users\User\OneDrive\Documents\School Stuffs\2-A AI\2nd Sem\BrewCode POS Project\Database\CSV\menu_item_ingredients.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);
*/

PRINT 'Database import completed successfully!';
GO
