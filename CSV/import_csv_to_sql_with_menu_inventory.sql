-- Import CSV files into SQL Server
-- Updated script with menu-inventory relationship enhancement
-- For BrewCode POS Project - May 22, 2025

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
DROP TABLE IF EXISTS MenuItemIngredients; -- Drop the junction table first to avoid foreign key issues
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Transactions;
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

-- Create the MenuItemIngredients junction table
CREATE TABLE MenuItemIngredients (
    MenuItemIngredientID INT PRIMARY KEY IDENTITY(1,1),
    MenuItemID INT NOT NULL,
    InventoryID INT NOT NULL,
    -- No quantity tracking as requested
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(ItemID),
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID),
    -- Ensure a menu item doesn't link to the same inventory item twice
    CONSTRAINT UC_MenuItem_Inventory UNIQUE (MenuItemID, InventoryID)
);

-- Create stored procedures for menu-inventory relationship

-- 1. Stored procedure for updating menu availability based on ingredients
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_UpdateMenuAvailabilityByIngredients')
BEGIN
    DROP PROCEDURE sp_UpdateMenuAvailabilityByIngredients;
END
GO

CREATE PROCEDURE sp_UpdateMenuAvailabilityByIngredients
AS
BEGIN
    -- First, set all menu items as active (default state)
    UPDATE MenuItems SET Active = 1;
    
    -- Then, mark menu items as inactive if ANY of their required ingredients
    -- are not available
    UPDATE MenuItems
    SET Active = 0
    WHERE ItemID IN (
        -- Find menu items that have at least one unavailable ingredient
        SELECT DISTINCT mi.MenuItemID
        FROM MenuItemIngredients mi
        JOIN Inventory i ON mi.InventoryID = i.InventoryID
        WHERE i.Status = 'Not Available'
    );
    
    PRINT 'Menu item availability updated based on ingredient status';
END;
GO

-- 2. Helper procedure to link menu items to ingredients
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_LinkMenuItemToIngredient')
BEGIN
    DROP PROCEDURE sp_LinkMenuItemToIngredient;
END
GO

CREATE PROCEDURE sp_LinkMenuItemToIngredient
    @MenuItemID INT,
    @InventoryID INT
AS
BEGIN
    -- Check if both IDs exist
    IF NOT EXISTS (SELECT 1 FROM MenuItems WHERE ItemID = @MenuItemID)
    BEGIN
        PRINT 'Error: Menu item ID ' + CAST(@MenuItemID AS VARCHAR(10)) + ' does not exist';
        RETURN;
    END
    
    IF NOT EXISTS (SELECT 1 FROM Inventory WHERE InventoryID = @InventoryID)
    BEGIN
        PRINT 'Error: Inventory item ID ' + CAST(@InventoryID AS VARCHAR(10)) + ' does not exist';
        RETURN;
    END
    
    -- Check if relationship already exists
    IF EXISTS (SELECT 1 FROM MenuItemIngredients 
                WHERE MenuItemID = @MenuItemID AND InventoryID = @InventoryID)
    BEGIN
        -- Relationship already exists, do nothing
        PRINT 'Relationship already exists, no changes made';
    END
    ELSE
    BEGIN
        -- Insert new relationship
        INSERT INTO MenuItemIngredients (MenuItemID, InventoryID)
        VALUES (@MenuItemID, @InventoryID);
        
        PRINT 'Created new menu item-ingredient relationship';
    END
END;
GO

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

-- Stored procedure to complete an order and create transaction
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_CompleteOrder')
BEGIN
    DROP PROCEDURE sp_CompleteOrder;
END
GO

CREATE PROCEDURE sp_CompleteOrder
    @OrderID INT,
    @CustomerInitials VARCHAR(10) = 'XX'
AS
BEGIN
    DECLARE @ReceiptNumber VARCHAR(50);
    DECLARE @TotalAmount DECIMAL(10,2);
    DECLARE @DatePart VARCHAR(15);
    
    -- Get order total
    SELECT @TotalAmount = TotalAmount 
    FROM Orders 
    WHERE OrderID = @OrderID;
    
    -- Generate receipt number (date + time + customer initials)
    SET @DatePart = FORMAT(GETDATE(), 'yyyyMMdd-HHmmss');
    SET @ReceiptNumber = @DatePart + '-' + @CustomerInitials;
    
    -- Update order status
    UPDATE Orders
    SET OrderStatus = 'Completed'
    WHERE OrderID = @OrderID;
    
    -- Create transaction record
    INSERT INTO Transactions (OrderID, Amount, TransactionStatus, ReceiptNumber)
    VALUES (@OrderID, @TotalAmount, 'Completed', @ReceiptNumber);
    
    -- Return result
    SELECT 
        @ReceiptNumber AS ReceiptNumber, 
        'Order completed successfully with receipt number: ' + @ReceiptNumber AS Result;
END;
GO

-- Import data from CSV files
-- NOTE: Update these paths to the actual locations of your CSV files before running

-- Import Categories
BULK INSERT Categories
FROM 'C:\Projects\BrewCode-POS-Project\CSV\categories_updated.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Staff (contains only one record as requested)
BULK INSERT Staff
FROM 'C:\Projects\BrewCode-POS-Project\CSV\staff.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Menu Items
BULK INSERT MenuItems
FROM 'C:\Projects\BrewCode-POS-Project\CSV\menu_items_updated.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Inventory
BULK INSERT Inventory
FROM 'C:\Projects\BrewCode-POS-Project\CSV\inventory_updated.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Customers (empty file with headers only as requested)
BULK INSERT Customers
FROM 'C:\Projects\BrewCode-POS-Project\CSV\customers.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Orders (empty file with headers only as requested)
BULK INSERT Orders
FROM 'C:\Projects\BrewCode-POS-Project\CSV\orders.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Order Items (empty file with headers only as requested)
BULK INSERT OrderItems
FROM 'C:\Projects\BrewCode-POS-Project\CSV\order_items.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Transactions (empty file with headers only as requested)
BULK INSERT Transactions
FROM 'C:\Projects\BrewCode-POS-Project\CSV\transactions.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

-- Import Menu-Item-Ingredient relationships
BULK INSERT MenuItemIngredients
FROM 'C:\Projects\BrewCode-POS-Project\CSV\menu_item_ingredients.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    TABLOCK
);

PRINT 'Database setup completed successfully';
GO
