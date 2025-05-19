-- Food Business Database (Simplified Version)
-- A streamlined database for managing food service operations, orders, and customers

-- Create the database if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'FoodBusinessDB')
BEGIN
    CREATE DATABASE FoodBusinessDB;
END
GO

-- Use the newly created database
USE KohiDB;
GO

-- Drop existing views and procedures first
DROP VIEW IF EXISTS vw_MenuItemsWithCategories;
GO
DROP VIEW IF EXISTS vw_DailySalesReport;
GO
DROP VIEW IF EXISTS vw_TopSellingItems;
GO
DROP PROCEDURE IF EXISTS sp_PlaceOrder;
GO
DROP PROCEDURE IF EXISTS sp_AddOrderItem;
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
GO

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
GO

-- Create Inventory table (simplified)
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY IDENTITY(1,1),
    ItemName VARCHAR(100) NOT NULL,
    CategoryID INT,
    Notes TEXT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

-- Create Staff table (simplified)
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL
);
GO

-- Create Customers table (simplified)
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Notes TEXT
);
GO

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
GO

-- Create a cross-reference table between MenuItems and Inventory
CREATE TABLE MenuItemIngredients (
    MenuItemID INT,
    InventoryID INT,
    Quantity DECIMAL(10,3) NOT NULL,
    PRIMARY KEY (MenuItemID, InventoryID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(ItemID),
    FOREIGN KEY (InventoryID) REFERENCES Inventory(InventoryID)
);
GO

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
GO

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
GO

-- Insert main categories
INSERT INTO Categories (CategoryName, Description) VALUES 
('Food Ingredients', 'Raw ingredients used in food preparation'),
('Drink Ingredients', 'Raw ingredients used in drink preparation'),
('Packaging', 'Containers and packaging materials'),
('Menu - Food', 'Food items on the menu'),
('Menu - Drinks', 'Beverage items on the menu'),
('Menu - Desserts', 'Dessert items on the menu'),
('Menu - Sides', 'Side dish items on the menu'),
('Sauces', 'Different types of sauces'),
('Toppings', 'Toppings for dishes and drinks');
GO

-- Get category IDs for easy reference
DECLARE @FoodIngredientsCat INT = (SELECT CategoryID FROM Categories WHERE CategoryName = 'Food Ingredients');
DECLARE @DrinkIngredientsCat INT = (SELECT CategoryID FROM Categories WHERE CategoryName = 'Drink Ingredients');
DECLARE @PackagingCat INT = (SELECT CategoryID FROM Categories WHERE CategoryName = 'Packaging');
DECLARE @SaucesCat INT = (SELECT CategoryID FROM Categories WHERE CategoryName = 'Sauces');

-- Insert inventory items based on the provided ingredients
INSERT INTO Inventory (ItemName, CategoryID) VALUES
-- Food Ingredients
('Chicken', @FoodIngredientsCat),
('Sugar', @FoodIngredientsCat),
('Black Pepper', @FoodIngredientsCat),
('Garlic', @FoodIngredientsCat),
('Kalamansi', @FoodIngredientsCat),
('Egg', @FoodIngredientsCat),
('Salt', @FoodIngredientsCat),
('Sesame Oil', @FoodIngredientsCat),
('Nam2/Magic Sarap', @FoodIngredientsCat),
('Cassava Flour', @FoodIngredientsCat),
('Ground Beef', @FoodIngredientsCat),
('Onion', @FoodIngredientsCat),
('All Purpose Flour', @FoodIngredientsCat),
('Bread Crumbs', @FoodIngredientsCat),
('Oyster', @FoodIngredientsCat),

-- Packaging
('Cups', @PackagingCat),
('Straws', @PackagingCat),
('Plastics Single', @PackagingCat),
('Plastics Double', @PackagingCat),
('Tiny Container', @PackagingCat),
('Medium Container', @PackagingCat),

-- Drink Ingredients
('Caramel', @DrinkIngredientsCat),
('Chocolate', @DrinkIngredientsCat),
('Ube', @DrinkIngredientsCat),
('Matcha Powder', @DrinkIngredientsCat),
('French Vanilla', @DrinkIngredientsCat),
('Salted Caramel', @DrinkIngredientsCat),
('Milk', @DrinkIngredientsCat),
('Coffee Beans', @DrinkIngredientsCat),
('Condensed Milk', @DrinkIngredientsCat),
('Strawberry Syrup', @DrinkIngredientsCat),
('Mixed Berries Syrup', @DrinkIngredientsCat),
('Lemon Syrup', @DrinkIngredientsCat),
('Lychee Syrup', @DrinkIngredientsCat),
('Green Apple Syrup', @DrinkIngredientsCat),
('Wintermelon Syrup', @DrinkIngredientsCat),
('Oreos', @DrinkIngredientsCat),
('Cinnamon Powder', @DrinkIngredientsCat),

-- Sauces and Toppings
('Mango Jam', @SaucesCat),
('Strawberry Jam', @SaucesCat),
('Blueberry Jam', @SaucesCat),
('Parmesan', @SaucesCat),
('Honey Glazed', @SaucesCat),
('Margarine', @SaucesCat),
('Buffalo Sauce', @SaucesCat),
('Soy Sauce', @SaucesCat),
('Teriyaki Sauce', @SaucesCat),
('Sweet Chili Sauce', @SaucesCat),
('BBQ Sauce', @SaucesCat);
GO

-- Insert sample staff
INSERT INTO Staff (FirstName, LastName) VALUES
('Anna', 'Garcia'),
('Ben', 'Smith'),
('Carlos', 'Martinez'),
('Diana', 'Johnson');
GO

-- Insert sample customers
INSERT INTO Customers (FirstName, LastName, Notes) VALUES
('John', 'Doe', 'Regular customer, prefers takeout'),
('Jane', 'Smith', 'Prefers delivery'),
('Mike', 'Brown', 'Usually orders for large groups');
GO

-- Insert sample menu categories
DECLARE @FoodMenuCat INT = (SELECT CategoryID FROM Categories WHERE CategoryName = 'Menu - Food');
DECLARE @DrinksMenuCat INT = (SELECT CategoryID FROM Categories WHERE CategoryName = 'Menu - Drinks');
DECLARE @SidesMenuCat INT = (SELECT CategoryID FROM Categories WHERE CategoryName = 'Menu - Sides');

-- Insert menu items
INSERT INTO MenuItems (ItemName, CategoryID, Description, Price, Recipe, Active) VALUES
('Fried Chicken', @FoodMenuCat, 'Crispy classic fried chicken', 199.00, 'Marinate chicken with salt, pepper, and spices. Coat with flour and fry until golden.', 1),
('Beef Steak', @FoodMenuCat, 'Tender beef steak cooked to perfection', 250.00, 'Season beef with salt and pepper. Grill to desired doneness.', 1),
('Caramel Macchiato', @DrinksMenuCat, 'Sweet caramel coffee with steamed milk', 120.00, 'Espresso with steamed milk and caramel syrup.', 1),
('Wintermelon Milk Tea', @DrinksMenuCat, 'Milk tea with wintermelon flavor', 95.00, 'Tea with wintermelon syrup and milk, served over ice.', 1),
('Chicken Nuggets', @SidesMenuCat, 'Crispy chicken nuggets', 85.00, 'Ground chicken formed into nuggets, breaded and fried.', 1);
GO

-- Insert sample orders
INSERT INTO Orders (CustomerID, StaffID, OrderDate, OrderType, OrderStatus, TotalAmount, PaymentStatus) VALUES
(1, 1, '2023-05-09 09:30:00', 'Dine-in', 'Completed', 319.00, 'Paid'),
(2, 3, '2023-05-10 13:45:00', 'Takeout', 'Completed', 215.00, 'Paid'),
(3, 3, '2023-05-11 16:20:00', 'Delivery', 'Delivered', 535.00, 'Paid');
GO

-- Insert order items
INSERT INTO OrderItems (OrderID, ItemID, Quantity, UnitPrice) VALUES
(1, 1, 1, 199.00), -- Fried Chicken
(1, 3, 1, 120.00), -- Caramel Macchiato
(2, 4, 1, 95.00),  -- Wintermelon Milk Tea
(2, 5, 1, 85.00),  -- Chicken Nuggets
(2, 3, 1, 120.00), -- Caramel Macchiato
(3, 2, 2, 250.00), -- 2 Beef Steaks
(3, 3, 2, 120.00), -- 2 Caramel Macchiatos
(3, 5, 1, 85.00);  -- Chicken Nuggets
GO

-- View for menu items with their categories
CREATE VIEW vw_MenuItemsWithCategories
AS
SELECT m.ItemID, m.ItemName, m.Price, c.CategoryName, m.Active
FROM MenuItems m
JOIN Categories c ON m.CategoryID = c.CategoryID;
GO

-- View for daily sales report
CREATE VIEW vw_DailySalesReport
AS
SELECT CAST(o.OrderDate AS DATE) AS OrderDate, 
       COUNT(DISTINCT o.OrderID) AS TotalOrders,
       SUM(o.TotalAmount) AS TotalSales,
       AVG(o.TotalAmount) AS AverageOrderValue
FROM Orders o
WHERE o.OrderStatus IN ('Completed', 'Delivered')
GROUP BY CAST(o.OrderDate AS DATE);
GO

-- View for top selling items
CREATE VIEW vw_TopSellingItems
AS
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
GO

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
    
    SELECT @OrderID AS OrderID, 'Order created successfully' AS Result;
END
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
END
GO
