-- MySQL import script for BrewCode POS Project
-- This script creates the database structure and imports data from CSV files

-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS KohiDB;

-- Use the newly created database
USE KohiDB;

-- Drop tables if they exist to avoid errors on recreating the database
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Inventory;
DROP TABLE IF EXISTS MenuItems;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Transactions;

-- Create Categories table
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL,
    Description VARCHAR(255)
);

-- Create MenuItems table
CREATE TABLE MenuItems (
    MenuItemID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description VARCHAR(255),
    Price DECIMAL(10, 2) NOT NULL,
    CategoryID INT,
    ImagePath VARCHAR(255),
    IsAvailable BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Create Inventory table
CREATE TABLE Inventory (
    InventoryID INT AUTO_INCREMENT PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    UnitOfMeasure VARCHAR(20) NOT NULL,
    QuantityInStock DECIMAL(10, 2) NOT NULL,
    ReorderLevel DECIMAL(10, 2) NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    LastRestockDate DATETIME,
    ExpiryDate DATETIME,
    SupplierInfo VARCHAR(255)
);

-- Create Customers table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(20),
    PointsBalance INT DEFAULT 0,
    RegistrationDate DATETIME
);

-- Create Staff table
CREATE TABLE Staff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Position VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Username VARCHAR(50) NOT NULL,
    Password VARCHAR(255) NOT NULL,
    HireDate DATETIME
);

-- Create Orders table
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    StaffID INT,
    OrderDate DATETIME NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    OrderStatus VARCHAR(20) NOT NULL,
    OrderType VARCHAR(20) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

-- Create OrderItems table
CREATE TABLE OrderItems (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    MenuItemID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Subtotal DECIMAL(10, 2) NOT NULL,
    Notes VARCHAR(255),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

-- Create Transactions table
CREATE TABLE Transactions (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    TransactionDate DATETIME NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentMethod VARCHAR(50) NOT NULL,
    Status VARCHAR(20) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Load data from CSV files
-- Note: You'll need to update the file paths to match your environment
-- and make sure MySQL has permissions to read these files

-- Load Categories data
LOAD DATA INFILE '/path/to/categories_updated.csv' 
INTO TABLE Categories
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CategoryID, CategoryName, Description);

-- Load MenuItems data
LOAD DATA INFILE '/path/to/menu_items_updated.csv' 
INTO TABLE MenuItems
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(MenuItemID, Name, Description, Price, CategoryID, ImagePath, IsAvailable);

-- Load Inventory data
LOAD DATA INFILE '/path/to/inventory_updated.csv' 
INTO TABLE Inventory
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InventoryID, ItemName, UnitOfMeasure, QuantityInStock, ReorderLevel, UnitPrice, @LastRestockDate, @ExpiryDate, SupplierInfo)
SET LastRestockDate = NULLIF(@LastRestockDate, ''),
    ExpiryDate = NULLIF(@ExpiryDate, '');

-- Load Customers data
LOAD DATA INFILE '/path/to/customers.csv' 
INTO TABLE Customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(CustomerID, FirstName, LastName, Email, Phone, PointsBalance, @RegistrationDate)
SET RegistrationDate = NULLIF(@RegistrationDate, '');

-- Load Staff data
LOAD DATA INFILE '/path/to/staff.csv' 
INTO TABLE Staff
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(StaffID, FirstName, LastName, Position, Email, Phone, Username, Password, @HireDate)
SET HireDate = NULLIF(@HireDate, '');

-- Load Orders data
LOAD DATA INFILE '/path/to/orders.csv' 
INTO TABLE Orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(OrderID, CustomerID, StaffID, @OrderDate, TotalAmount, OrderStatus, OrderType)
SET OrderDate = NULLIF(@OrderDate, '');

-- Load OrderItems data
LOAD DATA INFILE '/path/to/order_items.csv' 
INTO TABLE OrderItems
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(OrderItemID, OrderID, MenuItemID, Quantity, UnitPrice, Subtotal, Notes);

-- Load Transactions data
LOAD DATA INFILE '/path/to/transactions.csv' 
INTO TABLE Transactions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(TransactionID, OrderID, @TransactionDate, Amount, PaymentMethod, Status)
SET TransactionDate = NULLIF(@TransactionDate, '');

-- Note: When using this script with MySQL Workbench or MySQL CLI, you may need to:
-- 1. Update the file paths for LOAD DATA INFILE to match your system
-- 2. Set secure_file_priv variable to allow MySQL to read files from your directories
-- 3. You might need to use LOCAL keyword (LOAD DATA LOCAL INFILE) depending on your MySQL configuration
