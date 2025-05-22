-- MySQL import script with menu-inventory relationship enhancement
-- For BrewCode POS Project - May 22, 2025

-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS KohiDB;

-- Use the newly created database
USE KohiDB;

-- Drop tables if they exist to avoid errors on recreating the database
DROP TABLE IF EXISTS MenuItemIngredients;
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
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL,
    Description VARCHAR(200),
    ParentCategoryID INT,
    Active BOOLEAN DEFAULT TRUE,
    CONSTRAINT UC_CategoryName UNIQUE (CategoryName),
    FOREIGN KEY (ParentCategoryID) REFERENCES Categories(CategoryID)
);

-- Create Inventory table (updated with status and unit but no quantity tracking)
CREATE TABLE Inventory (
    InventoryID INT AUTO_INCREMENT PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    CategoryID INT,
    Unit VARCHAR(20),
    Status VARCHAR(20) CHECK (Status IN ('Available', 'Not Available', 'Low Stock')),
    Notes TEXT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Create Staff table (simplified)
CREATE TABLE Staff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL
);

-- Create Customers table (simplified)
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    Notes TEXT
);

-- Create MenuItems table (simplified)
CREATE TABLE MenuItems (
    ItemID INT AUTO_INCREMENT PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    CategoryID INT,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL,
    Active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Create Orders table (simplified)
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    StaffID INT NOT NULL,
    OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    OrderType VARCHAR(20) CHECK (OrderType IN ('Dine-in', 'Takeout')),
    OrderStatus VARCHAR(20) DEFAULT 'Pending' CHECK (OrderStatus IN ('Pending', 'Completed')),
    TotalAmount DECIMAL(10,2) NOT NULL,
    Notes TEXT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

-- Create OrderItems table (simplified)
CREATE TABLE OrderItems (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
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
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    TransactionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Amount DECIMAL(10,2) NOT NULL,
    TransactionStatus VARCHAR(20) DEFAULT 'Completed' CHECK (TransactionStatus IN ('Completed', 'Refunded')),
    ReceiptNumber VARCHAR(50),
    Notes TEXT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Create the MenuItemIngredients junction table
CREATE TABLE MenuItemIngredients (
    MenuItemIngredientID INT AUTO_INCREMENT PRIMARY KEY,
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
DELIMITER //
CREATE PROCEDURE sp_UpdateMenuAvailabilityByIngredients()
BEGIN
    -- First, set all menu items as active (default state)
    UPDATE MenuItems SET Active = TRUE;
    
    -- Then, mark menu items as inactive if ANY of their required ingredients
    -- are not available
    UPDATE MenuItems
    SET Active = FALSE
    WHERE ItemID IN (
        -- Find menu items that have at least one unavailable ingredient
        SELECT DISTINCT mi.MenuItemID
        FROM MenuItemIngredients mi
        JOIN Inventory i ON mi.InventoryID = i.InventoryID
        WHERE i.Status = 'Not Available'
    );
    
    SELECT 'Menu item availability updated based on ingredient status' AS Message;
END //
DELIMITER ;

-- 2. Helper procedure to link menu items to ingredients
DELIMITER //
CREATE PROCEDURE sp_LinkMenuItemToIngredient(
    IN p_MenuItemID INT,
    IN p_InventoryID INT
)
BEGIN
    -- Check if both IDs exist
    IF NOT EXISTS (SELECT 1 FROM MenuItems WHERE ItemID = p_MenuItemID) THEN
        SELECT CONCAT('Error: Menu item ID ', p_MenuItemID, ' does not exist') AS Message;
    ELSEIF NOT EXISTS (SELECT 1 FROM Inventory WHERE InventoryID = p_InventoryID) THEN
        SELECT CONCAT('Error: Inventory item ID ', p_InventoryID, ' does not exist') AS Message;
    ELSE
        -- Check if relationship already exists
        IF EXISTS (SELECT 1 FROM MenuItemIngredients 
                    WHERE MenuItemID = p_MenuItemID AND InventoryID = p_InventoryID) THEN
            -- Relationship already exists, do nothing
            SELECT 'Relationship already exists, no changes made' AS Message;
        ELSE
            -- Insert new relationship
            INSERT INTO MenuItemIngredients (MenuItemID, InventoryID)
            VALUES (p_MenuItemID, p_InventoryID);
            
            SELECT 'Created new menu item-ingredient relationship' AS Message;
        END IF;
    END IF;
END //
DELIMITER ;

-- 3. Stored procedure for creating a new order
DELIMITER //
CREATE PROCEDURE sp_CreateOrder(
    IN p_CustomerID INT,
    IN p_StaffID INT,
    IN p_OrderType VARCHAR(20),
    IN p_Notes TEXT
)
BEGIN
    DECLARE v_OrderID INT;
    
    INSERT INTO Orders (CustomerID, StaffID, OrderType, TotalAmount, Notes)
    VALUES (p_CustomerID, p_StaffID, p_OrderType, 0, p_Notes);
    
    SET v_OrderID = LAST_INSERT_ID();
    
    SELECT CONCAT('Order created successfully with ID: ', v_OrderID) AS Result;
END //
DELIMITER ;

-- 4. Stored procedure for completing an order and creating transaction
DELIMITER //
CREATE PROCEDURE sp_CompleteOrder(
    IN p_OrderID INT,
    IN p_CustomerInitials VARCHAR(10)
)
BEGIN
    DECLARE v_ReceiptNumber VARCHAR(50);
    DECLARE v_TotalAmount DECIMAL(10,2);
    
    -- Get order total
    SELECT TotalAmount INTO v_TotalAmount
    FROM Orders 
    WHERE OrderID = p_OrderID;
    
    -- Generate receipt number (date + time + customer initials)
    SET v_ReceiptNumber = CONCAT(
        DATE_FORMAT(NOW(), '%Y%m%d-%H%i%s'),
        '-',
        IFNULL(p_CustomerInitials, 'XX')
    );
    
    -- Update order status
    UPDATE Orders
    SET OrderStatus = 'Completed'
    WHERE OrderID = p_OrderID;
    
    -- Create transaction record
    INSERT INTO Transactions (OrderID, Amount, TransactionStatus, ReceiptNumber)
    VALUES (p_OrderID, v_TotalAmount, 'Completed', v_ReceiptNumber);
    
    -- Return result
    SELECT 
        v_ReceiptNumber AS ReceiptNumber, 
        CONCAT('Order completed successfully with receipt number: ', v_ReceiptNumber) AS Result;
END //
DELIMITER ;

-- Load data from CSV files
-- Note: You'll need to update the file paths to match your environment
-- and make sure MySQL has permissions to read these files

-- Load Categories data
LOAD DATA INFILE 'C:/Projects/BrewCode-POS-Project/CSV/categories_updated.csv' 
INTO TABLE Categories
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CategoryID, CategoryName, Description);

-- Load MenuItems data
LOAD DATA INFILE 'C:/Projects/BrewCode-POS-Project/CSV/menu_items_updated.csv' 
INTO TABLE MenuItems
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ItemID, ItemName, CategoryID, Description, Price, Active);

-- Load Inventory data
LOAD DATA INFILE 'C:/Projects/BrewCode-POS-Project/CSV/inventory_updated.csv' 
INTO TABLE Inventory
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InventoryID, ItemName, CategoryID, Unit, Status, Notes);

-- Load Staff data (contains only one record as requested)
LOAD DATA INFILE 'C:/Projects/BrewCode-POS-Project/CSV/staff.csv' 
INTO TABLE Staff
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(StaffID, FirstName, LastName);

-- Load Menu-Item-Ingredient relationships
LOAD DATA INFILE 'C:/Projects/BrewCode-POS-Project/CSV/menu_item_ingredients.csv'
INTO TABLE MenuItemIngredients
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(MenuItemIngredientID, MenuItemID, InventoryID);

-- The remaining tables (Customers, Orders, OrderItems, Transactions) will be empty
-- since we've edited the CSV files to contain only headers
